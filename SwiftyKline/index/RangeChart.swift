//
//  RangeChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class RangeChart: FreeLineChart {

  override func setup(_ ls: [KlineData]) {
    super.setup(ls)
    dataSets.append(range_set)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    range_set.removeEntry(index: index)
    if let entry = CandleChartDataEntry(index.d, range_res[0][index]?[1], range_res[0][index]?[2], range_res[0][index]?[0], range_res[0][index]?[3], data) {
      range_set.append(entry)
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.open.d ?? 0, $0.high.d ?? 0, $0.low.d ?? 0, $0.close.d ?? 0] }
    range_calc(0, inputs)
  }

  var range_res: [[Int:[Double]]] = [[:]]

  func range_calc(_ n: Int, _ inputs: [[Double]]) {
    range_res[n] = inputs.dict_val
  }

  lazy var range_set: CandleChartDataSet = {
    let ret = CandleChartDataSet("range-candle",
                                 datas.enumerated().compactMap { CandleChartDataEntry($0.offset.d, range_res[0][$0.offset]?[1], range_res[0][$0.offset]?[2], range_res[0][$0.offset]?[0], range_res[0][$0.offset]?[3], $0.element) },
                                 .right,
                                 range_colors
    )

    ret.highlightEnabled = true

    return ret
  }()

  public var range_colors = [kline_range_decrease_c, kline_range_neutral_c, kline_range_increase_c]
}
