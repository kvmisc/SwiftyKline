//
//  MainWS.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SwiftyJSON

public class MainWS: WebSocketManager {

  public static let shared = MainWS("wss://stream.binance.com:9443/ws")

  override func recv(_ val: Data) {
    let json = JSON(val)
    let event = json["e"].stringValue

    switch event {
    case "kline":
      let symbol = json["s"].stringValue.lowercased()

      let kline = KlineModel(any: json["k"])

      let key = "kline_\(symbol)_\(kline.interval)"
      let publisher = entries[key]?.publisher as? PassthroughSubject<KlineModel,Never>
      publisher?.send(kline)

    default: break
    }

  }

}

public extension MainWS {

  func subscribeKline(_ symbol: String, _ interval: String) -> AnyPublisher<KlineModel,Never> {
    let key = "kline_\(symbol)_\(interval)"
    let cmd1 = json_to_data([
      "id": 1,
      "method": "SUBSCRIBE",
      "params": ["\(symbol)@kline_\(interval)"]
    ])?.str ?? ""
    let cmd2 = json_to_data([
      "id": 2,
      "method": "UNSUBSCRIBE",
      "params": ["\(symbol)@kline_\(interval)"]
    ])?.str ?? ""
    return addEntry(key, cmd1, cmd2).eraseToAnyPublisher()
  }

  func unsubscribeKline(_ symbol: String, _ interval: String) {
    let key = "kline_\(symbol)_\(interval)"
    removeEntry(key)
  }

}
