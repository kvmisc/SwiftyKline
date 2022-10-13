//
//  ChartsExt.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

extension ChartDataEntryBase {
  @objc var maxValue: Double { y }
  @objc var minValue: Double { y }
}

extension CandleChartDataEntry {
  override var maxValue: Double { high }
  override var minValue: Double { low }
}


extension ChartBaseDataSet {
  func entriesForXRange(_ lowest: Double?, _ highest: Double?) -> [ChartDataEntry] {
    if let lowest = lowest, let highest = highest, lowest < highest {
      let begin = Int(max(floor(lowest), 0))
      let end = Int(round(highest))
      return (begin...end).compactMap { entryForXValue(Double($0), closestToY: .nan, rounding: .down) }
    }
    return []
  }
}

extension CandleChartDataSet {
  func maxEntry(_ lowest: Double?, _ highest: Double?) -> CandleChartDataEntry? {
    (entriesForXRange(lowest, highest) as? [CandleChartDataEntry])?.max { $0.maxValue < $1.maxValue }
  }
  func minEntry(_ lowest: Double?, _ highest: Double?) -> CandleChartDataEntry? {
    (entriesForXRange(lowest, highest) as? [CandleChartDataEntry])?.min { $0.minValue < $1.minValue }
  }
}

extension BarChartDataSet {
  func maxEntry(_ lowest: Double?, _ highest: Double?) -> BarChartDataEntry? {
    (entriesForXRange(lowest, highest) as? [BarChartDataEntry])?.max { $0.maxValue < $1.maxValue }
  }
  func minEntry(_ lowest: Double?, _ highest: Double?) -> BarChartDataEntry? {
    (entriesForXRange(lowest, highest) as? [BarChartDataEntry])?.min { $0.minValue < $1.minValue }
  }
}

extension LineChartDataSet {
  func maxEntry(_ lowest: Double?, _ highest: Double?) -> ChartDataEntry? {
    entriesForXRange(lowest, highest).max { $0.maxValue < $1.maxValue }
  }
  func minEntry(_ lowest: Double?, _ highest: Double?) -> ChartDataEntry? {
    entriesForXRange(lowest, highest).min { $0.minValue < $1.minValue }
  }
}
