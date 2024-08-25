//
//  EMAChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class EMAChart: RangeChart {

  public var periods = [7, 25, 99]

  override func setup(_ ls: [KlineData]) {
    ema_res = periods.map { _ in [:] }
    super.setup(ls)
    dataSets.append(contentsOf: ema_sets)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    ema_sets.enumerated().forEach {
      $0.element.removeEntry(index: index)
      if let entry = ChartDataEntry(index.d, ema_res[$0.offset][index]?[0], data) {
        $0.element.append(entry)
      }
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.close.d ?? 0] }
    periods.enumerated().forEach {
      ema_calc($0.offset, inputs, $0.element)
    }
  }

  var ema_res: [[Int:[Double]]] = []

  // https://tulipindicators.org/ema
  // https://www.statology.org/excel-exponential-moving-average/
  // [25, 20, 14, 16, 27, 20, 12, 15, 14, 19] 3
  // [25, 22.5, 18.25, 17.13, 22.06, 21.03, 16.52, 15.76, 14.88, 16.94]
  func ema_calc(_ n: Int, _ inputs: [[Double]], _ period: Int) {
    let c = inputs.count
    let b: Int
    if ema_res[n][c-1] == nil {
      let max = ema_res[n].max { $0.key < $1.key }
      b = (max?.key ?? -1) + 1
    } else {
      b = c - 1
    }
    let per = 2 / (period + 1).d
    var ema = ema_res[n][b-1]?[0] ?? 0.0
    for i in b..<c {
      let val = inputs[i][0]
      if i == 0 {
        ema = val
      } else {
        ema = (val - ema) * per + ema
      }
      ema_res[n][i] = [ema]
    }
  }

  lazy var ema_sets: [LineChartDataSet] = {
    let ret = periods.enumerated().map { it in
      LineChartDataSet("ema-\(it.element)-line",
                       datas.enumerated().compactMap { ChartDataEntry($0.offset.d, ema_res[it.offset][$0.offset]?[0], $0.element) },
                       .right,
                       [ema_colors[it.offset]]
      )
    }
    return ret
  }()

  public var ema_colors = [kline_ema7_line_c, kline_ema25_line_c, kline_ema99_line_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let list = periods.enumerated().compactMap { it -> NSAttributedString? in
      if let vals = ema_res[it.offset][index],
         let str = f2s(vals[0], decimals)
      {
        return NSAttributedString(string: "EMA(\(it.element)):\(str)", attributes: [.font: kline_legend_f, .foregroundColor: ema_colors[it.offset]])
      } else {
        return nil
      }
    }
    return list
  }
}
