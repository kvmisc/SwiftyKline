//
//  TimelineChart.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit
import DGCharts

public class TimelineChart: FreeLineChart {

  override func setup(_ ls: [KlineData]) {
    super.setup(ls)
    dataSets.append(timeline_set)
  }

  override func add(_ index: Int, _ data: KlineData) {
    super.add(index, data)
    timeline_set.removeEntry(index: index)
    if let entry = ChartDataEntry(index.d, timeline_res[0][index]?[0], data) {
      timeline_set.append(entry)
    }
  }


  override func calculate() {
    super.calculate()
    let inputs = datas.map { [$0.close.d ?? 0] }
    timeline_calc(0, inputs)
  }

  var timeline_res: [[Int:[Double]]] = [[:]]

  func timeline_calc(_ n: Int, _ inputs: [[Double]]) {
    timeline_res[n] = inputs.dict_val
  }

  lazy var timeline_set: LineChartDataSet = {
    let ret = LineChartDataSet("timeline-line",
                               datas.enumerated().compactMap { ChartDataEntry($0.offset.d, timeline_res[0][$0.offset]?[0], $0.element) },
                               .right,
                               [timeline_colors[0]]
    )

    ret.highlightEnabled = true

    let gradient_colors = [UIColor.white, timeline_colors[1]].map { $0.cgColor }
    if let gradient = CGGradient(colorsSpace: nil, colors: gradient_colors as CFArray, locations: [0.25, 1.0]) {
      ret.fill = LinearGradientFill(gradient: gradient, angle: 90)
    }
    ret.drawFilledEnabled = true

    return ret
  }()

  public var timeline_colors = [kline_timeline_line_c, kline_timeline_fill_c]
}
