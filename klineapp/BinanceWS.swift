//
//  BinanceWS.swift
//  klineapp
//
//  Created by Kevin Wu on 2024/08/23.
//

import UIKit
import Combine
import SwiftyJSON
import SwiftyKline

public class BinanceWS: WebSocketManager {

  public static let shared = BinanceWS("wss://stream.binance.com:9443/ws")

  public override func recv(_ val: Data) {
    let json = JSON(val)
    let event = json["e"].stringValue

    switch event {
    case "kline":
      let symbol = json["s"].stringValue.lowercased()
      let interval = json["k"]["i"].stringValue.lowercased()
      let key = "kline_\(symbol)_\(interval)"
      let pub = subs[key]?.publisher as? PassthroughSubject<KlineData,Never>

      let model = KlineData(json["k"])

      pub?.send(model)

    default: break
    }
  }

  public func subscribeKline(_ symbol: String, _ interval: String) -> PassthroughSubject<KlineData,Never> {
    let key = "kline_\(symbol)_\(interval)"
    let cmd1: [String:Any] = [
      "id": 1,
      "method": "SUBSCRIBE",
      "params": ["\(symbol)@kline_\(interval)"]
    ]
    let cmd2: [String:Any] = [
      "id": 2,
      "method": "UNSUBSCRIBE",
      "params": ["\(symbol)@kline_\(interval)"]
    ]
    return addSub(key, cmd1.json_str, cmd2.json_str)
  }

  public func unsubscribeKline(_ symbol: String, _ interval: String) {
    let key = "kline_\(symbol)_\(interval)"
    removeSub(key)
  }

}

extension Dictionary {
  var json_str: String? {
    if let dat = try? JSONSerialization.data(withJSONObject: self) {
      return String(decoding: dat, as: UTF8.self)
    }
    return nil
  }
}
