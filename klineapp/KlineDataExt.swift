//
//  KlineDataExt.swift
//  klineapp
//
//  Created by Kevin Wu on 2024/08/23.
//

import UIKit
import SwiftyJSON
import SwiftyKline

extension JSON {
  init(any: Any?) {
    if let val = any as? JSON {
      self.init(val.rawValue)
    } else if let val = any as? String {
      self.init(parseJSON: val)
    } else {
      self.init(any as Any) // data or dict
    }
  }
}

extension KlineData {
  init(_ any: Any?) {
    self.init()
    let json = JSON(any: any)
    if let ary = json.array {
      begin = ary[0].intValue
      end = ary[6].intValue
      open = ary[1].stringValue
      high = ary[2].stringValue
      low = ary[3].stringValue
      close = ary[4].stringValue
      volume = ary[5].stringValue
      quote = ary[7].stringValue
      trades = ary[8].intValue
    } else {
      begin = json["t"].intValue
      end = json["T"].intValue
      open = json["o"].stringValue
      high = json["h"].stringValue
      low = json["l"].stringValue
      close = json["c"].stringValue
      volume = json["v"].stringValue
      quote = json["q"].stringValue
      trades = json["n"].intValue
    }
    if let open = Double(open), let close = Double(close) {
      if open < close {
        rnf = .rise
      } else if open > close {
        rnf = .fall
      } else {
        rnf = .neu
      }
    } else {
      rnf = .neu
    }
  }
}
