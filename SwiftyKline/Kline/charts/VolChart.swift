//
//  VolChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class VolChart: BotZeroChart {

  struct Config {
    var neutralColor: UIColor?
    var increaseColor: UIColor?
    var decreaseColor: UIColor?

    var legendColor: UIColor?
  }
  let config: Config

  init(_ list: [KlineModel], _ config: Config) {
    self.config = config
    super.init(list)
    padding_bottom = 0
  }
  override func setup() {
    super.setup()
    dataSets.append(volSet)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    volSet.colors = volColors.compactMap { $0 }
    volSet.removeEntry(index: index)
    if let entry = barEntry(0, index, model) {
      volSet.append(entry)
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = index_vol(list.map({ [$0.volume.dbl ?? 0] }))
    results += [res]
  }

  lazy var volSet: BarChartDataSet = {
    let ret = barSet("vol-bar",
                     list.enumerated().compactMap { barEntry(0, $0.offset, $0.element) },
                     .left,
                     volColors)
    return ret
  }()

  var volColors: [UIColor?] {
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
    let vals = results[0][index] ?? [0]
    let str = Num(vals[0]).scaleDown(decimals) ?? ""
    return [
      NSAttributedString(string: "Vol:\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.legendColor as Any])
    ]
  }

}
