//
//  CombineCompatible.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public protocol CombineCompatible: AnyObject {
  var cancellables: Set<AnyCancellable> { get set }
}


open class BaseObject: CombineCompatible {
  public init() { }

  public lazy var cancellables = Set<AnyCancellable>()
}

open class BaseCocoa: NSObject, CombineCompatible {

  public lazy var cancellables = Set<AnyCancellable>()
}
