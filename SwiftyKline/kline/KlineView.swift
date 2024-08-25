//
//  KlineView.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/21.
//

import UIKit
import DGCharts

public class KlineView: CombinedChartView, ChartViewDelegate {

  // MARK: Metrics

  public var ver_segment_count = 4 {
    didSet {
      //setNeedsUpdateConstraints()
      rightAxis.setLabelCount(ver_segment_count + 1, force: true)
      //setChartMetrics()
    }
  }
  public var ver_segment_height = 75.0 {
    didSet {
      //setNeedsUpdateConstraints()
      //setChartMetrics()
    }
  }

  public var hor_segment_count = 3 {
    didSet {
      xAxis.setLabelCount(hor_segment_count + 1, force: false)
      setNeedsDisplay()
    }
  }
  public var hor_segment_width: Double {
    bounds.width / hor_segment_count.d
  }
  public var hor_drag_offset = 80.0 { // won't move automatically
    didSet {
      viewPortHandler.setDragOffsetX(hor_drag_offset)
    }
  }


  public var header_height = 16.0 {
    didSet {
      //setNeedsUpdateConstraints()
      setExtraOffsets(left: 0, top: header_height, right: 0, bottom: footer_label_padding_bottom)
    }
  }

  public var footer_label_padding_top = 2.0 {
    didSet {
      xAxis.yOffset = footer_label_padding_top
      //setNeedsUpdateConstraints()
    }
  }
  public var footer_label_font = kline_footer_label_f {
    didSet {
      xAxis.labelFont = footer_label_font
      //setNeedsUpdateConstraints()
    }
  }
  public var footer_label_color = kline_footer_label_c {
    didSet {
      xAxis.labelTextColor = footer_label_color
      setNeedsDisplay()
    }
  }
  public var footer_label_padding_bottom = 2.0 {
    didSet {
      setExtraOffsets(left: 0, top: header_height, right: 0, bottom: footer_label_padding_bottom)
      //setNeedsUpdateConstraints()
    }
  }
  public var footer_height: Double {
    footer_label_padding_top + footer_label_font.lineHeight + footer_label_padding_bottom
  }


  public var value_label_offset: CGPoint = .zero { // y=0 means above line
    didSet {
      rightAxis.xOffset = value_label_offset.x
      rightAxis.yOffset = -(rightAxis.labelFont.lineHeight / 2.5) + value_label_offset.y
      setNeedsDisplay()
    }
  }
  public var value_label_font = kline_value_label_f {
    didSet {
      rightAxis.labelFont = value_label_font
      rightAxis.yOffset = -(rightAxis.labelFont.lineHeight / 2.5) + value_label_offset.y
      setNeedsDisplay()
    }
  }
  public var value_label_color = kline_value_label_c {
    didSet {
      rightAxis.labelTextColor = value_label_color
      setNeedsDisplay()
    }
  }


  public var grid_line_width = 0.5 {
    didSet {
      rightAxis.gridLineWidth = grid_line_width
      xAxis.gridLineWidth = grid_line_width
      setNeedsDisplay()
    }
  }
  public var grid_line_color = kline_grid_line_c {
    didSet {
      rightAxis.gridColor = grid_line_color
      xAxis.gridColor = grid_line_color
      setNeedsDisplay()
    }
  }


  public var bar_width_min = 2.0
  public var bar_width_max = 30.0
  public var bar_width_preferred = 6.0


  public override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: ver_segment_height * ver_segment_count.d + header_height + footer_height)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(width: UIScreen.main.bounds.width, height: ver_segment_height * ver_segment_count.d + header_height + footer_height)
  }

  // MARK: Data & Chart

  public private(set) var datas: [KlineData] = [] {
    didSet {
      (xAxis.valueFormatter as? KlineXFormatter)?.reload(datas.map({ $0.begin.d }))
      reloadSelectedData()
    }
  }

  var primaryChart: KlineChart?
  var secondaryChart: KlineChart?
  var charts: [KlineChart] {
    [primaryChart, secondaryChart].compactMap { $0 }
  }

  // MARK: Public Functions

  public func setup() {
    noDataText = ""
    backgroundColor = .clear

    pinchZoomEnabled = false // 两根手指缩放时，不让两轴同时伸缩
    dragDecelerationEnabled = false // 拖拽放手后立即停止
    highlightPerTapEnabled = false // 点击的时候是否选中
    highlightPerDragEnabled = false // 拖动的时候是否选中
    doubleTapToZoomEnabled = true // 双击放大

    scaleXEnabled = true // 水平可以缩放
    dragXEnabled = true // 水平可以拖拽
    scaleYEnabled = false // 垂直不能缩放
    dragYEnabled = false // 垂直不能拖拽

    autoScaleMinMaxEnabled = true // 水平缩放时，垂直范围自动变化

    legend.enabled = false

    // 四周的空白边距
    minOffset = 0
    // 指定边界 padding，上面是整个 header 的高度，下面只需指定文字下边距，再通过 xAxis.yOffset 将文字下移来指定文字上连距
    setExtraOffsets(left: 0, top: header_height, right: 0, bottom: footer_label_padding_bottom)
    // 左右能动的空白，和固定空白不同
    viewPortHandler.setDragOffsetX(hor_drag_offset)


    leftAxis.drawZeroLineEnabled = false
    leftAxis.drawAxisLineEnabled = false
    leftAxis.drawGridLinesEnabled = false
    leftAxis.drawLabelsEnabled = false
    leftAxis.drawTopYLabelEntryEnabled = false
    leftAxis.drawBottomYLabelEntryEnabled = false
    //leftAxis.spaceTop = xx
    //leftAxis.spaceBottom = xx
    //leftAxis.axisMinimum = xx
    //leftAxis.axisMaximum = xx


    rightAxis.drawZeroLineEnabled = false
    rightAxis.drawAxisLineEnabled = false
    rightAxis.drawGridLinesEnabled = true
    rightAxis.drawLabelsEnabled = true
    rightAxis.drawTopYLabelEntryEnabled = true
    rightAxis.drawBottomYLabelEntryEnabled = false
    //rightAxis.spaceTop = xx
    //rightAxis.spaceBottom = xx
    //rightAxis.axisMinimum = xx
    //rightAxis.axisMaximum = xx


    rightAxis.gridColor = grid_line_color
    rightAxis.gridLineWidth = grid_line_width

    rightAxis.labelPosition = .insideChart
    rightAxis.setLabelCount(ver_segment_count + 1, force: true)
    rightAxis.labelFont = value_label_font
    rightAxis.labelTextColor = value_label_color
    rightAxis.labelAlignment = .right

    // 移动 right 轴文字的位置
    rightAxis.xOffset = value_label_offset.x
    rightAxis.yOffset = -(rightAxis.labelFont.lineHeight / 2.5) + value_label_offset.y // 内部是除 2.5，这里抵消它


    xAxis.gridColor = grid_line_color
    xAxis.gridLineWidth = grid_line_width

    xAxis.labelPosition = .bottom
    xAxis.setLabelCount(hor_segment_count + 1, force: false)
    xAxis.labelFont = footer_label_font
    xAxis.labelTextColor = footer_label_color

    // 移动 x 轴文字的位置
    xAxis.xOffset = 0
    xAxis.yOffset = footer_label_padding_top

    xAxis.spaceMin = 0.5 // ???
    xAxis.spaceMax = 0.5 // ???
    xAxis.granularity = 1 // ???
    xAxis.valueFormatter = KlineXFormatter()
    xAxis.avoidFirstLastClippingEnabled = true


    drawOrder = [
      DrawOrder.candle.rawValue,
      DrawOrder.bar.rawValue,
      DrawOrder.line.rawValue,
    ]

    delegate = self

    let tap = gestureRecognizers?.first { ($0 as? UITapGestureRecognizer)?.numberOfTapsRequired == 1 }
    tap?.addTarget(self, action: #selector(chartTapped))

    let press = UILongPressGestureRecognizer(target: self, action: #selector(chartPressed))
    press.cancelsTouchesInView = false
    press.delaysTouchesBegan = false
    press.delaysTouchesEnded = false
    addGestureRecognizer(press)
  }

  public func resetDatas(_ ls: [KlineData], _ decimals: Int?, _ primary: KlineChart, _ secondary: KlineChart) {
    datas = ls
    primary.setup(ls)
    secondary.setup(ls)
    primaryChart = primary
    secondaryChart = secondary

    setChartMetrics()
    setYAxisDecimals(decimals)

    let dt = CombinedChartData()
    dt.candleData = CandleChartData(dataSets: charts.flatMap({ $0.candleDataSets }))
    dt.barData = BarChartData(dataSets: charts.flatMap({ $0.barDataSets }))
    dt.lineData = LineChartData(dataSets: charts.flatMap({ $0.lineDataSets }))
    data = dt

    setVisibleRange(true)
    setXAxisMaxmin()
  }

  public func addData(_ data: KlineData) {
    if let index = datas.firstIndex(where: { $0.begin == data.begin }) {
      datas[index] = data
      charts.forEach { $0.add(index, data) }
    } else {
      let index = datas.count
      datas.append(data)
      charts.forEach { $0.add(index, data) }
    }
    notifyDataSetChanged()

    setXAxisMaxmin()
  }

  public func erase() {
    datas = []
    primaryChart = nil
    secondaryChart = nil

    selected = nil

    clear()
  }

  // MARK: Private Functions

  func setVisibleRange(_ navi: Bool) {
    setVisibleXRange(minXRange: bounds.width / bar_width_max, maxXRange: bounds.width / bar_width_min)
    if navi {
      let range = bounds.width / bar_width_preferred
      let scale = xAxis.axisRange / range
      // zoom(scaleX: scale, scaleY: 1, xValue: xAxis.axisMaximum - range/2, yValue: 0, axis: .right)
      zoom(scaleX: scale, scaleY: 1, xValue: xAxis.axisMaximum, yValue: 0, axis: .right)
    }
  }

  func setXAxisMaxmin() {
    if let pc = primaryChart {
      pc.lowestX = lowestVisibleX
      pc.highestX = highestVisibleX
      if let maxY = pc.maxY, let minY = pc.minY {
        rightAxis.axisMaximum = maxY
        rightAxis.axisMinimum = minY
      }
    }
    if let sc = secondaryChart {
      sc.lowestX = lowestVisibleX
      sc.highestX = highestVisibleX
      if let maxY = sc.maxY, let minY = sc.minY {
        leftAxis.axisMaximum = maxY
        leftAxis.axisMinimum = minY
      }
    }
  }

  func setYAxisDecimals(_ decimals: Int?) {
    if let formatter = rightAxis.valueFormatter as? DefaultAxisValueFormatter {
      if let decimals = decimals {
        formatter.hasAutoDecimals = false
        formatter.decimals = decimals
      } else {
        formatter.hasAutoDecimals = true
      }
    }
  }

  func moveToEnd() {
    zoom(scaleX: viewPortHandler.scaleX, scaleY: 1, xValue: xAxis.axisMaximum, yValue: 0, axis: .right)
    setXAxisMaxmin()
  }

  func setChartMetrics() {
    primaryChart?.margin_top = 0
    primaryChart?.margin_bottom = ver_segment_height
    primaryChart?.height = ver_segment_height * ver_segment_count.d

    secondaryChart?.margin_top = ver_segment_height * (ver_segment_count.d - 1)
    secondaryChart?.margin_bottom = 0
    secondaryChart?.height = ver_segment_height * ver_segment_count.d
  }

  // MARK: Drawing

  public override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    drawTrademark(context)
    drawGridLine(context)
    super.draw(rect)
    drawCurrent(context)
    drawMinax(context)
    drawLegend(context)
    drawDetail(context)
  }

  func drawTrademark(_ context: CGContext?) {
    let base64 = "iVBORw0KGgoAAAANSUhEUgAAACoAAAAqCAMAAADyHTlpAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAALiaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx0aWZmOkNvbXByZXNzaW9uPjE8L3RpZmY6Q29tcHJlc3Npb24+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOlBob3RvbWV0cmljSW50ZXJwcmV0YXRpb24+MjwvdGlmZjpQaG90b21ldHJpY0ludGVycHJldGF0aW9uPgogICAgICAgICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+NDI8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpDb2xvclNwYWNlPjE8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjQyPC9leGlmOlBpeGVsWURpbWVuc2lvbj4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CrmcQF8AAAHyUExURUdwTP///9bW1v////////////////////Hx8fHx8fHx8fHx8fLy8vHx8fHx8fLy8vLy8vHx8c3Nze/v78DAwPLy8vHx8fHx8fHx8fHx8fLy8qurq/Ly8vHx8fLy8vHx8fDw8PLy8vLy8oGBgfDw8P////Hx8fHx8fDw8PHx8fLy8vHx8fDw8PDw8PHx8fDw8PDw8PLy8vHx8fPz8/Hx8fT09PHx8fLy8vLy8vLy8vPz8/Hx8f////Ly8uvr6/Hx8e/v7/Ly8vHx8fDw8O/v7/Hx8fHx8fPz8+3t7e/v7+/v7/Hx8e/v7/Dw8PHx8fLy8tzc3O7u7u/v7/Ly8vLy8vDw8PLy8vPz8/Hx8fHx8fPz8/Dw8O/v7/Hx8e/v7/Hx8e/v7/X19fLy8vPz8/Pz8/Dw8PPz8/Ly8vDw8PDw8PDw8PLy8vDw8PHx8fPz8+7u7v////Dw8PHx8fDw8PLy8vDw8PLy8vHx8fHx8fHx8f////////Ly8vDw8PHx8f////Dw8PLy8vDw8PT09PHx8fPz8/Hx8e7u7uzs7PHx8fHx8fDw8PHx8fDw8Ozs7PHx8fX19e/v7/T09PHx8fLy8u/v7+/v7/Hx8f////Ly8vn5+fj4+Pr6+vz8/Pf39/v7+/b29vT09P39/f7+/vX19fPz8wZs/PwAAACXdFJOUwAFBgEDBAYC/fr++/n5fDn6/AVABPZ99Tf4/QP4yjr39jv3AncL6+4y7yjqe4aDenn7bmlsF0f8PV9AxgdkDEgP0PHQEOnwKikvMDgu9TYnBzh+ek2FhldLb2dpP0lMwmwywD8+ZULCZszBdXbDFToMZ3HSw8t0NcVdDwkU0ccNRTxoLdUr8hwa9F7yzvAn7TFBLvPpLTxrp2gTAAADH0lEQVQ4y42VBXsaQRCGB7jjlCJpGkhoksZTS+P1pHGvu7u7u7vr7gkQaf9nZ+5IGlIKXe653dt575uP2eEBYO6QKmHZcpAkyDuQWcD50v9gkdjCNY3Py8s6mjKOvKxDFsuMyWoeNq3JcOTRnUXmYSslWOpkZ+FGltMD7ja4pJZKablY3NvqZg/wNSd54N8efAAruNpuMBbjV9evPc1j0yyFMkgJqrjqam7oBKhe6OqqvAEqM1kRrnCNSJ133wFRJFYnVuFnYX4GKkC019YNFufdPeABvC4t5HFm6ObHlRicpSmg7OIlCQWz94AXBAHZ9airpN4PYkgS//gEig3U2JP3O3GBzxJO1denrL4hXKCqz/GLgRufwY+fD2+fPYQIqjQ34U2Eu+8qRpxAKdahxKnnOd73CTc88Pwlkh5YZSaO4xSBV4M4+aG/ly+n3D6sp2Z31eGmSEZEWGUzNXEKlwJVxgP9NSmd7yADVbxYVeyuIbIvYfi2/atd/pVYhymlEvq6NQlFDfPtROoyMwJW7Kmr8maKTlcO83VuloEXZtxgapwvg7bypGLgGT24AE4lot9sxTAUs/YxvSrBvVt0btoE2wkQLDM1hV/z4KEIJXjbiPUNpepHcCkJtHmGK43jxi7AgpcWJvn5tWSVDPjxLKxk/RdciKSKX+wInzAO0Bn6Iaqu8ULEJ8CTDnxzE2ys/fodJy88agHBJ0LkoLkfn5zzP9zqVP4yryjFLT/UjeHkhbHX/BBGI9CKfeBL9wpeEjRPysnYIjcxGYmWJ8NTTSC58el2occ9CSaHrApisV38sLnIVGQ22YLsTLu4/bqXh8PMUKyyH4jhNTxqYlPKGt/9V792lCXxt2eETNT1emHzqInlZtq4si2jXx02WEhB1EW/MFzkPIQsZd9cklKWFpoBDOtW4GZdWXqpF7hVmsteTOva9bW2m0A5SsazscFyx2D4588w2tYsJasmDS8EHYuMeos0C+g0sw9HF00yl1ydPfsMi34JDVmhglzkjAeqUo7ss9kQZffm+98gD+MT+bJPs1FdPfY/JHk40ZbN52+EGOJcU9v5zAAAAABJRU5ErkJggg=="
    if let data = Data(base64Encoded: base64),
       let icon = UIImage(data: data, scale: 2)
    {
      let size = icon.size
      let offset = CGPoint(x: 10, y: 10)
      let spacing = 4.0
      context?.drawImage(icon,
                         atCenter: CGPoint(x: offset.x + size.width/2, y: header_height + offset.y + size.height/2),
                         size: size)
      context?.drawText("BINANCE",
                        at: CGPoint(x: offset.x + size.width + spacing, y: header_height + offset.y + size.height/2),
                        anchor: CGPoint(x: 0, y: 0.5),
                        angleRadians: 0,
                        attributes: [.font: kline_trademark_text_f, .foregroundColor: kline_trademark_text_c])
    }
  }

  func drawGridLine(_ context: CGContext?) {
    guard isEmpty() else { return }
    guard xAxis.labelCount > 1 else { return }
    guard rightAxis.labelCount > 1 else { return }

    context?.saveGState()

    context?.setShouldAntialias(xAxis.gridAntialiasEnabled)
    context?.setLineCap(xAxis.gridLineCap)
    context?.setLineWidth(xAxis.gridLineWidth)
    context?.setStrokeColor(xAxis.gridColor.cgColor)

    context?.beginPath()
    for i in 0...ver_segment_count {
      context?.move(to: CGPoint(x: 0, y: header_height + ver_segment_height * i.d))
      context?.addLine(to: CGPoint(x: bounds.width, y: header_height + ver_segment_height * i.d))
    }
    for i in 1..<hor_segment_count {
      context?.move(to: CGPoint(x: hor_segment_width * i.d, y: header_height))
      context?.addLine(to: CGPoint(x: hor_segment_width * i.d, y: bounds.height - footer_height))
    }
    context?.strokePath()

    context?.restoreGState()
  }

  func drawCurrent(_ context: CGContext?) {
    guard !isEmpty() else { return }
    guard let matrix = rightYAxisRenderer.transformer?.valueToPixelMatrix else { return }

    if let current = primaryChart?.current {
      let unit_px = viewPortHandler.contentWidth * (viewPortHandler.scaleX / xAxis.axisRange)

      let point = current.applying(matrix)
      let minus = point.x > bounds.width - hor_drag_offset
      let pt1 = CGPoint(x: minus ? 0 : point.x + unit_px/2, y: point.y)
      let pt2 = CGPoint(x: bounds.width, y: point.y)

      context?.saveGState()

      context?.setStrokeColor(kline_current_line_c.cgColor)
      context?.setLineWidth(1)
      context?.setLineDash(phase: 0, lengths: [3])

      context?.beginPath()
      context?.move(to: pt1)
      context?.addLine(to: pt2)
      context?.strokePath()

      let padding_v = 1.0
      let padding_h = 2.0
      let value = (rightAxis.valueFormatter?.stringForValue(current.y, axis: rightAxis) ?? "") + (minus ? " \u{27a4}" : "")
      let value_size = value.size(withAttributes: [.font: kline_current_text_f])
      var rect = CGRect(x: 0,
                        y: pt1.y - value_size.height/2 - padding_v,
                        width: value_size.width + padding_h*2,
                        height: value_size.height + padding_v*2)
      if minus {
        rect.origin.x = viewPortHandler.contentWidth - value_size.width - hor_drag_offset - unit_px/2
      } else {
        rect.origin.x = viewPortHandler.contentWidth - value_size.width
      }
      context?.setFillColor(kline_current_background_c.cgColor)
      let path = UIBezierPath(roundedRect: rect, cornerRadius: 1.5)
      path.fill()

      context?.restoreGState()

      context?.drawText(value,
                        at: CGPoint(x: rect.minX + padding_h, y: rect.midY),
                        anchor: CGPoint(x: 0, y: 0.5),
                        angleRadians: 0,
                        attributes: [.font: kline_current_text_f, .foregroundColor: kline_current_text_c])
    }
  }

  func drawMinax(_ context: CGContext?) {
    guard !isEmpty() else { return }
    guard let matrix = rightYAxisRenderer.transformer?.valueToPixelMatrix else { return }

    let line_length = 15.0
    let spacing_0 = 0.0
    let spacing_1 = 0.0

    context?.saveGState()

    context?.setStrokeColor(kline_minax_line_c.cgColor)
    context?.setLineWidth(1)

    [primaryChart?.minaxTop, primaryChart?.minaxBot]
      .compactMap { $0 }
      .forEach {
        let point = $0.applying(matrix)
        let minus = point.x > bounds.width/2

        let pt1 = CGPoint(x: point.x + (minus ? -spacing_0 : spacing_0), y: point.y)
        let pt2 = CGPoint(x: pt1.x + (minus ? -line_length : line_length), y: pt1.y)
        context?.beginPath()
        context?.move(to: pt1)
        context?.addLine(to: pt2)
        context?.strokePath()

        let pt3 = CGPoint(x: pt2.x + (minus ? -spacing_1 : spacing_1), y: pt2.y)
        let anchor = CGPoint(x: minus ? 1.0 : 0.0, y: 0.5)
        context?.drawText(rightAxis.valueFormatter?.stringForValue($0.y, axis: rightAxis) ?? "",
                          at: pt3,
                          anchor: anchor,
                          angleRadians: 0,
                          attributes: [.font: kline_minax_text_f, .foregroundColor: kline_minax_text_c])
      }

    context?.restoreGState()
  }

  func drawLegend(_ context: CGContext?) {
    guard !isEmpty() else { return }
    guard let context = context else { return }

    UIGraphicsPushContext(context)

    let offset_y = (header_height - kline_legend_f.lineHeight) / 2

    let text1 = primaryChart?.legend
    let point1 = CGPoint(x: 10, y: offset_y)
    text1?.draw(at: point1)

    let text2 = secondaryChart?.legend
    let point2 = CGPoint(x: 10, y: header_height + ver_segment_height * (ver_segment_count.d - 1) + offset_y)
    text2?.draw(at: point2)

    UIGraphicsPopContext()
  }

  lazy var detailView: KlineDetailView = {
    let ret = KlineDetailView()
    ret.sizeToFit()
    return ret
  }()

  func drawDetail(_ context: CGContext?) {
    guard !isEmpty() else { return }
    guard let context = context else { return }

    if let highlight = lastHighlighted {
      let minus = highlight.xPx > bounds.width/2

      context.saveGState()

      if minus {
        context.translateBy(x: 8,
                            y: header_height + 8)
      } else {
        context.translateBy(x: bounds.width - hor_drag_offset - 8 - detailView.bounds.width,
                            y: header_height + 8)
      }
      UIGraphicsPushContext(context)
      detailView.layer.render(in: context)
      UIGraphicsPopContext()

      context.restoreGState()
    }
  }

//  public override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
//    super.nsuiTouchesBegan(touches, withEvent: event)
//    guard !isEmpty() else { return }
//    if let currentFrame = currentFrame,
//       let point = event?.allTouches?.first?.location(in: self),
//       currentFrame.contains(point)
//    {
//      kline.moveToEnd()
//      //moveViewToAnimated(xValue: xAxis.axisMaximum, yValue: 0, axis: .right, duration: 0.25)
//    }
//  }

  // MARK: Highlight

  var selected: Highlight? {
    didSet { reloadSelectedData() }
  }
  func reloadSelectedData() {
    if let i = selected?.x.i, i >= 0 && i < datas.count {
      selectedData = datas[i]
    } else {
      selectedData = nil
    }
  }

  var selectedData: KlineData? {
    didSet {
      if let data = selectedData {
        detailView.fill([
          (xAxis.valueFormatter as? KlineXFormatter)?.format(data.begin.d),
          data.open,
          data.high,
          data.low,
          data.close,
          data.volume,
          data.quote,
        ])
      } else {
        detailView.fill([])
      }
    }
  }

  func setChartSelected(_ highlight: Highlight?) {
    selected = highlight
    primaryChart?.selected = highlight
    secondaryChart?.selected = highlight
  }

  func removeSelected() {
    if lastHighlighted != nil {
      lastHighlighted = nil
      highlightValue(nil, callDelegate: true)
    }
  }

  @objc func chartTapped(_ recognizer: UITapGestureRecognizer) {
    guard !isEmpty() else { return }
    if recognizer.state == .ended {
      removeSelected()
    }
  }

  @objc func chartPressed(_ recognizer: UILongPressGestureRecognizer) {
    guard !isEmpty() else { return }
    if recognizer.state == .began {
      if let highlight = getHighlightByTouchPoint(recognizer.location(in: self)) {
//        if lastHighlighted == highlight {
//          lastHighlighted = nil
//          highlightValue(nil, callDelegate: true)
//        } else {
//          lastHighlighted = highlight
//          highlightValue(highlight, callDelegate: true)
//        }
        lastHighlighted = highlight
        highlightValue(highlight, callDelegate: true)
      } else {
        if lastHighlighted != nil {
          lastHighlighted = nil
          highlightValue(nil, callDelegate: true)
        }
      }
    }
  }

  // MARK: ChartViewDelegate

  public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print("[dlg] selected")
    setChartSelected(highlight)

    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    generator.selectionChanged()
  }

  public func chartValueNothingSelected(_ chartView: ChartViewBase) {
    print("[dlg] nothing selected")
    setChartSelected(nil)
  }

  public func chartViewDidEndPanning(_ chartView: ChartViewBase) {
    print("[dlg] end panning")
    setXAxisMaxmin()
    removeSelected()
  }

  public func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
    print("[dlg] scaled")
    setXAxisMaxmin()
    removeSelected()
  }

  public func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
    print("[dlg] translated")
    setXAxisMaxmin()
    removeSelected()
  }

  public func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator) {
    print("[dlg] did stop")
  }
}
