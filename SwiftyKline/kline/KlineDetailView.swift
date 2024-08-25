//
//  KlineDetailView.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/24.
//

import UIKit

class KlineDetailView: UIView {
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

    fields.forEach {
      addSubview($0.0)
      addSubview($0.1)
    }
  }

  lazy var fields: [(UILabel,UILabel)] = [
    "Time",
    "Open",
    "High",
    "Low",
    "Close",
    "Volume",
    "Txn",
  ].map {
    let lb1 = UILabel()
    lb1.font = kline_detail_field_title_f
    lb1.textColor = kline_detail_field_title_c
    lb1.textAlignment = .left
    lb1.text = $0
    let lb2 = UILabel()
    lb2.font = kline_detail_field_value_f
    lb2.textColor = kline_detail_field_value_c
    lb2.textAlignment = .right
    return (lb1, lb2)
  }

  func fill(_ values: [String?]) {
    fields.enumerated().forEach {
      if $0.offset >= 0 && $0.offset < values.count {
        $0.element.1.text = values[$0.offset] ?? "--"
      } else {
        $0.element.1.text = "--"
      }
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    shadowLayer.frame = bounds
    for it in fields.enumerated() {
      it.element.0.sizeToFit()
      it.element.0.frame = CGRect(x: 8, y: 10 + it.offset.d * 18, width: it.element.0.bounds.width, height: 18)
      it.element.1.frame = CGRect(x: 8 + it.element.0.bounds.width, y: 10 + it.offset.d * 18, width: bounds.width - 2*8 - it.element.0.bounds.width, height: 18)
    }
  }
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(width: 140, height: 10*2 + 18 * fields.count.d)
  }

  lazy var shadowLayer: CALayer = {
    let ret = CALayer()

    ret.backgroundColor = kline_detail_background_c.cgColor
    ret.cornerRadius = 3

    ret.shadowColor = kline_detail_shadow_c.cgColor
    ret.shadowRadius = 6.0
    ret.shadowOpacity = 0.25
    ret.shadowOffset = .zero

    return ret
  }()
}
