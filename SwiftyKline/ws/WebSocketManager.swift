//
//  WebSocketManager.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/21.
//

import UIKit
import Combine
import Starscream

open class WebSocketManager: WebSocketDelegate {
  lazy var cancellables = Set<AnyCancellable>()

  public private(set) var url: String

  var socket: WebSocket?

  public enum Status {
    case unknown // 新建对象/手动断连
    case connecting
    case connected
    case failed
    case disconnected
    var shouldRecover: Bool {
      self == .connecting || self == .connected || self == .failed || self == .disconnected
    }
  }
  public private(set) var status: Status = .unknown
  var recoverWhenBack = false

  public init(_ addr: String) {
    url = addr
    bindEvents()
  }


  public func resetUrl(_ addr: String?) {
    guard let addr = addr else { return }
    url = addr
    connect(true)
  }

  public func connect(_ force: Bool) {
    print("[WS] to connect")
    guard !url.isEmpty else { return }
    if force || (status != .connecting && status != .connected) {
      stopAndPrepare()
      status = .connecting
      delayOpenSocket(0.25)
    }
  }

  public func disconnect() {
    print("[WS] to disconnect")
    stopAndPrepare()
    status = .unknown
  }

  func stopAndPrepare() {
    cancelDelayOpenSocket()
    closeSocket()
    retryTimes = 0
  }


  public func send(_ val: String?) {
    guard let val = val else { return }
    switch status {
    case .unknown, .failed, .disconnected:
      connect(false)
    case .connecting:
      break
    case .connected:
      socket?.write(string: val) {
        print("[WS] did send: \(val)")
      }
    }
  }

  open func recv(_ val: Data) {
  }


  var openSocketWork: DispatchWorkItem?
  func delayOpenSocket(_ delay: Double) {
    cancelDelayOpenSocket()
    let work = DispatchWorkItem { [weak self] in self?.openSocket() }
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    openSocketWork = work
  }
  func cancelDelayOpenSocket() {
    openSocketWork?.cancel()
    openSocketWork = nil
  }

  func openSocket() {
    if let url = URL(string: url) {
      print("[WS] to open: \(url)")
      var request = URLRequest(url: url)
      request.timeoutInterval = 10
      socket = WebSocket(request: request)
      socket?.delegate = self
      socket?.connect()
    } else {
      // think about why you are here, idiot
      print("[WS] to open: ___")
    }
  }
  func closeSocket() {
    guard socket != nil else { return }
    print("[WS] to close")
    socket?.delegate = nil
    socket?.disconnect()
    socket = nil
  }

  public func didReceive(event: WebSocketEvent, client: WebSocketClient) {
    switch event {
    case let .connected(headers):
      print("[WS] receive connected: \(headers)")
      retryTimes = 0
      status = .connected
      restore()
    case let .disconnected(reason, code):
      print("[WS] receive disconnected: \(reason) \(code)")
      closeSocket()
      retryTimes = 0
      status = .disconnected

    case let .text(txt):
      print("[WS] receive text: \(txt)")
      recv(Data(txt.utf8))
    case let .binary(dat):
      print("[WS] receive data: \(String(decoding: dat, as: UTF8.self))")
      recv(dat)

    case let .error(err):
      if let err = err {
        print("[WS] receive error: \(err.localizedDescription)")
      } else {
        print("[WS] receive error: ___")
      }
      closeSocket()
      retry()
    case .cancelled:
      print("[WS] receive cancelled, the end of the stream has been reached")
      closeSocket()
      retryTimes = 0
      status = .disconnected
    case .peerClosed:
      print("[WS] receive peer closed")
      closeSocket()
      retryTimes = 0
      status = .disconnected

    case let .ping(dat):
      if let dat = dat {
        print("[WS] receive ping: \(dat.count)")
      } else {
        print("[WS] receive ping: ___")
      }
    case let .pong(dat):
      if let dat = dat {
        print("[WS] receive pong: \(dat.count)")
      } else {
        print("[WS] receive pong: ___")
      }

    case let .viabilityChanged(value):
      print("[WS] receive viability changed: \(value)")
    case let .reconnectSuggested(value):
      print("[WS] receive reconnect suggested: \(value)")

    @unknown default:
      print("[WS] receive unknown")
    }
  }

  var retryTimes = 0
  func retry() {
    if (retryTimes < 20) {
      retryTimes += 1
      status = .connecting
      let timing: (Double)->Double = { 1 - pow(1 - $0, 3) } // https://easings.net/#easeOutCubic
      let delay = timing(Double(retryTimes) / 20) * 5
      print("[WS] retry after \(delay)s \(retryTimes)/20")
      delayOpenSocket(delay)
    } else {
      print("[WS] won't retry again")
      retryTimes = 0
      status = .failed
    }
  }


  @Published var foreground = true
  func bindEvents() {
    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
      .sink { [weak self] _ in self?.foreground = false }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      .sink { [weak self] _ in self?.foreground = true }
      .store(in: &cancellables)

    $foreground
      .dropFirst()
      .filter { $0 == true }
      .debounce(for: .seconds(4), scheduler: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.foreground {
          print("[WS] fore, fore:conn, recover:\(self.recoverWhenBack)")
          if self.recoverWhenBack == true {
            self.recoverWhenBack = false
            self.connect(false)
          }
        } else {
          print("[WS] fore, back:____")
        }
      }
      .store(in: &cancellables)

    $foreground
      .dropFirst()
      .filter { $0 == false }
      .debounce(for: .seconds(8), scheduler: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.foreground {
          print("[WS] back, fore:____")
        } else {
          print("[WS] back, back:disc, shouldRecover:\(self.status.shouldRecover)")
          if self.status.shouldRecover {
            self.recoverWhenBack = true
          }
          self.stopAndPrepare()
        }
      }
      .store(in: &cancellables)
  }


  public struct Sub {
    public var times = 0
    public var key: String
    public var subscribe: String?
    public var unsubscribe: String?
    public var publisher: Any?
  }
  public var subs: [String:Sub] = [:]

  public func addSub<T>(_ key: String, _ sub: String? = nil, _ uns: String? = nil) -> PassthroughSubject<T,Never> {
    var it = subs[key] ?? Sub(key: key, subscribe: sub, unsubscribe: uns)
    it.times += 1
    let publisher = it.publisher as? PassthroughSubject<T,Never> ?? PassthroughSubject<T,Never>()
    it.publisher = publisher
    subs[key] = it
    if it.times == 1 {
      send(it.subscribe)
    }
    return publisher
  }

  public func removeSub(_ key: String) {
    if var it = subs[key] {
      if it.times <= 1 {
        subs[key] = nil
        send(it.unsubscribe)
      } else {
        it.times -= 1
        subs[key] = it
      }
    }
  }

  func restore() {
    subs.values
      .filter { $0.times > 0 }
      .forEach { send($0.subscribe) }
  }
}
