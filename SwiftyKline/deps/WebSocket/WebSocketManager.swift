//
//  WebSocketManager.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import Starscream

public class WebSocketManager: BaseObject {

  var url: String?
  var retryTimes = 0
  var socket: WebSocket?

  enum Status {
    case unknown
    case connecting
    case connected
    case failed
    case disconnected
    var shouldRecover: Bool {
      self == .connecting || self == .connected || self == .failed
    }
  }
  var status: Status = .unknown
  var reconnectWhenBack = false

  init(_ url: String) {
    self.url = url
    super.init()
    bindEvents()
  }


  public func resetUrl(_ url: String?) {
    self.url = url
    connect(true)
  }

  public func connect(_ force: Bool) {
    guard url?.isEmpty == false else { return }
    if force || status != .connected {
      cancelDelayOpenSocket()
      retryTimes = 0
      closeSocket()
      status = .connecting
      delayOpenSocket(0.25)
    }
  }

  public func disconnect() {
    cancelDelayOpenSocket()
    retryTimes = 0
    closeSocket()
    status = .disconnected
  }


  func retryOpenSocket() {
    if (retryTimes < 20) {
      retryTimes += 1
      let timing: (Double)->Double = { 1 - pow(1 - $0, 3) } // https://easings.net/#easeOutCubic
      let delay = timing(Double(retryTimes) / 20) * 5

      print("[WS] retry after \(delay)s \(retryTimes)/20")
      delayOpenSocket(delay)
    } else {
      print("[WS] won't retry again")
      retryTimes = 0;
      status = .failed
    }
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
    if let url = URL(string: url ?? "") {
      print("[WS] to open: \(url)")
      var request = URLRequest(url: url)
      request.timeoutInterval = 10
      socket = WebSocket(request: request)
      socket?.delegate = self
      socket?.connect()
    } else {
      // think about why you are here, idiot
    }
  }
  func closeSocket() {
    socket?.delegate = nil
    socket?.disconnect()
    socket = nil
  }


  struct Entry {
    var key: String
    var subscribe: String
    var unsubscribe: String
    var times: Int
    var publisher: Any
  }
  var entries: [String:Entry] = [:]
  func addEntry<T>(_ key: String, _ subscribe: String, _ unsubscribe: String) -> PassthroughSubject<T,Never> {
    if var entry = entries[key] {
      entry.times += 1
      let publisher = entry.publisher as? PassthroughSubject<T,Never> ?? PassthroughSubject<T,Never>()
      entry.publisher = publisher
      entries[key] = entry
      return publisher
    } else {
      let publisher = PassthroughSubject<T,Never>()
      let entry = Entry(key: key, subscribe: subscribe, unsubscribe: unsubscribe, times: 1, publisher: publisher)
      entries[key] = entry
      send(subscribe)
      return publisher
    }
  }
  func removeEntry(_ key: String) {
    if let entry = entries[key] {
      if entry.times <= 1 {
        entries[key] = nil
        send(entry.unsubscribe)
      } else {
        var val = entry
        val.times -= 1
        entries[key] = val
      }
    }
  }
  func restoreEntries() {
    entries.values
      .filter { $0.times > 0 }
      .forEach { send($0.subscribe) }
  }


  func bindEvents() {
//    NetworkMonitor.shared.$status
//      .sink { [weak self] in
//        guard let self = self else { return }
//        if $0.isReachable {
//          if self.status.shouldRecover {
//            self.connect(true)
//          }
//        }
//      }
//      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
      .sink { _ in
        print("[WS] will enter foreground")
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink { _ in
        print("[WS] did enter background")
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
      .sink { [weak self] _ in
        print("[WS] will resign active")
        guard let self = self else { return }
        if self.status.shouldRecover {
          self.reconnectWhenBack = true
        }
        self.disconnect()
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      .sink { [weak self] _ in
        print("[WS] did become active")
        guard let self = self else { return }
        if self.reconnectWhenBack == true {
          self.reconnectWhenBack = false
          self.connect(true)
        }
      }
      .store(in: &cancellables)
  }


  func send(_ val: String) {
    if status == .connected {
      socket?.write(string: val) { print("[WS] did write: \(val)") }
    }
  }

  func recv(_ val: Data) {
  }

}

extension WebSocketManager: WebSocketDelegate {

  public func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case let .connected(headers):
      print("[WS] received connected: \(headers)")
      status = .connected
      restoreEntries()
    case let .disconnected(reason, code):
      print("[WS] received disconnected: \(reason) \(code)")
      status = .disconnected

    case let .text(txt):
      print("[WS] received text: \(txt)")
      recv(txt.dat)
    case let .binary(dat):
      print("[WS] received data: \(dat.count)")
      recv(dat)

    case let .error(err):
      if let err = err {
        print("[WS] received error: \(err.localizedDescription)")
      } else {
        print("[WS] received error: nil")
      }
      closeSocket()
      retryOpenSocket()
    case .cancelled:
      print("[WS] received cancelled")
      closeSocket()
      status = .failed

    case let .ping(dat):
      if let dat = dat {
        print("[WS] received ping: \(dat.count)")
      } else {
        print("[WS] received ping: nil")
      }
    case let .pong(dat):
      if let dat = dat {
        print("[WS] received pong: \(dat.count)")
      } else {
        print("[WS] received pong: nil")
      }

    case let .viabilityChanged(value):
      print("[WS] received viability changed: \(value)")
    case let .reconnectSuggested(value):
      print("[WS] received reconnect suggested: \(value)")
    }
  }

}
