//
//  Num.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// 0.
// 3333333333
// 3333333333
// 3333333333
// 33333333

// print( Num(1) / "3" )
// 0.33333333333333333333333333333333333333
//
// print( Num(1/3.0) )
// 0.333333333333333248

public extension String {
  func zeroPadded(_ length: Int) -> String {
    let comps = split(separator: ".", maxSplits: Int.max, omittingEmptySubsequences: false).map { String($0) }
    var tail = comps.at(1) ?? ""
    while tail.count < length {
      tail += "0"
    }
    if tail.isEmpty {
      return comps[0]
    } else {
      return comps[0] + "." + tail
    }
  }
}

public struct Num {

  public let raw: Decimal

  public init(_ value: Any?) {
    if let value = value as? Int {
      raw = Decimal(value)
    } else if let value = value as? Double, value.isFinite {
      raw = Decimal(value)
    } else if let value = value as? String {
      if let decimal = Decimal(string: value, locale: nil), decimal.isFinite {
        raw = decimal
      } else {
        raw = .nan
      }
    } else if let value = value as? Decimal, value.isFinite {
      raw = value
    } else if let value = value as? Num {
      raw = value.raw
    } else {
      raw = .nan
    }
  }

  public var isFinite: Bool {
    raw.isFinite
  }

  public var finited: Self? {
    raw.isFinite ? self : nil
  }


  public var int: Int? {
    format(.original)?.split(separator: ".", maxSplits: Int.max, omittingEmptySubsequences: false).map({ String($0) }).first?.int
  }

  public var dbl: Double? {
    format(.original)?.dbl
  }

  public var str: String? {
    format(.original)
  }


  public enum Format {
    case original                                           // 原始形式
    case scale(_ places: Int, _ mode: Decimal.RoundingMode) // 保留 n 位小数，采用 RoundingMode
    case pad(_ places: Int, _ mode: Decimal.RoundingMode)   // 保留 n 位小数，采用 RoundingMode，不足时补 0
  }
  public func format(_ format: Format) -> String? {
    guard raw.isFinite else { return nil }
    var num = raw
    switch format {
    case .original:
      let str = NSDecimalString(&num, nil)
      return str
    case let .scale(places, mode):
      var result: Decimal = .nan
      NSDecimalRound(&result, &num, places, mode)
      let str = NSDecimalString(&result, nil)
      return str
    case let .pad(places, mode):
      var result: Decimal = .nan
      NSDecimalRound(&result, &num, places, mode)
      let str = NSDecimalString(&result, nil)
      return str.zeroPadded(places)
    }
  }

}

extension Num: Equatable, Hashable, Comparable {

  public static func < (lhs: Num, rhs: Num) -> Bool {
    lhs.raw < rhs.raw
  }

}

extension Num: CustomStringConvertible {

  // String(describing:)
  // print(_:)
  public var description: String {
    format(.original) ?? "[NaN]"
  }

}

public extension Num {

  static func + (lhs: Num, rhs: @autoclosure ()->Any?) -> Num {
    if lhs.isFinite {
      let num = Num(rhs())
      if num.isFinite {
        let res = lhs.raw + num.raw
        if res.isFinite {
          return Num(res)
        }
      }
    }
    return Num(nil)
  }

  static func - (lhs: Num, rhs: @autoclosure ()->Any?) -> Num {
    if lhs.isFinite {
      let num = Num(rhs())
      if num.isFinite {
        let res = lhs.raw - num.raw
        if res.isFinite {
          return Num(res)
        }
      }
    }
    return Num(nil)
  }

  static func * (lhs: Num, rhs: @autoclosure ()->Any?) -> Num {
    if lhs.isFinite {
      let num = Num(rhs())
      if num.isFinite {
        let res = lhs.raw * num.raw
        if res.isFinite {
          return Num(res)
        }
      }
    }
    return Num(nil)
  }

  static func / (lhs: Num, rhs: @autoclosure ()->Any?) -> Num {
    if lhs.isFinite {
      let num = Num(rhs())
      if num.isFinite {
        let res = lhs.raw / num.raw
        if res.isFinite {
          return Num(res)
        }
      }
    }
    return Num(nil)
  }

}


public extension Num {

  // 四舍五入，不管正负
  //  1.24=> 1.2,  1.25=> 1.3
  // -1.24=>-1.2, -1.25=>-1.3
  func scalePlain(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.scale(val, .plain))
  }
  // x 轴往左
  //  1.24=> 1.2
  // -1.24=>-1.3
  func scaleDown(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.scale(val, .down))
  }
  // x 轴往右
  //  1.24=> 1.3
  // -1.24=>-1.2
  func scaleUp(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.scale(val, .up))
  }
  // 后面非 5 时，四舍六入
  //  1.24=> 1.2,  1.26=> 1.3
  // -1.24=>-1.2, -1.26=>-1.3
  // 后面是 5 时，5 后无数，向偶数靠近
  //  1.25=> 1.2,  1.35=> 1.4
  // -1.25=>-1.2, -1.35=>-1.4
  // 后面是 5 时，5 后有数，直接加一
  //  1.251=> 1.3,  1.351=> 1.4
  // -1.251=>-1.3, -1.351=>-1.4
  func scaleBankers(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.scale(val, .bankers))
  }


  func padPlain(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.pad(val, .plain))
  }
  func padDown(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.pad(val, .down))
  }
  func padUp(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.pad(val, .up))
  }
  func padBankers(_ places: Any?) -> String? {
    guard let val = Num(places).int else { return format(.original) }
    return format(.pad(val, .bankers))
  }

}
