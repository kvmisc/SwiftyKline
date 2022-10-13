//
//  KdjChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class KdjChart: FreeZeroChart {

  struct Config {
    var kperiod: Int
    var kslow: Int
    var dperiod: Int

    var kColor: UIColor?
    var dColor: UIColor?
    var jColor: UIColor?
    var colors: [UIColor] {
      [
        kColor,
        dColor,
        jColor,
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
    dataSets.append(contentsOf: kdjLineSets)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    kdjLineSets.enumerated().forEach { idx, set in
      set.removeEntry(index: index)
      if let entry = lineEntry(idx, index, model) {
        set.append(entry)
      }
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = index_kdj(list.map({ [$0.high.dbl ?? 0, $0.low.dbl ?? 0, $0.close.dbl ?? 0] }), config.kperiod, config.kslow, config.dperiod)
    let splited = (0..<3).map { idx in
      res.mapValues { [$0[idx]] }
    }
    results += splited
  }

  lazy var kdjLineSets: [LineChartDataSet] = {
    let ret = (0..<3).map { idx -> LineChartDataSet in
      let set = lineSet("kdj\(idx)-line",
                        list.enumerated().compactMap { lineEntry(idx, $0.offset, $0.element) },
                        .left,
                        config.colors.at(idx))
      return set
    }
    return ret
  }()


  override var legendValues: [NSAttributedString] {
    let index = (highlight?.x ?? highestX).int
    return ["K", "D", "J"].enumerated().compactMap { idx, title -> NSAttributedString? in
      if let vals = results[idx][index],
         let str = Num(vals[0]).scaleDown(decimals)
      {
        return NSAttributedString(string: "\(title):\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.colors.at(idx) as Any])
      }
      return nil
    }
  }

}
