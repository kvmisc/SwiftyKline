//
//  KDJChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class KDJChart: FreeLineChart {

  public var kperiod = 9
  public var kslow = 3
  public var dperiod = 3

  override func setup(_ ls: [KlineData]) {
    kdj_res = [[:]]
    kdj_max_buf = [size_buffer(kperiod)]
    kdj_min_buf = [size_buffer(kperiod)]
    kdj_kfast_buf = [size_buffer(kslow)]
    kdj_k_buf = [size_buffer(dperiod)]
    super.setup(ls)
    dataSets.append(contentsOf: kdj_sets)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    kdj_sets.enumerated().forEach {
      $0.element.removeEntry(index: index)
      if let entry = ChartDataEntry(index.d, kdj_res[0][index]?[$0.offset], data) {
        $0.element.append(entry)
      }
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.high.d ?? 0, $0.low.d ?? 0, $0.close.d ?? 0] }
    kdj_calc(0, inputs, kperiod, kslow, dperiod)
  }

  var kdj_res: [[Int:[Double]]] = []

  var kdj_max_buf: [(Double?)->[Double]] = []
  var kdj_min_buf: [(Double?)->[Double]] = []
  var kdj_kfast_buf: [(Double?)->[Double]] = []
  var kdj_k_buf: [(Double?)->[Double]] = []

  // https://tulipindicators.org/stoch
  func kdj_calc(_ n: Int, _ inputs: [[Double]], _ kperiod: Int, _ kslow: Int, _ dperiod: Int) {
    let c = inputs.count
    let b: Int
    if kdj_res[n][c-1] == nil {
      let max = kdj_res[n].max { $0.key < $1.key }
      b = (max?.key ?? -1) + 1
    } else {
      _ = kdj_max_buf[n](nil)
      _ = kdj_min_buf[n](nil)
      _ = kdj_kfast_buf[n](nil)
      _ = kdj_k_buf[n](nil)
      b = c - 1
    }
    let kper = 1 / kslow.d
    let dper = 1 / dperiod.d
    for i in b..<c {
      let high = inputs[i][0]
      let low = inputs[i][1]
      let close = inputs[i][2]
      let maxs = kdj_max_buf[n](high)
      let mins = kdj_min_buf[n](low)
      // 0...8, 9 max/min enqueue, then go inside
      if i >= kperiod-1 {
        let max = maxs.max() ?? 0
        let min = mins.min() ?? 0
        let kdiff = max - min
        let kfast = kdiff == 0 ? 0 : 100 * ((close - min) / kdiff)
        let kfasts = kdj_kfast_buf[n](kfast)
        // 8...10, 3 kfast enqueue, then go inside
        if i >= kperiod-1 + kslow-1 {
          let k = kfasts.reduce(0, +) * kper
          let ks = kdj_k_buf[n](k)
          // 10...12, 3 k enqueue, then go inside
          if i >= kperiod-1 + kslow-1 + dperiod-1 {
            let d = ks.reduce(0, +) * dper
            // I don't know what does 3 and 2 means. Maybe people think 9,3,3 is fix parameters and won't change in the future.
            // So they said j value formula is `k * 3 - d * 2`.
            let j = k * 3 - d * 2
            kdj_res[n][i] = [k, d, j]
          }
        }
      }
    }
  }

  lazy var kdj_sets: [LineChartDataSet] = {
    let ret = ["k", "d", "j"].enumerated().map { it in
      LineChartDataSet("kdj-\(it.element)-line",
                       datas.enumerated().compactMap { ChartDataEntry($0.offset.d, kdj_res[0][$0.offset]?[it.offset], $0.element) },
                       .left,
                       [kdj_colors[it.offset]]
      )
    }
    return ret
  }()

  public var kdj_colors = [kline_kdj_k_line_c, kline_kdj_d_line_c, kline_kdj_j_line_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let list = ["K", "D", "J"].enumerated().compactMap { it -> NSAttributedString? in
      if let vals = kdj_res[0][index],
         let str = f2s(vals[it.offset], decimals)
      {
        return NSAttributedString(string: "\(it.element):\(str)", attributes: [.font: kline_legend_f, .foregroundColor: kdj_colors[it.offset]])
      } else {
        return nil
      }
    }
    return list
  }
}
