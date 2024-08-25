//
//  VOLChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class VOLChart: BotLineChart {

  override func setup(_ ls: [KlineData]) {
    super.setup(ls)
    dataSets.append(vol_set)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    vol_set.colors = datas.map { vol_colors[$0.rnf.i] }
    vol_set.removeEntry(index: index)
    if let entry = BarChartDataEntry(index.d, vol_res[0][index]?[0], data) {
      vol_set.append(entry)
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.volume.d ?? 0] }
    vol_calc(0, inputs)
  }

  var vol_res: [[Int:[Double]]] = [[:]]

  func vol_calc(_ n: Int, _ inputs: [[Double]]) {
    vol_res[n] = inputs.dict_val
  }

  lazy var vol_set: BarChartDataSet = {
    let ret = BarChartDataSet("vol-bar",
                              datas.enumerated().compactMap { BarChartDataEntry($0.offset.d, vol_res[0][$0.offset]?[0], $0.element) },
                              .left,
                              datas.map { vol_colors[$0.rnf.i] }
    )
    return ret
  }()

  public var vol_colors = [kline_vol_decrease_c, kline_vol_neutral_c, kline_vol_increase_c, kline_vol_legend_c]


  override var legendValues: [NSAttributedString] {
    let index = (selected?.x ?? highestX).i
    let vals = vol_res[0][index] ?? [0]
    let str = f2s(vals[0], decimals) ?? ""
    return [
      NSAttributedString(string: "Vol:\(str)", attributes: [.font: kline_legend_f, .foregroundColor: vol_colors[3]])
    ]
  }
}
