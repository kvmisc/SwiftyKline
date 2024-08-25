//
//  KlineUtils.swift
//  SwiftyKline
//
//  Created by Kevin Wu on 2024/08/22.
//

import UIKit

extension BinaryInteger {
  var i: Int { Int(self) }
  var d: Double { Double(self) }
}
extension BinaryFloatingPoint {
  var d: Double { Double(self) }
  var i: Int { Int(self) }
}

extension String {
  var d: Double? { Double(self) }
}

extension Array {
  var dict_val: [Int:Element] {
    enumerated().reduce([Int:Element]()) {
      var dict = $0
      dict[$1.offset] = $1.element
      return dict
    }
  }
}


func size_buffer(_ size: Int) -> (Double?)->[Double] {
  var queue: [Double] = []
  return {
    if let val = $0 {
      queue.append(val)
    } else {
      if !queue.isEmpty {
        queue.removeLast()
      }
    }
    if queue.count > size {
      queue.removeFirst()
    }
    return queue
  }
}


func f2s(_ val: Double?, _ places: Int?) -> String? {
  if let val = val {
    var num = Decimal(val)
    if let places = places {
      var raw = num
      NSDecimalRound(&num, &raw, places, .down)
    }
    let str = NSDecimalString(&num, nil)
    return str
  }
  return nil
}
