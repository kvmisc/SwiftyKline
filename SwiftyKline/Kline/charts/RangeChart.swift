//
//  RangeChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class RangeChart: FreeZeroChart {

  override init(_ list: [KlineModel]) {
    super.init(list)
  }
  override func setup() {
    super.setup()
    dataSets.append(rangeSet)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    rangeSet.removeEntry(index: index)
    if let entry = candleEntry(0, index, model) {
      rangeSet.append(entry)
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = index_range(list.map({ [$0.open.dbl ?? 0, $0.high.dbl ?? 0, $0.low.dbl ?? 0, $0.close.dbl ?? 0] }))
    results += [res]
  }

  lazy var rangeSet: CandleChartDataSet = {
    let ret = candleSet("range-candle",
                        list.enumerated().compactMap { candleEntry(0, $0.offset, $0.element) },
                        .right,
                        [.kline_range_neutral, .kline_range_increase, .kline_range_decrease])

    ret.highlightEnabled = true

    return ret
  }()

}
