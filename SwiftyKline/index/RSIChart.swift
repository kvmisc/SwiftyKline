//
//  RSIChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class RSIChart: FreeLineChart {

  public var periods = [6, 12, 24]

  override func setup(_ ls: [KlineData]) {
    rsi_res = periods.map { _ in [:] }
    rsi_up_buf = periods.map { size_buffer($0) }
    rsi_dn_buf = periods.map { size_buffer($0) }
    super.setup(ls)
    dataSets.append(contentsOf: rsi_sets)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    rsi_sets.enumerated().forEach {
      $0.element.removeEntry(index: index)
      if let entry = ChartDataEntry(index.d, rsi_res[$0.offset][index]?[0], data) {
        $0.element.append(entry)
      }
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.close.d ?? 0] }
    periods.enumerated().forEach {
      rsi_calc($0.offset, inputs, $0.element)
    }
  }

  var rsi_res: [[Int:[Double]]] = []

  var rsi_up_buf: [(Double?)->[Double]] = []
  var rsi_dn_buf: [(Double?)->[Double]] = []

  // https://www.omnicalculator.com/finance/rsi
  func rsi_calc(_ n: Int, _ inputs: [[Double]], _ period: Int) {
    let c = inputs.count
    let b: Int
    if rsi_res[n][c-1] == nil {
      let max = rsi_res[n].max { $0.key < $1.key }
      b = (max?.key ?? 0) + 1 // loop begin from 1
    } else {
      _ = rsi_up_buf[n](nil)
      _ = rsi_dn_buf[n](nil)
      b = c - 1
    }
    for i in b..<c {
      let valp = inputs[i-1][0]
      let valn = inputs[i][0]
      let upward = valn > valp ? valn - valp : 0
      let downward = valn < valp ? valp - valn : 0
      let upwards = rsi_up_buf[n](upward)
      let downwards = rsi_dn_buf[n](downward)
      if i >= period {
        let up_smooth = upwards.reduce(0, +) / period.d
        let down_smooth = downwards.reduce(0, +) / period.d
        let rsi = 100 - 100 / (1 + up_smooth / down_smooth)
        rsi_res[n][i] = [rsi]
      }
    }
  }

  lazy var rsi_sets: [LineChartDataSet] = {
    let ret = periods.enumerated().map { it in
      LineChartDataSet("rsi-\(it.element)-line",
                       datas.enumerated().compactMap { ChartDataEntry($0.offset.d, rsi_res[it.offset][$0.offset]?[0], $0.element) },
                       .left,
                       [rsi_colors[it.offset]]
      )
    }
    return ret
  }()

  public var rsi_colors = [kline_rsi6_line_c, kline_rsi12_line_c, kline_rsi24_line_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let list = periods.enumerated().compactMap { it -> NSAttributedString? in
      if let vals = rsi_res[it.offset][index],
         let str = f2s(vals[0], decimals)
      {
        return NSAttributedString(string: "RSI(\(it.element)):\(str)", attributes: [.font: kline_legend_f, .foregroundColor: rsi_colors[it.offset]])
      } else {
        return nil
      }
    }
    return list
  }
}
