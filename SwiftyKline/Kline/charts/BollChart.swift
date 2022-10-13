//
//  BollChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class BollChart: RangeChart {

  struct Config {
    var period: Int
    var deviations: Double

    var midColor: UIColor?
    var upColor: UIColor?
    var lowColor: UIColor?
    var colors: [UIColor] {
      [
        midColor,
        upColor,
        lowColor,
      ].compactMap { $0 }
    }
  }
  let config: Config

  init(_ list: [KlineModel], _ config: Config) {
    self.config = config
    super.init(list)
  }
  override func setup() {
    super.setup()
    dataSets.append(contentsOf: bollLineSets)
    legendTitle = "BOLL(\(config.period),\(config.deviations.int))"
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    bollLineSets.enumerated().forEach { idx, set in
      set.removeEntry(index: index)
      if let entry = lineEntry(1+idx, index, model) {
        set.append(entry)
      }
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = index_boll(list.map({ [$0.close.dbl ?? 0] }), config.period, config.deviations)
    let splited = (0..<3).map { idx in
      res.mapValues { [$0[idx]] }
    }
    results += splited
  }

  lazy var bollLineSets: [LineChartDataSet] = {
    let ret = (0..<3).map { idx -> LineChartDataSet in
      let set = lineSet("boll\(idx)-line",
                        list.enumerated().compactMap { lineEntry(1+idx, $0.offset, $0.element) },
                        .right,
                        config.colors.at(idx))
      return set
    }
    return ret
  }()


  override var legendValues: [NSAttributedString] {
    let index = (highlight?.x ?? highestX).int
    return ["UP", "MB", "DN"].enumerated().compactMap { idx, title -> NSAttributedString? in
      if let vals = results[idx+1][index],
         let str = Num(vals[0]).scaleDown(decimals)
      {
        return NSAttributedString(string: "\(title):\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.colors.at(idx) as Any])
      }
      return nil
    }
  }

}
