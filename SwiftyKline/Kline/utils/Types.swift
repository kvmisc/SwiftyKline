//
//  Types.swift
//  testlib
//
//  Created by Kevin Wu on 2022/10/13.
//

import UIKit

// Int - Double
public extension Int {
  var dbl: Double { Double(self) }
}
public extension Double {
  var int: Int { Int(self) }
}

// Int - String
public extension Int {
  var str: String { String(self, radix: 10, uppercase: false) }
}
public extension String {
  var int: Int? { Int(self, radix: 10) }
}

// Double - String
public extension Double {
  var str: String { String(format: "%f", self) }
}
public extension String {
  var dbl: Double? { Double(self) }
}

public extension Collection {
  func at(_ i: Int) -> Element? {
    if i >= 0 && i < count {
      let idx = index(startIndex, offsetBy: i)
      return self[idx]
    }
    return nil
  }
}
public extension Collection where Self: MutableCollection & RangeReplaceableCollection {
  @discardableResult mutating func update(_ i: Int, _ e: Element) -> Element? {
    if let old = at(i) {
      let idx = index(startIndex, offsetBy: i)
      self[idx] = e // MutableCollection
      return old
    } else {
      if i == count {
        append(e) // RangeReplaceableCollection
      }
      return nil
    }
  }
}
public extension Array {
  var dictValue: [Int:Element] {
    enumerated().reduce([Int:Element]()) {
      var dict = $0
      dict[$1.offset] = $1.element
      return dict
    }
  }
}

public extension String {
  var clr: UIColor {
    if !isEmpty {
      var str = replacingOccurrences(of: "#", with: "")
      if str.count == 6 {
        str += "ff"
      }
      if str.count == 8 {
        let scanner = Scanner(string: str)
        var value: UInt64 = 0
        if scanner.scanHexInt64(&value) {
          let r = CGFloat((value & 0xff000000) >> 24) / 255
          let g = CGFloat((value & 0x00ff0000) >> 16) / 255
          let b = CGFloat((value & 0x0000ff00) >> 8 ) / 255
          let a = CGFloat( value & 0x000000ff       ) / 255
          return UIColor(red: r, green: g, blue: b, alpha: a)
        }
      }
    }
    assertionFailure("create color failed, should not be here")
    return .clear
  }
}

public extension Date {
  static func fromTimestamp(_ val: Double?) -> Date? {
    if let val = val, val > 0 {
      return Date(timeIntervalSince1970: val < 100_0000_0000 ? val : val / 1000)
    }
    return nil
  }
}

public extension CGPoint {
  func rX(_ val: Int) -> CGPoint { CGPoint(x: CGFloat(val), y: y) }
  func rY(_ val: Int) -> CGPoint { CGPoint(x: x, y: CGFloat(val)) }
  func rX(_ val: Double) -> CGPoint { CGPoint(x: val, y: y) }
  func rY(_ val: Double) -> CGPoint { CGPoint(x: x, y: val) }
}
public extension CGPoint {
  func oX(_ val: Int) -> CGPoint { CGPoint(x: x + CGFloat(val), y: y) }
  func oY(_ val: Int) -> CGPoint { CGPoint(x: x, y: y + CGFloat(val)) }
  func oX(_ val: Double) -> CGPoint { CGPoint(x: x + val, y: y) }
  func oY(_ val: Double) -> CGPoint { CGPoint(x: x, y: y + val) }
}
public extension CGRect {
  func rX(_ val: Int) -> CGRect { CGRect(x: CGFloat(val), y: minY, width: width, height: height) }
  func rY(_ val: Int) -> CGRect { CGRect(x: minX, y: CGFloat(val), width: width, height: height) }
  func rWidth(_ val: Int) -> CGRect { CGRect(x: minX, y: minY, width: CGFloat(val), height: height) }
  func rHeight(_ val: Int) -> CGRect { CGRect(x: minX, y: minY, width: width, height: CGFloat(val)) }
  func rX(_ val: Double) -> CGRect { CGRect(x: val, y: minY, width: width, height: height) }
  func rY(_ val: Double) -> CGRect { CGRect(x: minX, y: val, width: width, height: height) }
  func rWidth(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: val, height: height) }
  func rHeight(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: width, height: val) }
}
public extension CGRect {
  func oX(_ val: Int) -> CGRect { CGRect(x: minX + CGFloat(val), y: minY, width: width, height: height) }
  func oY(_ val: Int) -> CGRect { CGRect(x: minX, y: minY + CGFloat(val), width: width, height: height) }
  func oWidth(_ val: Int) -> CGRect { CGRect(x: minX, y: minY, width: width + CGFloat(val), height: height) }
  func oHeight(_ val: Int) -> CGRect { CGRect(x: minX, y: minY, width: width, height: height + CGFloat(val)) }
  func oX(_ val: Double) -> CGRect { CGRect(x: minX + val, y: minY, width: width, height: height) }
  func oY(_ val: Double) -> CGRect { CGRect(x: minX, y: minY + val, width: width, height: height) }
  func oWidth(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: width + val, height: height) }
  func oHeight(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: width, height: height + val) }
}
