//
//  Comb.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public class Comb<Base> {
  let base: Base
  init(_ base: Base) {
    self.base = base
  }
}

public protocol Combe {
  associatedtype CombBase
  var cmb: Comb<CombBase> { get }
}

public extension Combe {
  var cmb: Comb<Self> { Comb(self) }
}

extension NSObject: Combe { }
