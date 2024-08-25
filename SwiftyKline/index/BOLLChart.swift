//
//  BOLLChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class BOLLChart: RangeChart {

  public var period = 20
  public var deviations = 2.0

  override func setup(_ ls: [KlineData]) {
    boll_res = [[:]]
    boll_ma_buf = [size_buffer(period)]
    super.setup(ls)
    dataSets.append(contentsOf: boll_sets)
    legendTitle = NSAttributedString(string: "BOLL(\(period),\(deviations.i))", attributes: [.font: kline_legend_f, .foregroundColor: boll_colors[3]])
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    boll_sets.enumerated().forEach {
      $0.element.removeEntry(index: index)
      if let entry = ChartDataEntry(index.d, boll_res[0][index]?[$0.offset], data) {
        $0.element.append(entry)
      }
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.close.d ?? 0] }
    boll_calc(0, inputs, period, deviations)
  }

  var boll_res: [[Int:[Double]]] = []

  var boll_ma_buf: [(Double?)->[Double]] = []

  // https://www.investopedia.com/terms/b/bollingerbands.asp
  func boll_calc(_ n: Int, _ inputs: [[Double]], _ period: Int, _ deviations: Double) {
    let c = inputs.count
    let b: Int
    if boll_res[n][c-1] == nil {
      let max = boll_res[n].max { $0.key < $1.key }
      b = (max?.key ?? -1) + 1
    } else {
      _ = boll_ma_buf[n](nil)
      b = c - 1
    }
    for i in b..<c {
      let val = inputs[i][0]
      let vals = boll_ma_buf[n](val)
      if i >= period-1 {
        let ma = vals.reduce(0, +) / period.d
        var sum = 0.0
        for j in (i+1-period)..<(i+1) {
          sum += pow(inputs[j][0] - ma, 2)
        }
        let sd = sqrt(sum / period.d)
        let mid = ma
        let up = mid + deviations * sd
        let low = mid - deviations * sd
        boll_res[n][i] = [mid, up, low]
      }
    }
  }

  lazy var boll_sets: [LineChartDataSet] = {
    let ret = ["mb", "up", "dn"].enumerated().map { it in
      LineChartDataSet("boll-\(it.element)-line",
                       datas.enumerated().compactMap { ChartDataEntry($0.offset.d, boll_res[0][$0.offset]?[it.offset], $0.element) },
                       .right,
                       [boll_colors[it.offset]]
      )
    }
    return ret
  }()

  public var boll_colors = [kline_boll_mid_line_c, kline_boll_up_line_c, kline_boll_low_line_c, kline_boll_legend_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let list = ["MB", "UP", "DN"].enumerated().compactMap { it -> NSAttributedString? in
      if let vals = boll_res[0][index],
         let str = f2s(vals[it.offset], decimals)
      {
        return NSAttributedString(string: "\(it.element):\(str)", attributes: [.font: kline_legend_f, .foregroundColor: boll_colors[it.offset]])
      } else {
        return nil
      }
    }
    return list
  }
}
