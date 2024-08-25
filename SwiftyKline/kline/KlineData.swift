//
//  KlineData.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit

/*
{
  "e": "kline",         // Event type
  "E": 1672515782136,   // Event time
  "s": "BNBBTC",        // Symbol
  "k": {
      "t": 1672515780000, // Kline start time
      "T": 1672515839999, // Kline close time
    "x": false,         // Is this kline closed?

      "o": "0.0010",      // Open price
      "h": "0.0025",      // High price
      "l": "0.0015",      // Low price
      "c": "0.0020",      // Close price

      "v": "1000",        // Base asset volume
      "q": "1.0000",      // Quote asset volume
      "n": 100,           // Number of trades

    "s": "BNBBTC",      // Symbol
    "i": "1m",          // Interval
    "f": 100,           // First trade ID
    "L": 200,           // Last trade ID

    "V": "500",         // Taker buy base asset volume
    "Q": "0.500",       // Taker buy quote asset volume
    "B": "123456"       // Ignore
  }
}
*/

public struct KlineData {
  public var begin = 0
  public var end = 0
  public var open = ""
  public var high = ""
  public var low = ""
  public var close = ""
  public var volume = ""
  public var quote = ""
  public var trades = 0

  // rise & fall
  public enum Rnf: Int {
    case fall = -1
    case neu
    case rise
    var i: Int { rawValue + 1 }
  }
  public var rnf: Rnf = .neu

  public init() { }
}
