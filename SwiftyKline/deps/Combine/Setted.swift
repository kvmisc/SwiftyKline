//
//  Setted.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

@propertyWrapper
public struct Setted<Output>: Publisher {
  public typealias Failure = Never

  let subject: CurrentValueSubject<Output, Never>

  public init(wrappedValue: Output) {
    subject = CurrentValueSubject<Output, Never>(wrappedValue)
  }

  public var wrappedValue: Output {
    get { subject.value }
    nonmutating set { subject.send(newValue) }
  }

  public var projectedValue: Setted<Output> { self }

  public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
    subject.receive(subscriber: subscriber)
  }
}
