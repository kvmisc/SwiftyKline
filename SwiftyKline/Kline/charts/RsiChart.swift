//
//  RsiChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class RsiChart: FreeZeroChart {

  struct Config {
    var period: Int
    var color: UIColor?
  }
  let configs: [Config]

  init(_ list: [KlineModel], _ configs: [Config]) {
    self.configs = configs
    super.init(list)
  }
  override func setup() {
    super.setup()
    dataSets.append(contentsOf: rsiLineSets)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    rsiLineSets.enumerated().forEach { idx, set in
      set.removeEntry(index: index)
      if let entry = lineEntry(idx, index, model) {
        set.append(entry)
      }
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = configs.map { index_rsi(list.map({ [$0.close.dbl ?? 0] }), $0.period) }
    results += res
  }

  lazy var rsiLineSets: [LineChartDataSet] = {
    let ret = configs.enumerated().map { idx, config -> LineChartDataSet in
      let set = lineSet("rsi\(config.period)-line",
                        list.enumerated().compactMap { lineEntry(idx, $0.offset, $0.element) },
                        .left,
                        config.color)
      return set
    }
    return ret
  }()


  override var legendValues: [NSAttributedString] {
    let index = (highlight?.x ?? highestX).int
    return configs.enumerated().compactMap { idx, config -> NSAttributedString? in
      if let vals = results[idx][index],
         let str = Num(vals[0]).scaleDown(decimals)
      {
        return NSAttributedString(string: "RSI(\(config.period)):\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.color as Any])
      }
      return nil
    }
  }

}
