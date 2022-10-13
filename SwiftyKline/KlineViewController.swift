//
//  KlineViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SwiftyJSON

class KlineViewController: UIViewController {

  open override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    layoutViews()
    bindEvents()
  }

  open override func updateViewConstraints() {
    layoutViews()
    super.updateViewConstraints()
  }

  func setup() {
    view.backgroundColor = .white

    view.addSubview(klineView)
    view.addSubview(btn1)
    view.addSubview(btn2)
    MainWS.shared.connect(true)
  }
  func layoutViews() {
    klineView.snp.remakeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(100)
    }
    btn1.snp.remakeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.top.equalTo(klineView.snp.bottom).offset(20)
      make.height.equalTo(40)
    }
    btn2.snp.remakeConstraints { make in
      make.trailing.equalToSuperview().offset(-20)
      make.top.equalTo(klineView.snp.bottom).offset(20)
      make.height.equalTo(40)
      make.leading.equalTo(btn1.snp.trailing).offset(20)
      make.width.equalTo(btn1)
    }
  }
  func bindEvents() {

    comb_pack($symbol, klineView.intervalView.intervalPub)
      .sink { [weak self] symbol, interval in
        self?.unsubscribeWebSocket()
      }
      .store(in: &cancellables)

    comb_pack($symbol, klineView.intervalView.intervalPub)
      .map { symbol, interval in
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.binance.com/api/v3/klines?symbol=\(symbol.uppercased())&interval=\(interval.value)")!)
          .map { $0.data }
          .replaceError(with: Data())
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] data in
        guard let self = self else { return }
        guard !data.isEmpty else { return }
        print("[kline] http: got data")
        self.list = JSON.fromAny(data).array?.map({ KlineModel(any: $0) }) ?? []
        self.klineView.clear()
        self.klineView.resetKlineList(self.list, self.decimals)
        self.subscribeWebSocket()
      }
      .store(in: &cancellables)


    klineView.subtypeView.primaryPub
      .dropFirst()
      .sink { [weak self] _ in
        guard let self = self else { return }
        self.klineView.clear()
        self.klineView.resetKlineList(self.list, self.decimals)
      }
      .store(in: &cancellables)

    klineView.subtypeView.secondaryPub
      .dropFirst()
      .sink { [weak self] _ in
        guard let self = self else { return }
        self.klineView.clear()
        self.klineView.resetKlineList(self.list, self.decimals)
      }
      .store(in: &cancellables)
  }

  var oldSymbol: String?
  var oldInterval: KlineView.IntervalView.Interval?
  func subscribeWebSocket() {
    print("[kline] subscribe start: \(symbol) \(klineView.intervalView.interval.value)")
    MainWS.shared.subscribeKline(symbol, klineView.intervalView.interval.value)
      .sink { [weak self] model in
        guard let self = self else { return }
        self.klineView.addKlineItem(model)
        if let index = self.list.firstIndex(where: { $0.begin == model.begin }) {
          self.list[index] = model
        } else {
          self.list.append(model)
        }
      }
      .store(in: &cancellables)
    oldSymbol = symbol
    oldInterval = klineView.intervalView.interval
  }
  func unsubscribeWebSocket() {
    if let oldSymbol = oldSymbol, !oldSymbol.isEmpty,
       let oldInterval = oldInterval
    {
      print("[kline] subscribe stop: \(oldSymbol) \(oldInterval.value)")
      MainWS.shared.unsubscribeKline(oldSymbol, oldInterval.value)
    }
    print("[kline] subscribe prepare: \(symbol) \(klineView.intervalView.interval.value)")
  }

  var list: [KlineModel] = []



  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  }



  let symbols = ["ethusdt", "shibusdt"]

  @Setted var symbol = "ethusdt" {
    didSet {
      btn1.isEnabled = symbol != symbols[0]
      btn2.isEnabled = symbol != symbols[1]
    }
  }

  var decimals: Int? {
    symbol.hasPrefix("shib") ? 6 : 4
  }

  lazy var klineView: KlineView = {
    let ret = KlineView()
    return ret
  }()

  lazy var btn1: UIButton = {
    let ret = UIButton(type: .custom)
    ret.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    ret.setTitle(symbols[0], for: .normal)
    ret.setTitleColor(.lightGray, for: .normal)
    ret.setTitleColor(.black, for: .highlighted)
    ret.setTitleColor(.black, for: .disabled)
    ret.isEnabled = false
    ret.cmb.tap
      .sink { [weak self] in
        guard let self = self else { return }
        self.symbol = self.symbols[0]
      }
      .store(in: &cancellables)
    return ret
  }()

  lazy var btn2: UIButton = {
    let ret = UIButton(type: .custom)
    ret.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    ret.setTitle(symbols[1], for: .normal)
    ret.setTitleColor(.lightGray, for: .normal)
    ret.setTitleColor(.black, for: .highlighted)
    ret.setTitleColor(.black, for: .disabled)
    ret.cmb.tap
      .sink { [weak self] in
        guard let self = self else { return }
        self.symbol = self.symbols[1]
      }
      .store(in: &cancellables)
    return ret
  }()

  public lazy var cancellables = Set<AnyCancellable>()
}
