//
//  KlineXFormatter.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

class KlineXFormatter: AxisValueFormatter {

  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    let i = value.i
    if i >= 0 && i < titles.count {
      return titles[i]
    } else {
      return ""
    }
  }


  var titles: [String] = []

  func reload(_ times: [Double]) {
    titles = times.map { format($0) }
  }
  func format(_ time: Double) -> String {
    let date = Date(timeIntervalSince1970: time < 100_0000_0000 ? time : time / 1000)
    if Calendar.current.isDate(date, inSameDayAs: Date()) {
      return today.string(from: date)
    } else {
      return ago.string(from: date)
    }
  }

  lazy var today: DateFormatter = {
    let ret = DateFormatter()
    ret.dateFormat = "HH:mm"
    ret.locale = Locale(identifier: "en_US_POSIX")
    return ret
  }()

  lazy var ago: DateFormatter = {
    let ret = DateFormatter()
    ret.dateFormat = "MM-dd HH:mm"
    ret.locale = Locale(identifier: "en_US_POSIX")
    return ret
  }()
}
