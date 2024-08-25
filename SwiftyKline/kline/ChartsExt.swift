//
//  ChartsExt.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

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


extension ChartDataEntry {
  convenience init?(_ x: Double?, _ y: Double?, _ data: Any?) {
    if let x = x, let y = y {
      self.init(x: x, y: y, data: data)
    } else {
      return nil
    }
  }
}

extension CandleChartDataEntry {
  convenience init?(_ x: Double?, _ h: Double?, _ l: Double?, _ o: Double?, _ c: Double?, _ data: Any?) {
    if let x = x, let h = h, let l = l, let o = o, let c = c {
      self.init(x: x, shadowH: h, shadowL: l, open: o, close: c, data: data)
    } else {
      return nil
    }
  }
}


extension LineChartDataSet {
  convenience init(_ label: String,
                   _ entries: [ChartDataEntry],
                   _ dependency: YAxis.AxisDependency,
                   _ color: [UIColor]
  ) {
    self.init(entries: entries, label: label)

    axisDependency = dependency
    colors = color

    highlightEnabled = false
    //highlightLineWidth = 0.5
    highlightColor = kline_highlight_line_c
    form = .none
    drawValuesEnabled = false
    drawIconsEnabled = false


    //fillAlpha = 0.33
    //fillColor
    drawFilledEnabled = false

    //lineWidth = 1

    //mode = .linear
    drawCirclesEnabled = false
    drawCircleHoleEnabled = false
  }
}

extension BarChartDataSet {
  convenience init(_ label: String,
                   _ entries: [BarChartDataEntry],
                   _ dependency: YAxis.AxisDependency,
                   _ color: [UIColor]
  ) {
    self.init(entries: entries, label: label)

    axisDependency = dependency
    colors = color

    highlightEnabled = false
    //highlightLineWidth = 0.5
    highlightColor = kline_highlight_line_c
    form = .none
    drawValuesEnabled = false
    drawIconsEnabled = false


    //highlightAlpha = 120/255.0
  }
}

extension CandleChartDataSet {
  convenience init(_ label: String,
                   _ entries: [CandleChartDataEntry],
                   _ dependency: YAxis.AxisDependency,
                   _ color: [UIColor]
  ) {
    self.init(entries: entries, label: label)

    axisDependency = dependency
    //colors = []

    highlightEnabled = false
    //highlightLineWidth = 0.5
    highlightColor = kline_highlight_line_c
    form = .none
    drawValuesEnabled = false
    drawIconsEnabled = false


    //barSpace = 0.1

    //shadowWidth = 1.5
    shadowColorSameAsCandle = true

    decreasingColor = color[0]
    neutralColor = color[1]
    increasingColor = color[2]
    increasingFilled = true
    decreasingFilled = true
  }
}
