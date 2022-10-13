//
//  KlineView_OverlayView.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

extension KlineView {

  class OverlayView: UIView {
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setup()
    }
    override init(frame: CGRect) {
      super.init(frame: frame)
      setup()
    }
    func setup() {
      backgroundColor = .clear

      layer.insertSublayer(shadowLayer, at: 0)

      addSubview(stackView)
      fields.forEach { stackView.addArrangedSubview($0) }

      reloadTheme()
      reloadLanguage()
    }

    func reloadTheme() {
      fields.forEach {
        $0.titleLabel.textColor = .kline_overlay_field_title
        $0.valueLabel.textColor = .kline_overlay_field_value
      }
      shadowLayer.backgroundColor = UIColor.kline_overlay_background?.cgColor
      shadowLayer.shadowColor = UIColor.kline_overlay_shadow?.cgColor
    }
    func reloadLanguage() {
      let titles = [
        "Time",
        "Open",
        "High",
        "Low",
        "Close",
        "Volume",
        "Txn",
      ]
      fields.enumerated().forEach {
        $0.element.titleLabel.text = titles.at($0.offset)
      }
    }


    override func layoutSubviews() {
      super.layoutSubviews()
      shadowLayer.frame = bounds
      stackView.frame = CGRect(x: 8,
                               y: 10,
                               width: bounds.width - 8*2,
                               height: bounds.height - 10*2)
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
      CGSize(width: 140,
             height: 10*2 + 18 * fields.count.dbl)
    }


    var values: [String] = [] {
      didSet {
        fields.enumerated().forEach {
          $0.element.valueLabel.text = values.at($0.offset) ?? "--"
        }
      }
    }


    lazy var fields: [Field] = {
      (0..<7).map { _ in Field() }
    }()

    lazy var stackView: UIStackView = {
      let ret = UIStackView()
      ret.axis = .vertical
      ret.alignment = .fill
      ret.distribution = .fillEqually
      return ret
    }()

    lazy var shadowLayer: CALayer = {
      let ret = CALayer()

      ret.backgroundColor = UIColor.kline_overlay_background?.cgColor
      ret.cornerRadius = 3

      ret.shadowColor = UIColor.kline_overlay_shadow?.cgColor
      ret.shadowRadius = 6.0
      ret.shadowOpacity = 0.25
      ret.shadowOffset = .zero

      return ret
    }()


    class Field: UIView {
      override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
      }
      required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
      }
      func setup() {
        addSubview(titleLabel)
        addSubview(valueLabel)
      }
      override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
        valueLabel.frame = bounds
      }
      lazy var titleLabel: UILabel = {
        let ret = UILabel()
        ret.font = .kline_overlay_field_title
        ret.textColor = .kline_overlay_field_title
        ret.textAlignment = .left
        return ret
      }()
      lazy var valueLabel: UILabel = {
        let ret = UILabel()
        ret.font = .kline_overlay_field_value
        ret.textColor = .kline_overlay_field_value
        ret.textAlignment = .right
        return ret
      }()
    }

  }

}
