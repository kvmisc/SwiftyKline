//
//  KlineView_SubtypeView.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public extension KlineView {

  class SubtypeView: UIView {
    required init?(coder: NSCoder) { fatalError("not implemented") }
    public override init(frame: CGRect) {
      super.init(frame: frame)
      setup()
      layoutViews()
    }
    func setup() {
      backgroundColor = "#eaeaea".clr
      addSubview(primaryStack)
      addSubview(secondaryStack)

      primaryList = [
        Primary.ma,
        Primary.ema,
        Primary.boll,
      ].map { type -> UIButton in
        let btn = UIButton(type: .custom)
        btn.tag = type.rawValue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(type.title, for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.setTitleColor(.black, for: .disabled)
        btn.isEnabled = type != self.primary
        btn.addTarget(self, action: #selector(primaryAction(_:)), for: .touchUpInside)
        return btn
      }
      primaryList.forEach { primaryStack.addArrangedSubview($0) }

      secondaryList = [
        Secondary.vol,
        Secondary.macd,
        Secondary.kdj,
        Secondary.rsi,
      ].map { type -> UIButton in
        let btn = UIButton(type: .custom)
        btn.tag = type.rawValue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(type.title, for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.setTitleColor(.black, for: .disabled)
        btn.isEnabled = type != self.secondary
        btn.addTarget(self, action: #selector(secondaryAction(_:)), for: .touchUpInside)
        return btn
      }
      secondaryList.forEach { secondaryStack.addArrangedSubview($0) }
    }
    func layoutViews() {
      primaryStack.snp.remakeConstraints { make in
        make.top.bottom.equalToSuperview()
        make.leading.equalToSuperview().offset(20)
        make.width.equalTo(120)
      }
      secondaryStack.snp.remakeConstraints { make in
        make.top.bottom.equalToSuperview()
        make.trailing.equalToSuperview().offset(-20)
        make.width.equalTo(160)
      }
    }

    public private(set) var primaryList: [UIButton] = []

    public private(set) var secondaryList: [UIButton] = []


    public enum Primary: Int {
      case ma
      case ema
      case boll
      public var title: String {
        switch self {
        case .ma: return "MA"
        case .ema: return "EMA"
        case .boll: return "BOLL"
        }
      }
    }
    public var primary: Primary = .ma {
      didSet {
        primaryList.forEach { $0.isEnabled = $0.tag != primary.rawValue }
      }
    }
    public let primaryPub = CurrentValueSubject<Primary,Never>(.ma)

    public enum Secondary: Int {
      case vol
      case macd
      case kdj
      case rsi
      public var title: String {
        switch self {
        case .vol: return "VOL"
        case .macd: return "MACD"
        case .kdj: return "KDJ"
        case .rsi: return "RSI"
        }
      }
    }
    public var secondary: Secondary = .vol {
      didSet {
        secondaryList.forEach { $0.isEnabled = $0.tag != secondary.rawValue }
      }
    }
    public let secondaryPub = CurrentValueSubject<Secondary,Never>(.vol)


    @objc func primaryAction(_ sender: UIButton) {
      if let type = Primary(rawValue: sender.tag) {
        self.primary = type
        primaryPub.send(type)
      }
    }

    @objc func secondaryAction(_ sender: UIButton) {
      if let type = Secondary(rawValue: sender.tag) {
        self.secondary = type
        secondaryPub.send(type)
      }
    }

    public override var intrinsicContentSize: CGSize {
      CGSize(width: UIView.noIntrinsicMetric, height: 30)
    }

    public lazy var primaryStack: UIStackView = {
      let ret = UIStackView()
      ret.axis = .horizontal
      ret.alignment = .fill
      ret.distribution = .equalSpacing
      ret.spacing = 4
      return ret
    }()

    public lazy var secondaryStack: UIStackView = {
      let ret = UIStackView()
      ret.axis = .horizontal
      ret.alignment = .fill
      ret.distribution = .equalSpacing
      ret.spacing = 4
      return ret
    }()
  }

}
