//
//  Serialize.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public extension Data {
  var str: String { String(decoding: self, as: UTF8.self) }
}
public extension String {
  var dat: Data { Data(utf8) }
}

public func json_from_data(_ data: Data?, _ options: JSONSerialization.ReadingOptions = []) -> Any? {
  if let data = data, !data.isEmpty {
    return json_normalize(try? JSONSerialization.jsonObject(with: data, options: options))
  } else {
    return nil
  }
}
public func json_to_data(_ json: Any?, _ options: JSONSerialization.WritingOptions = []) -> Data? {
  if let json = json_normalize(json) {
    return try? JSONSerialization.data(withJSONObject: json, options: options)
  } else {
    return nil
  }
}

func json_normalize(_ json: Any?) -> Any? {
  if let array = json as? [Any] {
    return array.compactMap { json_normalize($0) }
  } else if let object = json as? [String:Any] {
    return object.compactMapValues { json_normalize($0) }
  } else if let number = json as? NSNumber {
    if number.isBool {
      return json as? Bool
    } else if number.isInt {
      return json as? Int
    } else if number.isDouble {
      return json as? Double
    }
  } else if let string = json as? String {
    return string
  }
  return nil
}

// bool as NSNumber   : is bool/int
// int as NSNumber    : is int
// double as NSNumber : is double
extension NSNumber {
  var isBool: Bool {
    CFGetTypeID(self) == CFBooleanGetTypeID()
  }

  var isInt: Bool {
    let types: [CFNumberType] = [
      .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
      .intType, .longType, .longLongType,
      .nsIntegerType,
      .charType, .shortType,
    ]
    return types.contains(CFNumberGetType(self))
  }

  var isDouble: Bool {
    let types: [CFNumberType] = [
      .float32Type, .float64Type,
      .floatType, .doubleType,
      .cgFloatType,
    ]
    return types.contains(CFNumberGetType(self))
  }
}
