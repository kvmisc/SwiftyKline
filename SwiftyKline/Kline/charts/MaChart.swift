//
//  MaChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class MaChart: RangeChart {

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
    dataSets.append(contentsOf: maLineSets)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    maLineSets.enumerated().forEach { idx, set in
      set.removeEntry(index: index)
      if let entry = lineEntry(1+idx, index, model) {
        set.append(entry)
      }
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = configs.map { index_ma(list.map({ [$0.close.dbl ?? 0] }), $0.period) }
    results += res
  }

  lazy var maLineSets: [LineChartDataSet] = {
    let ret = configs.enumerated().map { idx, config -> LineChartDataSet in
      let set = lineSet("ma\(config.period)-line",
                        list.enumerated().compactMap { lineEntry(1+idx, $0.offset, $0.element) },
                        .right,
                        config.color)
      return set
    }
    return ret
  }()


  override var legendValues: [NSAttributedString] {
    let index = (highlight?.x ?? highestX).int
    return configs.enumerated().compactMap { idx, config -> NSAttributedString? in
      if let vals = results[idx+1][index],
         let str = Num(vals[0]).scaleDown(decimals)
      {
        return NSAttributedString(string: "MA(\(config.period)):\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.color as Any])
      }
      return nil
    }
  }

}
