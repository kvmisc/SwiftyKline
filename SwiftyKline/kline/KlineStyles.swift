//
//  KlineStyles.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/21.
//

import UIKit

extension UIColor {
  static func hex(_ val: UInt) -> UIColor {
    UIColor(red: CGFloat(val >> 16)/255,
            green: CGFloat(val >> 8 & 0xff)/255,
            blue: CGFloat(val & 0xff)/255,
            alpha: 1.0)
  }
}



// highlight
let kline_highlight_line_c = UIColor.hex(0xd2d3d5)

// footer
let kline_footer_label_f = UIFont.systemFont(ofSize: 9, weight: .regular) // 10.7
let kline_footer_label_c = UIColor.hex(0x848d9c)

// value
let kline_value_label_f = UIFont.systemFont(ofSize: 9, weight: .regular)
let kline_value_label_c = UIColor.hex(0x848d9c)



// trademark
let kline_trademark_text_f = UIFont.systemFont(ofSize: 14, weight: .black) // 16.7
let kline_trademark_text_c = UIColor.hex(0xf1f1f1)

// grid
let kline_grid_line_c = UIColor.hex(0xecedf0)

// current
let kline_current_text_f = UIFont.systemFont(ofSize: 9, weight: .regular)
let kline_current_text_c = UIColor.hex(0xf0b80d)
let kline_current_line_c = UIColor.hex(0xf0dca6)
let kline_current_background_c = UIColor.hex(0xf9f5eb)

// minax
let kline_minax_text_f = UIFont.systemFont(ofSize: 9, weight: .regular)
let kline_minax_text_c = UIColor.hex(0x848d9c)
let kline_minax_line_c = UIColor.hex(0x848d9c)

// legend
let kline_legend_f = UIFont.systemFont(ofSize: 9, weight: .regular)

// detail
let kline_detail_field_title_f = UIFont.systemFont(ofSize: 9, weight: .regular)
let kline_detail_field_title_c = UIColor.hex(0x848d9c)
let kline_detail_field_value_f = UIFont.systemFont(ofSize: 9, weight: .regular)
let kline_detail_field_value_c = UIColor.hex(0x848d9c)
let kline_detail_background_c = UIColor.white
let kline_detail_shadow_c = UIColor.black



let kline_timeline_line_c = UIColor.hex(0xf1b90c)
let kline_timeline_fill_c = UIColor.hex(0xf1b90c)

let kline_range_decrease_c = UIColor.hex(0xf5455d)
let kline_range_neutral_c = UIColor.hex(0x2fbd85)
let kline_range_increase_c = UIColor.hex(0x2fbd85)


let kline_ma_line_1_c = UIColor.hex(0xf0b80d)
let kline_ma_line_2_c = UIColor.hex(0xe740b5)
let kline_ma_line_3_c = UIColor.hex(0x8a68c4)

let kline_ema7_line_c = UIColor.hex(0xf0b80d)
let kline_ema25_line_c = UIColor.hex(0xe740b5)
let kline_ema99_line_c = UIColor.hex(0x8a68c4)

let kline_boll_mid_line_c = UIColor.hex(0xf0b80d)
let kline_boll_up_line_c = UIColor.hex(0xe740b5)
let kline_boll_low_line_c = UIColor.hex(0x8a68c4)
let kline_boll_legend_c = UIColor.hex(0x848d9c)


let kline_vol_decrease_c = UIColor.hex(0xf5455d)
let kline_vol_neutral_c = UIColor.hex(0x2fbd85)
let kline_vol_increase_c = UIColor.hex(0x2fbd85)
let kline_vol_legend_c = UIColor.hex(0x848d9c)

let kline_macd_dif_c = UIColor.red // line & legend
let kline_macd_dea_c = UIColor.blue // line & legend
let kline_macd_macd_c = UIColor.green // legend
let kline_macd_neutral_c = UIColor.hex(0x2fbd85)
let kline_macd_increase_c = UIColor.hex(0x2fbd85)
let kline_macd_decrease_c = UIColor.hex(0xf5455d)

let kline_kdj_k_line_c = UIColor.hex(0xf0b80d)
let kline_kdj_d_line_c = UIColor.hex(0xe740b5)
let kline_kdj_j_line_c = UIColor.hex(0x8a68c4)

let kline_rsi6_line_c = UIColor.hex(0xf0b80d)
let kline_rsi12_line_c = UIColor.hex(0xe740b5)
let kline_rsi24_line_c = UIColor.hex(0x8a68c4)
