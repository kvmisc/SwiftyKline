//
//  KlineChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class KlineChart {

  public init() { }

  var datas: [KlineData] = []

  func setup(_ ls: [KlineData]) {
    datas = ls
    calculate()
  }

  func add(_ index: Int, _ data: KlineData) {
    if index < 0 {
      // ...
    } else if index < datas.count {
      datas[index] = data
    } else if index == datas.count {
      datas.append(data)
    } else {
      // ...
    }
    calculate()
  }


  // MARK: Results

  public var decimals: Int?

  func calculate() {

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

  // for legend calculation
  var selected: Highlight?


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
    guard let top = minaxTop else { return nil }
    guard let bot = minaxBot else { return nil }
    if let data = datas.last {
      let point = CGPoint(x: (datas.count - 1).d,
                          y: data.close.d ?? 0)
      if top.y >= point.y && point.y >= bot.y {
        return point
      }
    }
    return nil
  }


  // MARK: Minax

  var minaxTop: CGPoint? {
    if let entry = candleDataSets.compactMap({ $0.maxEntry(lowestX, highestX) }).max(by: { $0.maxValue < $1.maxValue }) {
      return CGPoint(x: entry.x, y: entry.maxValue)
    }
    return nil
  }

  var minaxBot: CGPoint? {
    if let entry = candleDataSets.compactMap({ $0.minEntry(lowestX, highestX) }).min(by: { $0.minValue < $1.minValue }) {
      return CGPoint(x: entry.x, y: entry.minValue)
    }
    return nil
  }


  // MARK: Legend

  var legend: NSAttributedString {
    ([legendTitle] + legendValues)
      .compactMap { $0 }
      .reduce(NSMutableAttributedString()) {
        if $0.length > 0 {
          $0.append(NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: 8, weight: .regular), .kern: 4-3]))
        }
        $0.append($1)
        return $0
      }
  }
  var legendTitle: NSAttributedString?
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

public class FreeLineChart: KlineChart { // 0 刻度线自由
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

public class MidLineChart: KlineChart { // 0 刻度线中间
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

public class BotLineChart: KlineChart { // 0 刻度线底部
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
