//
//  KlineModelExt.swift
//  testlib
//
//  Created by Kevin Wu on 2022/10/13.
//

import UIKit
import SwiftyJSON

public extension JSON {
  static func fromAny(_ any: Any?) -> JSON {
    if let str = any as? String {
      return .init(parseJSON: str)
    } else {
      return .init(any as Any)
    }
  }
}

extension KlineModel {

  public init(any: Any?) {
    let json = JSON.fromAny(any)
    if json.array != nil {
      begin = json.array?.at(0)?.int ?? 0
      end = json.array?.at(6)?.int ?? 0
      ended = end <= Int(Date().timeIntervalSince1970 * 1000)

      open = json.array?.at(1)?.string ?? ""
      high = json.array?.at(2)?.string ?? ""
      low = json.array?.at(3)?.string ?? ""
      close = json.array?.at(4)?.string ?? ""

      volume = json.array?.at(5)?.string ?? ""
      quantity = json.array?.at(7)?.string ?? ""
      orders = json.array?.at(8)?.int ?? 0
    } else {
      symbol = json["s"].stringValue
      interval = json["i"].stringValue

      begin = json["t"].intValue
      end = json["T"].intValue
      ended = json["x"].boolValue

      open = json["o"].stringValue
      high = json["h"].stringValue
      low = json["l"].stringValue
      close = json["c"].stringValue

      volume = json["v"].stringValue
      quantity = json["q"].stringValue
      orders = json["n"].intValue
    }
  }

}
