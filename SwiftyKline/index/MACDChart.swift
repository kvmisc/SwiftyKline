//
//  MACDChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class MACDChart: FreeLineChart {

  public var shortp = 12
  public var longp = 26
  public var signalp = 9

  override func setup(_ ls: [KlineData]) {
    macd_res = [[:]]
    macd_short_ema = [[:]]
    macd_long_ema = [[:]]
    macd_signal_ema = [[:]]
    super.setup(ls)
    dataSets.append(contentsOf: macd_line_sets)
    dataSets.append(macd_bar_set)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    macd_line_sets.enumerated().forEach {
      $0.element.removeEntry(index: index)
      if let entry = ChartDataEntry(index.d, macd_res[0][index]?[$0.offset], data) {
        $0.element.append(entry)
      }
    }
    macd_bar_set.colors = datas.map { macd_bar_colors[$0.rnf.i] }
    macd_bar_set.removeEntry(index: index)
    if let entry = BarChartDataEntry(index.d, macd_res[0][index]?[2], data) {
      macd_bar_set.append(entry)
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.close.d ?? 0] }
    macd_calc(0, inputs, shortp, longp, signalp)
  }

  var macd_res: [[Int:[Double]]] = []

  var macd_short_ema: [[Int:[Double]]] = []
  var macd_long_ema: [[Int:[Double]]] = []
  var macd_signal_ema: [[Int:[Double]]] = []

  // https://tulipindicators.org/macd
  //
  // https://medium.com/duedex/what-is-macd-4a43050e2ca8
  // The DIF line is called the MACD line
  // The DEA line is called the Signal line
  // Histogram usually drawn as a bar chart
  //
  // https://www.fmlabs.com/reference/default.htm?url=MACD.htm
  // why 0.15 & 0.075 ?
  func macd_calc(_ n: Int, _ inputs: [[Double]], _ shortp: Int, _ longp: Int, _ signalp: Int) {
    let c = inputs.count
    let b: Int
    if macd_res[n][c-1] == nil {
      let max = macd_res[n].max { $0.key < $1.key }
      b = (max?.key ?? -1) + 1
    } else {
      b = c - 1
    }
    // I don't like this, but it's what people expect.
    let short_per = (shortp == 12 && longp == 26) ? 0.15 : (2 / (shortp + 1).d)
    let long_per = (shortp == 12 && longp == 26) ? 0.075 : (2 / (longp + 1).d)
    let signal_per = 2 / (signalp + 1).d
    var short_ema = macd_short_ema[n][b-1]?[0] ?? 0.0
    var long_ema = macd_long_ema[n][b-1]?[0] ?? 0.0
    var signal_ema = macd_signal_ema[n][b-1]?[0] ?? 0.0
    for i in b..<c {
      let val = inputs[i][0]
      if i == 0 {
        short_ema = val
        long_ema = val
      } else {
        short_ema = (val - short_ema) * short_per + short_ema
        long_ema = (val - long_ema) * long_per + long_ema
        let out = short_ema - long_ema
        if i == longp-1 {
          signal_ema = out
        }
        if i >= longp-1 {
          signal_ema = (out - signal_ema) * signal_per + signal_ema
          let macd = out
          let signal = signal_ema
          let hist = out - signal_ema
          macd_res[n][i] = [macd, signal, hist]
        }
      }
      macd_short_ema[n][i] = [short_ema]
      macd_long_ema[n][i] = [long_ema]
      macd_signal_ema[n][i] = [signal_ema]
    }
  }

  lazy var macd_line_sets: [LineChartDataSet] = {
    let ret = ["dif", "dea"].enumerated().map { it in
      LineChartDataSet("macd-\(it.element)-line",
                       datas.enumerated().compactMap { ChartDataEntry($0.offset.d, macd_res[0][$0.offset]?[it.offset], $0.element) },
                       .left,
                       [macd_line_colors[it.offset]]
      )
    }
    return ret
  }()

  lazy var macd_bar_set: BarChartDataSet = {
    let ret = BarChartDataSet("macd-macd-bar",
                              datas.enumerated().compactMap { BarChartDataEntry($0.offset.d, macd_res[0][$0.offset]?[2], $0.element) },
                              .left,
                              datas.map { macd_bar_colors[$0.rnf.i] }
    )
    return ret
  }()

  var macd_line_colors = [kline_macd_dif_c, kline_macd_dea_c, kline_macd_macd_c]

  var macd_bar_colors = [kline_macd_decrease_c, kline_macd_neutral_c, kline_macd_increase_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let list = ["DIF", "DEA", "MACD"].enumerated().compactMap { it -> NSAttributedString? in
      if let vals = macd_res[0][index],
         let str = f2s(vals[it.offset], decimals)
      {
        return NSAttributedString(string: "\(it.element):\(str)", attributes: [.font: kline_legend_f, .foregroundColor: macd_line_colors[it.offset]])
      } else {
        return nil
      }
    }
    return list
  }
}
