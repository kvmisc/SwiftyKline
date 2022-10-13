//
//  KlineView_Formatter.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

extension KlineView {

  class IndexFormatter: AxisValueFormatter {

    var timestamps: [Double] = []

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

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      format(timestamps.at(Int(value)))
      // value.str.zeroTrimmed()
    }

    func format(_ timestamp: Double?) -> String {
      if let timestamp = timestamp,
         let date = Date.fromTimestamp(timestamp)
      {
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
          return today.string(from: date)
        } else {
          return ago.string(from: date)
        }
      } else {
        return ""
      }
    }
  }

}
