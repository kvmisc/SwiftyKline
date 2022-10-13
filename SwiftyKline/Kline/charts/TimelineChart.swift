//
//  TimelineChart.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

class TimelineChart: FreeZeroChart {

  override init(_ list: [KlineModel]) {
    super.init(list)
  }
  override func setup() {
    super.setup()
    dataSets.append(timelineSet)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    timelineSet.removeEntry(index: index)
    if let entry = lineEntry(0, index, model) {
      timelineSet.append(entry)
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = index_timeline(list.map({ [$0.close.dbl ?? 0] }))
    results += [res]
  }

  lazy var timelineSet: LineChartDataSet = {
    let ret = lineSet("timeline-line",
                      list.enumerated().compactMap { lineEntry(0, $0.offset, $0.element) },
                      .right,
                      .kline_timeline_line)

    ret.highlightEnabled = true

    let gradient_colors = [UIColor.white, UIColor.kline_timeline_fill].compactMap { $0?.cgColor }
    if let gradient = CGGradient(colorsSpace: nil, colors: gradient_colors as CFArray, locations: [0.25, 1.0]) {
      ret.fill = LinearGradientFill(gradient: gradient, angle: 90)
    }
    ret.drawFilledEnabled = true

    return ret
  }()

}
