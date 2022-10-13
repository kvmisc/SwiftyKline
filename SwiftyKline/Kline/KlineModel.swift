//
//  KlineModel.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct KlineModel: Codable {
  public var symbol = ""
  public var interval = ""

  public var begin = 0
  public var end = 0
  public var ended = false

  public var open = ""
  public var high = ""
  public var low = ""
  public var close = ""

  public var volume = ""
  public var quantity = ""
  public var orders = 0

  public var isIncrease: Bool {
    if let open = open.dbl, let close = close.dbl, open < close {
      return true
    } else {
      return false
    }
  }
  public var isDecrease: Bool {
    if let open = open.dbl, let close = close.dbl, open > close {
      return true
    } else {
      return false
    }
  }
  public var isNeutral: Bool {
    if let open = open.dbl, let close = close.dbl, open == close {
      return true
    } else {
      return false
    }
  }


  public init() { }
}
