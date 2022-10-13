//
//  KlineChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class KlineChart {
  var list: [KlineModel]
  init(_ list: [KlineModel]) {
    self.list = list
    setup()
  }
  func setup() {
    reloadResults()
  }
  func add(_ index: Int, _ model: KlineModel) {
    list.update(index, model)
    reloadResults()
  }


  // MARK: Results

  var results: [[Int:[Double]]] = []

  func reloadResults() {
      results = []
  }

  var decimals: Int?


  // MARK: Create Entry

  func lineEntry(_ idx: Int, _ index: Int, _ model: KlineModel) -> ChartDataEntry? {
    if let vals = results[idx][index] {
      return ChartDataEntry(x: index.dbl, y: vals[0], data: model)
    } else {
      return nil
    }
  }

  func barEntry(_ idx: Int, _ index: Int, _ model: KlineModel) -> BarChartDataEntry? {
    if let vals = results[idx][index] {
      return BarChartDataEntry(x: index.dbl, y: vals[0], data: model)
    } else {
      return nil
    }
  }

  func candleEntry(_ idx: Int, _ index: Int, _ model: KlineModel) -> CandleChartDataEntry? {
    if let vals = results[idx][index] {
      return CandleChartDataEntry(x: index.dbl, shadowH: vals[1], shadowL: vals[2], open: vals[0], close: vals[3], data: model)
    } else {
      return nil
    }
  }


  // MARK: Create Set

  func lineSet(_ label: String,
               _ entries: [ChartDataEntry],
               _ dependency: YAxis.AxisDependency,
               _ color: UIColor?
  ) -> LineChartDataSet {
    let ret = LineChartDataSet(entries: entries, label: label)
    ret.axisDependency = dependency
    ret.colors = [color].compactMap { $0 }

    ret.highlightEnabled = false
    //ret.highlightLineWidth = 0.5
    if let color = UIColor.kline_highlight_line {
      ret.highlightColor = color
    }
    ret.form = .none
    ret.drawValuesEnabled = false
    ret.drawIconsEnabled = false


    //ret.fillAlpha = 0.33
    //ret.fillColor
    ret.drawFilledEnabled = false

    //ret.lineWidth = 1

    //ret.mode = .linear
    ret.drawCirclesEnabled = false
    ret.drawCircleHoleEnabled = false

    return ret
  }

  func barSet(_ label: String,
              _ entries: [BarChartDataEntry],
              _ dependency: YAxis.AxisDependency,
              _ colors: [UIColor?]
  ) -> BarChartDataSet {
    let ret = BarChartDataSet(entries: entries, label: label)
    ret.axisDependency = dependency
    ret.colors = colors.compactMap { $0 }

    ret.highlightEnabled = false
    //ret.highlightLineWidth = 0.5
    if let color = UIColor.kline_highlight_line {
      ret.highlightColor = color
    }
    ret.form = .none
    ret.drawValuesEnabled = false
    ret.drawIconsEnabled = false


    //ret.highlightAlpha = 120/255.0

    return ret
  }

  func candleSet(_ label: String,
                 _ entries: [CandleChartDataEntry],
                 _ dependency: YAxis.AxisDependency,
                 _ colors: [UIColor?]
  ) -> CandleChartDataSet {
    let ret = CandleChartDataSet(entries: entries, label: label)
    ret.axisDependency = dependency
    //ret.colors = []

    ret.highlightEnabled = false
    //ret.highlightLineWidth = 0.5
    if let color = UIColor.kline_highlight_line {
      ret.highlightColor = color
    }
    ret.form = .none
    ret.drawValuesEnabled = false
    ret.drawIconsEnabled = false


    //ret.barSpace = 0.1

    //ret.shadowWidth = 1.5
    ret.shadowColorSameAsCandle = true

    ret.neutralColor = colors[0]
    ret.increasingColor = colors[1]
    ret.decreasingColor = colors[2]
    ret.increasingFilled = true
    ret.decreasingFilled = true

    return ret
  }


  // MARK: Data Set

  var dataSets: [ChartDataSet] = []
  var candleDataSets: [CandleChartDataSet] {
    dataSets.compactMap { $0 as? CandleChartDataSet }
  }
  var barDataSets: [BarChartDataSet] {
    dataSets.compactMap { $0 as? BarChartDataSet }
  }
  var lineDataSets: [LineChartDataSet] {
    dataSets.compactMap { $0 as? LineChartDataSet }
  }


  // MARK: Input Params

  var padding_top = 10.0
  var padding_bottom = 10.0
  var margin_top = 0.0
  var margin_bottom = 0.0
  var height = 0.0

  var lowestX = 0.0
  var highestX = 0.0

  var highlight: Highlight?


  // MARK: Y Axis

  var maxY: Double? { nil }
  var minY: Double? { nil }

  var maxEntry: ChartDataEntry? {
    [
      candleDataSets.compactMap({ $0.maxEntry(lowestX, highestX) }).max(by: { $0.maxValue < $1.maxValue }),
      barDataSets.compactMap({ $0.maxEntry(lowestX, highestX) }).max(by: { $0.maxValue < $1.maxValue }),
      lineDataSets.compactMap({ $0.maxEntry(lowestX, highestX) }).max(by: { $0.maxValue < $1.maxValue }),
    ]
      .compactMap { $0 }
      .max { $0.maxValue < $1.maxValue }
  }
  var minEntry: ChartDataEntry? {
    [
      candleDataSets.compactMap({ $0.minEntry(lowestX, highestX) }).min(by: { $0.minValue < $1.minValue }),
      barDataSets.compactMap({ $0.minEntry(lowestX, highestX) }).min(by: { $0.minValue < $1.minValue }),
      lineDataSets.compactMap({ $0.minEntry(lowestX, highestX) }).min(by: { $0.minValue < $1.minValue }),
    ]
      .compactMap { $0 }
      .min { $0.minValue < $1.minValue }
  }


  // MARK: Current

  var current: CGPoint? {
    guard let top = markTop else { return nil }
    guard let bottom = markBottom else { return nil }
    if let model = list.last {
      let point = CGPoint(x: (list.count - 1).dbl,
                          y: model.close.dbl ?? 0)
      if top.y >= point.y && point.y >= bottom.y {
        return point
      }
    }
    return nil
  }


  // MARK: Mark

  var markTop: CGPoint? {
    if let entry = candleDataSets.compactMap({ $0.maxEntry(lowestX, highestX) }).max(by: { $0.maxValue < $1.maxValue }) {
      return CGPoint(x: entry.x, y: entry.maxValue)
    }
    return nil
  }

  var markBottom: CGPoint? {
    if let entry = candleDataSets.compactMap({ $0.minEntry(lowestX, highestX) }).min(by: { $0.minValue < $1.minValue }) {
      return CGPoint(x: entry.x, y: entry.minValue)
    }
    return nil
  }


  // MARK: Legend

  var legend: NSAttributedString {
    let str = NSMutableAttributedString()

    if let legendTitle = legendTitle, !legendTitle.isEmpty {
      let title = NSAttributedString(string: legendTitle, attributes: [.font: UIFont.kline_legend, .foregroundColor: UIColor.kline_legend as Any])
      str.append(title)
    }

    let value = legendValues.reduce(NSMutableAttributedString()) {
      if $0.length > 0 {
        let sep = NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: 8, weight: .regular), .kern: 4-3])
        $0.append(sep)
      }
      $0.append($1)
      return $0
    }
    if value.length > 0 {
      if str.length > 0 {
        let sep = NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: 8, weight: .regular), .kern: 4-3])
        str.append(sep)
      }
      str.append(value)
    }

    return str
  }
  var legendTitle: String?
  var legendValues: [NSAttributedString] { [] }
}


// primary:
//   margin_top = 0
//   padding_top = 10
//   padding_bottom = 10
//   margin_bottom = segment_height
//   height = segment_height * segment_count
//
// secondary:
//   margin_top = segment_height * (segment_count -1)
//   padding_top = 10
//   padding_bottom = 10
//   margin_bottom = 0
//   height = segment_height * segment_count

class FreeZeroChart: KlineChart { // 0 刻度线自由
  override var maxY: Double? {
    if let high = maxEntry, let low = minEntry {
      let range = high.maxValue - low.minValue
      let ratio = range / (height - margin_top - padding_top - padding_bottom - margin_bottom)
      return high.maxValue + (padding_top + margin_top) * ratio
    }
    return nil
  }
  override var minY: Double? {
    if let high = maxEntry, let low = minEntry {
      let range = high.maxValue - low.minValue
      let ratio = range / (height - margin_top - padding_top - padding_bottom - margin_bottom)
      return low.minValue - (padding_bottom + margin_bottom) * ratio
    }
    return nil
  }
}

class MidZeroChart: KlineChart { // 0 刻度线中间
  override var maxY: Double? {
    if let high = maxEntry, let low = minEntry {
      let max = max(abs(high.maxValue), abs(low.minValue))
      let range = max * 2
      let ratio = range / (height - margin_top - padding_top - padding_bottom - margin_bottom)
      return max + (padding_top + margin_top) * ratio
    }
    return nil
  }
  override var minY: Double? {
    if let high = maxEntry, let low = minEntry {
      let max = max(abs(high.maxValue), abs(low.minValue))
      let range = max * 2
      let ratio = range / (height - margin_top - padding_top - padding_bottom - margin_bottom)
      return 0 - max - (padding_bottom + margin_bottom) * ratio
    }
    return nil
  }
}

class BotZeroChart: KlineChart { // 0 刻度线底部
  override var maxY: Double? {
    if let high = maxEntry {
      let range = high.maxValue - 0
      let ratio = range / (height - margin_top - padding_top - padding_bottom - margin_bottom)
      return high.maxValue + (padding_top + margin_top) * ratio
    }
    return nil
  }
  override var minY: Double? {
    if let high = maxEntry {
      let range = high.maxValue - 0
      let ratio = range / (height - margin_top - padding_top - padding_bottom - margin_bottom)
      return 0 - (padding_bottom + margin_bottom) * ratio
    }
    return nil
  }
}
