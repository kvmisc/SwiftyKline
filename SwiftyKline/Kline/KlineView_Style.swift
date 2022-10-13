//
//  KlineView_Style.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// [COLORS]
extension UIColor {
  static var kline_background: UIColor? { .white }


  // trademark
  static var kline_trademark_text: UIColor? { "#f1f1f1".clr }

  // grid
  static var kline_grid_line: UIColor? { "#ecedf0".clr }

  // label
  static var kline_footer_label: UIColor? { "#848d9c".clr }
  static var kline_value_label: UIColor? { "#848d9c".clr }

  // current
  static var kline_current_background: UIColor? { "#f9f5eb".clr }
  static var kline_current_text: UIColor? { "#f0b80d".clr }
  static var kline_current_line: UIColor? { "#f0dca6".clr }

  // mark
  static var kline_mark_text: UIColor? { "#848d9c".clr }
  static var kline_mark_line: UIColor? { "#848d9c".clr }

  // legend
  static var kline_legend: UIColor? { "#848d9c".clr }

  // highlight
  static var kline_highlight_line: UIColor? { "#d2d3d5".clr }

  // overlay
  static var kline_overlay_background: UIColor? { .white }
  static var kline_overlay_shadow: UIColor? { .black }
  static var kline_overlay_field_title: UIColor? { "#848d9c".clr }
  static var kline_overlay_field_value: UIColor? { "#848d9c".clr }


  static var kline_timeline_line: UIColor? { "#f1b90c".clr }
  static var kline_timeline_fill: UIColor? { "#f1b90c".clr }

  static var kline_range_neutral: UIColor? { "#2fbd85".clr }
  static var kline_range_increase: UIColor? { "#2fbd85".clr }
  static var kline_range_decrease: UIColor? { "#f5455d".clr }


  static var kline_ma7_line: UIColor? { "#f0b80d".clr }
  static var kline_ma25_line: UIColor? { "#e740b5".clr }
  static var kline_ma99_line: UIColor? { "#8a68c4".clr }

  static var kline_ema7_line: UIColor? { "#f0b80d".clr }
  static var kline_ema25_line: UIColor? { "#e740b5".clr }
  static var kline_ema99_line: UIColor? { "#8a68c4".clr }

  static var kline_boll_mid_line: UIColor? { "#f0b80d".clr }
  static var kline_boll_up_line: UIColor? { "#e740b5".clr }
  static var kline_boll_low_line: UIColor? { "#8a68c4".clr }


  static var kline_vol_neutral: UIColor? { "#2fbd85".clr }
  static var kline_vol_increase: UIColor? { "#2fbd85".clr }
  static var kline_vol_decrease: UIColor? { "#f5455d".clr }
  static var kline_vol_legend: UIColor? { "#848d9c".clr }

  static var kline_macd_dif: UIColor? { .red }
  static var kline_macd_dea: UIColor? { .blue }
  static var kline_macd_macd: UIColor? { .green }
  static var kline_macd_neutral: UIColor? { "#2fbd85".clr }
  static var kline_macd_increase: UIColor? { "#2fbd85".clr }
  static var kline_macd_decrease: UIColor? { "#f5455d".clr }

  static var kline_kdj_k_line: UIColor? { "#f0b80d".clr }
  static var kline_kdj_d_line: UIColor? { "#e740b5".clr }
  static var kline_kdj_j_line: UIColor? { "#8a68c4".clr }

  static var kline_rsi6_line: UIColor? { "#f0b80d".clr }
  static var kline_rsi12_line: UIColor? { "#e740b5".clr }
  static var kline_rsi24_line: UIColor? { "#8a68c4".clr }
}

// [FONTS]
extension UIFont {
  // trademark
  static let kline_trademark_text = UIFont.systemFont(ofSize: 14, weight: .black)

  // grid
  // ...

  // label
  static let kline_footer_label = UIFont.systemFont(ofSize: 9, weight: .regular)
  static let kline_value_label = UIFont.systemFont(ofSize: 9, weight: .regular)

  // current
  static var kline_current_text = UIFont.systemFont(ofSize: 9, weight: .regular)

  // mark
  static var kline_mark_text = UIFont.systemFont(ofSize: 9, weight: .regular)

  // legend
  static var kline_legend = UIFont.systemFont(ofSize: 9, weight: .regular)

  // highlight
  // ...

  // overlay
  static var kline_overlay_field_title = UIFont.systemFont(ofSize: 9, weight: .regular)
  static var kline_overlay_field_value = UIFont.systemFont(ofSize: 9, weight: .regular)
}
