//
//  MacdChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class MacdChart: FreeZeroChart {

  struct Config {
    var shortPeriod: Int
    var longPeriod: Int
    var signalPeriod: Int

    var difColor: UIColor?
    var deaColor: UIColor?
    var macdColor: UIColor? // used by lengend
    var colors: [UIColor] {
      [
        difColor,
        deaColor,
        macdColor,
      ].compactMap { $0 }
    }

    var neutralColor: UIColor?
    var increaseColor: UIColor?
    var decreaseColor: UIColor?
  }
  let config: Config

  init(_ list: [KlineModel], _ config: Config) {
    self.config = config
    super.init(list)
  }
  override func setup() {
    super.setup()
    dataSets.append(contentsOf: macdLineSets)
    dataSets.append(macdBarSet)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    macdLineSets.enumerated().forEach { idx, set in
      set.removeEntry(index: index)
      if let entry = lineEntry(idx, index, model) {
        set.append(entry)
      }
    }

    macdBarSet.colors = macdBarColors.compactMap { $0 }
    macdBarSet.removeEntry(index: index)
    if let entry = barEntry(2, index, model) {
      macdBarSet.append(entry)
    }
  }

  override func reloadResults() {
    super.reloadResults()
    let res = index_macd(list.map({ [$0.close.dbl ?? 0] }), config.shortPeriod, config.longPeriod, config.signalPeriod)
    let splited = (0..<3).map { idx in
      res.mapValues { [$0[idx]] }
    }
    results += splited
  }

  lazy var macdLineSets: [LineChartDataSet] = {
    let ret = (0..<2).map { idx -> LineChartDataSet in
      let set = lineSet("macd\(idx)-line",
                        list.enumerated().compactMap { lineEntry(idx, $0.offset, $0.element) },
                        .left,
                        config.colors.at(idx))
      return set
    }
    return ret
  }()

  lazy var macdBarSet: BarChartDataSet = {
    let ret = barSet("macd-bar",
                     list.enumerated().compactMap { barEntry(2, $0.offset, $0.element) },
                     .left,
                     macdBarColors)
    return ret
  }()

  var macdBarColors: [UIColor?] {
    list.map { item -> UIColor? in
      if item.isIncrease {
        return config.increaseColor
      } else if item.isDecrease {
        return config.decreaseColor
      } else {
        return config.neutralColor
      }
    }
  }


  override var legendValues: [NSAttributedString] {
    let index = (highlight?.x ?? highestX).int
    return ["DIF", "DEA", "MACD"].enumerated().compactMap { idx, title -> NSAttributedString? in
      if let vals = results[idx][index],
         let str = Num(vals[0]).scaleDown(decimals)
      {
        return NSAttributedString(string: "\(title):\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.colors.at(idx) as Any])
      }
      return nil
    }
  }

}
