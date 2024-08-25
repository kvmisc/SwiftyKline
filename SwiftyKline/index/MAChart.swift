//
//  MAChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class MAChart: RangeChart {

  public var periods = [7, 25, 99]

  override func setup(_ ls: [KlineData]) {
    ma_res = periods.map { _ in [:] }
    ma_ma_buf = periods.map { size_buffer($0) }
    super.setup(ls)
    dataSets.append(contentsOf: ma_sets)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    ma_sets.enumerated().forEach {
      $0.element.removeEntry(index: index)
      if let entry = ChartDataEntry(index.d, ma_res[$0.offset][index]?[0], data) {
        $0.element.append(entry)
      }
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.close.d ?? 0] }
    periods.enumerated().forEach {
      ma_calc($0.offset, inputs, $0.element)
    }
  }

  var ma_res: [[Int:[Double]]] = []

  var ma_ma_buf: [(Double?)->[Double]] = []

  // https://www.omnicalculator.com/finance/moving-average
  // [1,2,3,4,5,6,7,8,9] 5
  // [        3,4,5,6,7]
  func ma_calc(_ n: Int, _ inputs: [[Double]], _ period: Int) {
    let c = inputs.count
    let b: Int
    if ma_res[n][c-1] == nil {
      let max = ma_res[n].max { $0.key < $1.key }
      b = (max?.key ?? -1) + 1
    } else {
      _ = ma_ma_buf[n](nil)
      b = c - 1
    }
    for i in b..<c {
      let val = inputs[i][0]
      let vals = ma_ma_buf[n](val)
      if i >= period-1 {
        let ma = vals.reduce(0, +) / period.d
        ma_res[n][i] = [ma]
      }
    }
  }

  lazy var ma_sets: [LineChartDataSet] = {
    let ret = periods.enumerated().map { it in
      LineChartDataSet("ma-\(it.element)-line",
                       datas.enumerated().compactMap { ChartDataEntry($0.offset.d, ma_res[it.offset][$0.offset]?[0], $0.element) },
                       .right,
                       [ma_colors[it.offset]]
      )
    }
    return ret
  }()

  public var ma_colors = [kline_ma_line_1_c, kline_ma_line_2_c, kline_ma_line_3_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let list = periods.enumerated().compactMap { it -> NSAttributedString? in
      if let vals = ma_res[it.offset][index],
         let str = f2s(vals[0], decimals)
      {
        return NSAttributedString(string: "MA(\(it.element)):\(str)", attributes: [.font: kline_legend_f, .foregroundColor: ma_colors[it.offset]])
      } else {
        return nil
      }
    }
    return list
  }
}
