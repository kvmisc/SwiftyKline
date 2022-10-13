//
//  KlineView_ChartView.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts

public extension KlineView {

  class ChartView: CombinedChartView {

    weak var kline: KlineView!

    public override func draw(_ rect: CGRect) {
      let context = UIGraphicsGetCurrentContext()
      drawTrademark(context)
      drawGridLines(context)
      super.draw(rect)
      drawCurrent(context)
      drawMarks(context)
      drawLegends(context)
      drawOverlay(context)
    }


    func drawTrademark(_ context: CGContext?) {
      let icon_base64 = "iVBORw0KGgoAAAANSUhEUgAAACoAAAAqCAMAAADyHTlpAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAALiaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx0aWZmOkNvbXByZXNzaW9uPjE8L3RpZmY6Q29tcHJlc3Npb24+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOlBob3RvbWV0cmljSW50ZXJwcmV0YXRpb24+MjwvdGlmZjpQaG90b21ldHJpY0ludGVycHJldGF0aW9uPgogICAgICAgICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+NDI8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpDb2xvclNwYWNlPjE8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjQyPC9leGlmOlBpeGVsWURpbWVuc2lvbj4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CrmcQF8AAAHyUExURUdwTP///9bW1v////////////////////Hx8fHx8fHx8fHx8fLy8vHx8fHx8fLy8vLy8vHx8c3Nze/v78DAwPLy8vHx8fHx8fHx8fHx8fLy8qurq/Ly8vHx8fLy8vHx8fDw8PLy8vLy8oGBgfDw8P////Hx8fHx8fDw8PHx8fLy8vHx8fDw8PDw8PHx8fDw8PDw8PLy8vHx8fPz8/Hx8fT09PHx8fLy8vLy8vLy8vPz8/Hx8f////Ly8uvr6/Hx8e/v7/Ly8vHx8fDw8O/v7/Hx8fHx8fPz8+3t7e/v7+/v7/Hx8e/v7/Dw8PHx8fLy8tzc3O7u7u/v7/Ly8vLy8vDw8PLy8vPz8/Hx8fHx8fPz8/Dw8O/v7/Hx8e/v7/Hx8e/v7/X19fLy8vPz8/Pz8/Dw8PPz8/Ly8vDw8PDw8PDw8PLy8vDw8PHx8fPz8+7u7v////Dw8PHx8fDw8PLy8vDw8PLy8vHx8fHx8fHx8f////////Ly8vDw8PHx8f////Dw8PLy8vDw8PT09PHx8fPz8/Hx8e7u7uzs7PHx8fHx8fDw8PHx8fDw8Ozs7PHx8fX19e/v7/T09PHx8fLy8u/v7+/v7/Hx8f////Ly8vn5+fj4+Pr6+vz8/Pf39/v7+/b29vT09P39/f7+/vX19fPz8wZs/PwAAACXdFJOUwAFBgEDBAYC/fr++/n5fDn6/AVABPZ99Tf4/QP4yjr39jv3AncL6+4y7yjqe4aDenn7bmlsF0f8PV9AxgdkDEgP0PHQEOnwKikvMDgu9TYnBzh+ek2FhldLb2dpP0lMwmwywD8+ZULCZszBdXbDFToMZ3HSw8t0NcVdDwkU0ccNRTxoLdUr8hwa9F7yzvAn7TFBLvPpLTxrp2gTAAADH0lEQVQ4y42VBXsaQRCGB7jjlCJpGkhoksZTS+P1pHGvu7u7u7vr7gkQaf9nZ+5IGlIKXe653dt575uP2eEBYO6QKmHZcpAkyDuQWcD50v9gkdjCNY3Py8s6mjKOvKxDFsuMyWoeNq3JcOTRnUXmYSslWOpkZ+FGltMD7ja4pJZKablY3NvqZg/wNSd54N8efAAruNpuMBbjV9evPc1j0yyFMkgJqrjqam7oBKhe6OqqvAEqM1kRrnCNSJ133wFRJFYnVuFnYX4GKkC019YNFufdPeABvC4t5HFm6ObHlRicpSmg7OIlCQWz94AXBAHZ9airpN4PYkgS//gEig3U2JP3O3GBzxJO1denrL4hXKCqz/GLgRufwY+fD2+fPYQIqjQ34U2Eu+8qRpxAKdahxKnnOd73CTc88Pwlkh5YZSaO4xSBV4M4+aG/ly+n3D6sp2Z31eGmSEZEWGUzNXEKlwJVxgP9NSmd7yADVbxYVeyuIbIvYfi2/atd/pVYhymlEvq6NQlFDfPtROoyMwJW7Kmr8maKTlcO83VuloEXZtxgapwvg7bypGLgGT24AE4lot9sxTAUs/YxvSrBvVt0btoE2wkQLDM1hV/z4KEIJXjbiPUNpepHcCkJtHmGK43jxi7AgpcWJvn5tWSVDPjxLKxk/RdciKSKX+wInzAO0Bn6Iaqu8ULEJ8CTDnxzE2ys/fodJy88agHBJ0LkoLkfn5zzP9zqVP4yryjFLT/UjeHkhbHX/BBGI9CKfeBL9wpeEjRPysnYIjcxGYmWJ8NTTSC58el2occ9CSaHrApisV38sLnIVGQ22YLsTLu4/bqXh8PMUKyyH4jhNTxqYlPKGt/9V792lCXxt2eETNT1emHzqInlZtq4si2jXx02WEhB1EW/MFzkPIQsZd9cklKWFpoBDOtW4GZdWXqpF7hVmsteTOva9bW2m0A5SsazscFyx2D4588w2tYsJasmDS8EHYuMeos0C+g0sw9HF00yl1ydPfsMi34JDVmhglzkjAeqUo7ss9kQZffm+98gD+MT+bJPs1FdPfY/JHk40ZbN52+EGOJcU9v5zAAAAABJRU5ErkJggg=="
      if let icon_data = Data(base64Encoded: icon_base64),
         let icon = UIImage(data: icon_data, scale: 2)
      {
        let size = icon.size
        let offset = CGPoint(x: 10, y: 10)
        let spacing = 4.0
        context?.drawImage(icon,
                           atCenter: CGPoint(x: offset.x + size.width/2, y: kline.header_height + offset.y + size.height/2.0),
                           size: size)
        context?.drawText("BINANCE",
                          at: CGPoint(x: offset.x + size.width + spacing, y: kline.header_height + offset.y + size.height/2.0),
                          anchor: CGPoint(x: 0, y: 0.5),
                          angleRadians: 0,
                          attributes: [.font: UIFont.kline_trademark_text, .foregroundColor: UIColor.kline_trademark_text as Any])
      }
    }


    func drawGridLines(_ context: CGContext?) {
      guard isEmpty() else { return }
      guard xAxis.labelCount > 1 else { return }
      guard rightAxis.labelCount > 1 else { return }

      context?.saveGState()

      context?.setShouldAntialias(xAxis.gridAntialiasEnabled)
      context?.setLineCap(xAxis.gridLineCap)
      context?.setStrokeColor(xAxis.gridColor.cgColor)
      context?.setLineWidth(xAxis.gridLineWidth)

      for i in 0..<(kline.ver_segment_count + 1) {
        context?.beginPath()
        context?.move(to: CGPoint(x: 0, y: kline.header_height + kline.ver_segment_height * i.dbl))
        context?.addLine(to: CGPoint(x: bounds.width, y: kline.header_height + kline.ver_segment_height * i.dbl))
        context?.strokePath()
      }

      for i in 1..<kline.hor_segment_count {
        context?.beginPath()
        context?.move(to: CGPoint(x: kline.hor_segment_width * i.dbl, y: kline.header_height))
        context?.addLine(to: CGPoint(x: kline.hor_segment_width * i.dbl, y: bounds.height - kline.footer_height))
        context?.strokePath()
      }

      context?.restoreGState()
    }


    var current: ()->CGPoint? = { nil }

    var currentFrame: CGRect?

    func drawCurrent(_ context: CGContext?) {
      guard !isEmpty() else { return }
      guard let matrix = rightYAxisRenderer.transformer?.valueToPixelMatrix else { return }

      if let current = current() {
        let unit_px = viewPortHandler.contentWidth * (viewPortHandler.scaleX / xAxis.axisRange)

        let point = current.applying(matrix)
        let minus = point.x > bounds.width - kline.hor_drag_offset

        context?.saveGState()
        let pt1: CGPoint
        let pt2: CGPoint
        if minus {
          pt1 = point.rX(0)
          pt2 = point.rX(bounds.width)
        } else {
          pt1 = point.oX(unit_px/2)
          pt2 = point.rX(bounds.width)
        }
        if let color = UIColor.kline_current_line {
          context?.setStrokeColor(color.cgColor)
        }
        context?.setLineWidth(1)
        context?.setLineDash(phase: 0, lengths: [3])
        context?.beginPath()
        context?.move(to: pt1)
        context?.addLine(to: pt2)
        context?.strokePath()

        let padding_v = 1.0
        let padding_h = 2.0
        var value = rightAxis.valueFormatter?.stringForValue(current.y, axis: rightAxis) ?? ""
        value += (minus ? " \u{27a4}" : "")
        let value_size = value.size(withAttributes: [.font: UIFont.kline_current_text])
        var rect = CGRect(x: 0,
                          y: pt1.y - value_size.height/2 - padding_v,
                          width: value_size.width + padding_h*2,
                          height: value_size.height + padding_v*2)
        if minus {
          rect = rect.rX(viewPortHandler.contentWidth - value_size.width - kline.hor_drag_offset - unit_px/2)
          currentFrame = rect.insetBy(dx: 0, dy: -10)
        } else {
          rect = rect.rX(viewPortHandler.contentWidth - value_size.width)
          currentFrame = nil
        }
        if let color = UIColor.kline_current_background {
          context?.setFillColor(color.cgColor)
        }
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 1.5)
        path.fill()

        context?.restoreGState()

        context?.drawText(value,
                          at: CGPoint(x: rect.minX + padding_h, y: rect.midY),
                          anchor: CGPoint(x: 0, y: 0.5),
                          angleRadians: 0,
                          attributes: [.font: UIFont.kline_current_text, .foregroundColor: UIColor.kline_current_text as Any])
      }
    }


    var markTop: ()->CGPoint? = { nil }
    var markBottom: ()->CGPoint? = { nil }

    func drawMarks(_ context: CGContext?) {
      guard !isEmpty() else { return }
      guard let matrix = rightYAxisRenderer.transformer?.valueToPixelMatrix else { return }

      let line_length = 15.0
      let spacing_0 = 0.0
      let spacing_1 = 0.0

      context?.saveGState()
      if let color = UIColor.kline_mark_line {
        context?.setStrokeColor(color.cgColor)
      }
      context?.setLineWidth(1)

      [markTop(), markBottom()]
        .compactMap { $0 }
        .forEach { mark in
          let point = mark.applying(matrix)
          let minus = point.x > bounds.width/2

          let pt1 = point.oX(minus ? -spacing_0 : spacing_0)
          let pt2 = pt1.oX(minus ? -line_length : line_length)

          context?.beginPath()
          context?.move(to: pt1)
          context?.addLine(to: pt2)
          context?.strokePath()

          let pt3 = pt2.oX(minus ? -spacing_1 : spacing_1)
          let anchor = CGPoint(x: minus ? 1.0 : 0.0, y: 0.5)
          context?.drawText(rightAxis.valueFormatter?.stringForValue(mark.y, axis: rightAxis) ?? "",
                            at: pt3,
                            anchor: anchor,
                            angleRadians: 0,
                            attributes: [.font: UIFont.kline_mark_text, .foregroundColor: UIColor.kline_mark_text as Any])
        }

      context?.restoreGState()
    }


    var legendPrimary: ()->NSAttributedString? = { nil }
    var legendSecondary: ()->NSAttributedString? = { nil }

    func drawLegends(_ context: CGContext?) {
      guard !isEmpty() else { return }
      guard let context = context else { return }

      UIGraphicsPushContext(context)

      let offset_y = (kline.header_height - UIFont.kline_legend.lineHeight) / 2

      let text1 = legendPrimary()
      let point1 = CGPoint(x: 10,
                           y: offset_y)
      text1?.draw(at: point1)

      let text2 = legendSecondary()
      let point2 = CGPoint(x: 10,
                           y: kline.header_height + kline.ver_segment_height * (kline.ver_segment_count.dbl - 1) + offset_y)
      text2?.draw(at: point2)

      UIGraphicsPopContext()
    }


    lazy var overlayView: OverlayView = {
      let ret = OverlayView()
      ret.sizeToFit()
      return ret
    }()

    func drawOverlay(_ context: CGContext?) {
      guard !isEmpty() else { return }
      guard let context = context else { return }

      if let highlight = lastHighlighted {
        let minus = highlight.xPx > bounds.width/2

        context.saveGState()
        if minus {
          context.translateBy(x: 8,
                              y: kline.header_height + 8)
        } else {
          context.translateBy(x: bounds.width - kline.hor_drag_offset - 8 - overlayView.bounds.width,
                              y: kline.header_height + 8)
        }
        UIGraphicsPushContext(context)
        overlayView.layer.render(in: context)
        UIGraphicsPopContext()
        context.restoreGState()
      }
    }


    public override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
      super.nsuiTouchesBegan(touches, withEvent: event)
      guard !isEmpty() else { return }
      if let currentFrame = currentFrame,
         let point = event?.allTouches?.first?.location(in: self),
         currentFrame.contains(point)
      {
        kline.moveToEnd()
        //moveViewToAnimated(xValue: xAxis.axisMaximum, yValue: 0, axis: .right, duration: 0.25)
      }
    }

  }

}
