//
//  KlineView.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SnapKit
import Charts

public class KlineView: UIView {
  required init?(coder: NSCoder) { fatalError("not implemented") }
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    layoutViews()
  }
  func setup() {
    backgroundColor = .white
    addSubview(chartView)
    addSubview(intervalView)
    addSubview(subtypeView)
  }
  func layoutViews() {
    intervalView.snp.remakeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
    }
    chartView.snp.remakeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(interval_height)
      make.bottom.equalToSuperview().offset(-subtype_height)
      make.height.equalTo(ver_segment_height * ver_segment_count.dbl + header_height + footer_height)
    }
    subtypeView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
    }
  }


  // MARK: Properties

  public var interval_height = 30.0 {
    didSet { setNeedsUpdateConstraints() }
  }
  public var subtype_height = 30.0 {
    didSet { setNeedsUpdateConstraints() }
  }


  public var ver_segment_count = 4 {
    didSet {
      setNeedsUpdateConstraints()
      chartView.rightAxis.setLabelCount(ver_segment_count + 1, force: true)
      setChartMetrics()
    }
  }
  public var ver_segment_height = 75.0 {
    didSet {
      setNeedsUpdateConstraints()
      setChartMetrics()
    }
  }

  public var hor_segment_count = 3 {
    didSet {
      chartView.xAxis.setLabelCount(hor_segment_count + 1, force: false)
      chartView.setNeedsDisplay()
    }
  }
  public var hor_segment_width: Double {
    bounds.width / hor_segment_count.dbl
  }
  public var hor_drag_offset = 80.0 { // won't move automatically
    didSet { chartView.viewPortHandler.setDragOffsetX(hor_drag_offset) }
  }


  public var header_height = 16.0 {
    didSet {
      setNeedsUpdateConstraints()
      chartView.setExtraOffsets(left: 0, top: header_height, right: 0, bottom: footer_label_padding_bottom)
    }
  }

  public var footer_label_padding_top = 2.0 {
    didSet {
      chartView.xAxis.yOffset = footer_label_padding_top
      setNeedsUpdateConstraints()
    }
  }
  public var footer_label_font: UIFont = .kline_footer_label {
    didSet {
      chartView.xAxis.labelFont = footer_label_font
      setNeedsUpdateConstraints()
    }
  }
  public var footer_label_color: UIColor? = .kline_footer_label {
    didSet {
      if let color = footer_label_color {
        chartView.xAxis.labelTextColor = color
        chartView.setNeedsDisplay()
      }
    }
  }
  public var footer_label_padding_bottom = 2.0 {
    didSet {
      chartView.setExtraOffsets(left: 0, top: header_height, right: 0, bottom: footer_label_padding_bottom)
      setNeedsUpdateConstraints()
    }
  }
  public var footer_height: Double {
    footer_label_padding_top + footer_label_font.lineHeight + footer_label_padding_bottom
  }


  public var value_label_offset = CGPoint.zero { // y=0 means above line
    didSet {
      chartView.rightAxis.xOffset = value_label_offset.x
      chartView.rightAxis.yOffset = -(chartView.rightAxis.labelFont.lineHeight / 2.5) + value_label_offset.y
      chartView.setNeedsDisplay()
    }
  }
  public var value_label_font: UIFont = .kline_value_label {
    didSet {
      chartView.rightAxis.labelFont = value_label_font
      chartView.rightAxis.yOffset = -(chartView.rightAxis.labelFont.lineHeight / 2.5) + value_label_offset.y
      chartView.setNeedsDisplay()
    }
  }
  public var value_label_color: UIColor? = .kline_value_label {
    didSet {
      if let color = value_label_color {
        chartView.rightAxis.labelTextColor = color
        chartView.setNeedsDisplay()
      }
    }
  }


  public var grid_line_width = 0.5 {
    didSet {
      chartView.rightAxis.gridLineWidth = grid_line_width
      chartView.xAxis.gridLineWidth = grid_line_width
      chartView.setNeedsDisplay()
    }
  }
  public var grid_line_color: UIColor? = .kline_grid_line {
    didSet {
      if let color = grid_line_color {
        chartView.rightAxis.gridColor = color
        chartView.xAxis.gridColor = color
        chartView.setNeedsDisplay()
      }
    }
  }


  public var content_width = Double(UIScreen.main.bounds.width)

  public var bar_width_min = 2.0
  public var bar_width_max = 30.0
  public var bar_width_preferred = 6.0


  public private(set) var klineList: [KlineModel] = [] {
    didSet {
      xAxisFormatter.timestamps = klineList.map { $0.begin.dbl }
      highlightedItem = klineList.at(highlighted?.x.int ?? -1)
    }
  }

  var primaryChart: KlineChart?
  var secondaryChart: KlineChart?
  var charts: [KlineChart] { [primaryChart, secondaryChart].compactMap { $0 } }


  // MARK: Public API

  public func resetKlineList(_ list: [KlineModel], _ decimals: Int?) {
    klineList = list


    switch intervalView.interval {
    case .timeline:
      primaryChart = TimelineChart(klineList)
    default:
      switch subtypeView.primary {
      case .ma:
        primaryChart = MaChart(klineList, [
          .init(period: 7, color: .kline_ma7_line),
          .init(period: 25, color: .kline_ma25_line),
          .init(period: 99, color: .kline_ma99_line),
        ])
      case .ema:
        primaryChart = EmaChart(klineList, [
          .init(period: 7, color: .kline_ema7_line),
          .init(period: 25, color: .kline_ema25_line),
          .init(period: 99, color: .kline_ema99_line),
        ])
      case .boll:
        let config = BollChart.Config(period: 20,
                                      deviations: 2,
                                      midColor: .kline_boll_mid_line,
                                      upColor: .kline_boll_up_line,
                                      lowColor: .kline_boll_low_line)
        primaryChart = BollChart(klineList, config)
      }
    }
    primaryChart?.decimals = decimals

    switch subtypeView.secondary {
    case .vol:
      let config = VolChart.Config(neutralColor: .kline_vol_neutral,
                                   increaseColor: .kline_vol_increase,
                                   decreaseColor: .kline_vol_decrease,
                                   legendColor: .kline_vol_legend)
      secondaryChart = VolChart(klineList, config)
      secondaryChart?.decimals = 4
    case .macd:
      let config = MacdChart.Config(shortPeriod: 12,
                                    longPeriod: 26,
                                    signalPeriod: 9,
                                    difColor: .kline_macd_dif,
                                    deaColor: .kline_macd_dea,
                                    macdColor: .kline_macd_macd,
                                    neutralColor: .kline_macd_neutral,
                                    increaseColor: .kline_macd_increase,
                                    decreaseColor: .kline_macd_decrease)
      secondaryChart = MacdChart(klineList, config)
      secondaryChart?.decimals = 2
    case .kdj:
      let config = KdjChart.Config(kperiod: 9,
                                   kslow: 3,
                                   dperiod: 3,
                                   kColor: .kline_kdj_k_line,
                                   dColor: .kline_kdj_d_line,
                                   jColor: .kline_kdj_j_line)
      secondaryChart = KdjChart(klineList, config)
      secondaryChart?.decimals = 2
    case .rsi:
      secondaryChart = RsiChart(klineList, [
        .init(period: 6, color: .kline_rsi6_line),
        .init(period: 12, color: .kline_rsi12_line),
        .init(period: 24, color: .kline_rsi24_line),
      ])
      secondaryChart?.decimals = 2
    }

    setChartMetrics()
    setYAxisDecimals(decimals)


    let data = CombinedChartData()

    data.candleData = CandleChartData(dataSets: charts.flatMap({ $0.candleDataSets }))
    data.barData = BarChartData(dataSets: charts.flatMap({ $0.barDataSets }))
    data.lineData = LineChartData(dataSets: charts.flatMap({ $0.lineDataSets }))

    chartView.data = data


    setVisibleRange(true)
    setXAxisMaxmin()
  }

  public func addKlineItem(_ model: KlineModel) {
    if let index = klineList.firstIndex(where: { $0.begin == model.begin }) {
      klineList[index] = model
      charts.forEach { $0.add(index, model) }
    } else {
      let index = klineList.count
      klineList.append(model)
      charts.forEach { $0.add(index, model) }
    }
    chartView.notifyDataSetChanged()

    setXAxisMaxmin()
  }

  public func clear() {
    primaryChart = nil
    secondaryChart = nil

    klineList = []
    highlighted = nil

    chartView.clear()
  }


  // MARK: Highlight

  var highlighted: Highlight? {
    didSet { highlightedItem = klineList.at(highlighted?.x.int ?? -1) }
  }

  var highlightedItem: KlineModel? {
    didSet {
      if let item = highlightedItem {
        chartView.overlayView.values = [
          xAxisFormatter.format(item.begin.dbl),
          "\(item.open)",
          "\(item.high)",
          "\(item.low)",
          "\(item.close)",
          "\(item.volume)",
          "\(item.quantity)",
        ]
      } else {
        chartView.overlayView.values = []
      }
    }
  }


  // MARK: Routines

  func setVisibleRange(_ navi: Bool) {
    chartView.setVisibleXRange(minXRange: content_width / bar_width_max, maxXRange: content_width / bar_width_min)
    if navi {
      let range = content_width / bar_width_preferred
      let scale = chartView.xAxis.axisRange / range
      // chartView.zoom(scaleX: scale, scaleY: 1, xValue: chartView.xAxis.axisMaximum - range/2, yValue: 0, axis: .right)
      chartView.zoom(scaleX: scale, scaleY: 1, xValue: chartView.xAxis.axisMaximum, yValue: 0, axis: .right)
    }
  }

  func setXAxisMaxmin() {
    if let primaryChart = primaryChart {
      primaryChart.lowestX = chartView.lowestVisibleX
      primaryChart.highestX = chartView.highestVisibleX
      if let maxY = primaryChart.maxY,
         let minY = primaryChart.minY
      {
        chartView.rightAxis.axisMaximum = maxY
        chartView.rightAxis.axisMinimum = minY
      }
    }
    if let secondaryChart = secondaryChart {
      secondaryChart.lowestX = chartView.lowestVisibleX
      secondaryChart.highestX = chartView.highestVisibleX
      if let maxY = secondaryChart.maxY,
         let minY = secondaryChart.minY
      {
        chartView.leftAxis.axisMaximum = maxY
        chartView.leftAxis.axisMinimum = minY
      }
    }
  }

  func setYAxisDecimals(_ decimals: Int?) {
    if let formatter = chartView.rightAxis.valueFormatter as? DefaultAxisValueFormatter {
      if let decimals = decimals {
        formatter.hasAutoDecimals = false
        formatter.decimals = decimals
      } else {
        formatter.hasAutoDecimals = true
      }
    }
  }

  func moveToEnd() {
    chartView.zoom(scaleX: chartView.viewPortHandler.scaleX, scaleY: 1, xValue: chartView.xAxis.axisMaximum, yValue: 0, axis: .right)
    setXAxisMaxmin()
  }

  func setChartMetrics() {
    primaryChart?.margin_top = 0
    primaryChart?.margin_bottom = ver_segment_height
    primaryChart?.height = ver_segment_height * ver_segment_count.dbl

    secondaryChart?.margin_top = ver_segment_height * (ver_segment_count.dbl - 1)
    secondaryChart?.margin_bottom = 0
    secondaryChart?.height = ver_segment_height * ver_segment_count.dbl
  }

  func setChartHighlight(_ highlight: Highlight?) {
    highlighted = highlight
    primaryChart?.highlight = highlight
    secondaryChart?.highlight = highlight
  }

  func removeHighlights() {
    if chartView.lastHighlighted != nil {
      chartView.lastHighlighted = nil
      chartView.highlightValue(nil, callDelegate: true)
    }
  }

  @objc func chartTapped(_ recognizer: UITapGestureRecognizer) {
    guard !chartView.isEmpty() else { return }
    if recognizer.state == .ended {
      removeHighlights()
    }
  }

  @objc func chartPressed(_ recognizer: UILongPressGestureRecognizer) {
    guard !chartView.isEmpty() else { return }
    if recognizer.state == .began {
      if let highlight = chartView.getHighlightByTouchPoint(recognizer.location(in: chartView)) {
//        if chartView.lastHighlighted == highlight {
//          chartView.lastHighlighted = nil
//          chartView.highlightValue(nil, callDelegate: true)
//        } else {
//          chartView.lastHighlighted = highlight
//          chartView.highlightValue(highlight, callDelegate: true)
//        }
        chartView.lastHighlighted = highlight
        chartView.highlightValue(highlight, callDelegate: true)
      } else {
        if chartView.lastHighlighted != nil {
          chartView.lastHighlighted = nil
          chartView.highlightValue(nil, callDelegate: true)
        }
      }
    }
  }


  // MARK: Views

  public lazy var chartView: ChartView = {
    let ret = ChartView()

    ret.kline = self

    ret.noDataText = ""
    ret.backgroundColor = .clear

    ret.pinchZoomEnabled = false // 两根手指缩放时，不让两轴同时伸缩
    ret.dragDecelerationEnabled = false // 拖拽放手后立即停止
    ret.highlightPerTapEnabled = false // 点击的时候是否选中
    ret.highlightPerDragEnabled = false // 拖动的时候是否选中
    ret.doubleTapToZoomEnabled = true // 双击放大

    ret.scaleXEnabled = true // 水平可以缩放
    ret.dragXEnabled = true // 水平可以拖拽
    ret.scaleYEnabled = false // 垂直不能缩放
    ret.dragYEnabled = false // 垂直不能拖拽

    ret.autoScaleMinMaxEnabled = true // 水平缩放时，垂直范围自动变化

    ret.minOffset = 0
    ret.setExtraOffsets(left: 0, top: header_height, right: 0, bottom: footer_label_padding_bottom)
    ret.viewPortHandler.setDragOffsetX(hor_drag_offset)

    ret.current = { [weak self] in self?.primaryChart?.current }

    ret.markTop = { [weak self] in self?.primaryChart?.markTop }
    ret.markBottom = { [weak self] in self?.primaryChart?.markBottom }

    ret.legend.enabled = false
    ret.legendPrimary = { [weak self] in self?.primaryChart?.legend }
    ret.legendSecondary = { [weak self] in self?.secondaryChart?.legend }


    ret.leftAxis.drawZeroLineEnabled = false
    ret.leftAxis.drawAxisLineEnabled = false
    ret.leftAxis.drawGridLinesEnabled = false
    ret.leftAxis.drawLabelsEnabled = false
    ret.leftAxis.drawTopYLabelEntryEnabled = false
    ret.leftAxis.drawBottomYLabelEntryEnabled = false
    //ret.leftAxis.spaceTop = xx
    //ret.leftAxis.spaceBottom = xx
    //ret.leftAxis.axisMinimum = xx
    //ret.leftAxis.axisMaximum = xx


    ret.rightAxis.drawZeroLineEnabled = false
    ret.rightAxis.drawAxisLineEnabled = false
    ret.rightAxis.drawGridLinesEnabled = true
    ret.rightAxis.drawLabelsEnabled = true
    ret.rightAxis.drawTopYLabelEntryEnabled = true
    ret.rightAxis.drawBottomYLabelEntryEnabled = false
    //ret.rightAxis.spaceTop = xx
    //ret.rightAxis.spaceBottom = xx
    //ret.rightAxis.axisMinimum = xx
    //ret.rightAxis.axisMaximum = xx


    if let color = grid_line_color {
      ret.rightAxis.gridColor = color
    }
    ret.rightAxis.gridLineWidth = grid_line_width

    ret.rightAxis.labelPosition = .insideChart
    ret.rightAxis.setLabelCount(ver_segment_count + 1, force: true)
    ret.rightAxis.labelFont = value_label_font
    if let color = value_label_color {
      ret.rightAxis.labelTextColor = color
    }
    ret.rightAxis.labelAlignment = .right

    ret.rightAxis.xOffset = value_label_offset.x
    ret.rightAxis.yOffset = -(ret.rightAxis.labelFont.lineHeight / 2.5) + value_label_offset.y // 内部是除 2.5，这里抵消它


    if let color = grid_line_color {
      ret.xAxis.gridColor = color
    }
    ret.xAxis.gridLineWidth = grid_line_width

    ret.xAxis.labelPosition = .bottom
    ret.xAxis.setLabelCount(hor_segment_count + 1, force: false)
    ret.xAxis.labelFont = footer_label_font
    if let color = footer_label_color {
      ret.xAxis.labelTextColor = color
    }

    ret.xAxis.xOffset = 0
    ret.xAxis.yOffset = footer_label_padding_top

    ret.xAxis.spaceMin = 0.5
    ret.xAxis.spaceMax = 0.5
    ret.xAxis.granularity = 1
    ret.xAxis.valueFormatter = xAxisFormatter
    ret.xAxis.avoidFirstLastClippingEnabled = true


    ret.drawOrder = [
      DrawOrder.candle.rawValue,
      DrawOrder.bar.rawValue,
      DrawOrder.line.rawValue,
    ]


    let tap = ret.gestureRecognizers?.first { ($0 as? UITapGestureRecognizer)?.numberOfTapsRequired == 1 }
    tap?.addTarget(self, action: #selector(chartTapped(_:)))

    let press = UILongPressGestureRecognizer(target: self, action: #selector(chartPressed(_:)))
    press.cancelsTouchesInView = false
    press.delaysTouchesBegan = false
    press.delaysTouchesEnded = false
    ret.addGestureRecognizer(press)


    ret.delegate = self

    return ret
  }()


  lazy var xAxisFormatter = IndexFormatter()

  public lazy var intervalView = IntervalView()

  public lazy var subtypeView = SubtypeView()
}

extension KlineView: ChartViewDelegate {

  public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print("[dlg] selected")
    setChartHighlight(highlight)

    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    generator.selectionChanged()
  }

  public func chartValueNothingSelected(_ chartView: ChartViewBase) {
    print("[dlg] nothing selected")
    setChartHighlight(nil)
  }


  public func chartViewDidEndPanning(_ chartView: ChartViewBase) {
    print("[dlg] end panning")
    setXAxisMaxmin()
    removeHighlights()
  }

  public func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
    print("[dlg] scaled")
    setXAxisMaxmin()
    removeHighlights()
  }

  public func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
    print("[dlg] translated")
    setXAxisMaxmin()
    removeHighlights()
  }


  public func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator) {
    print("[dlg] did stop")
  }

}
