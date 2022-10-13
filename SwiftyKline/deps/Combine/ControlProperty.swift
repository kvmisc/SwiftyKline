//
//  ControlProperty.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Comb where Base: UITextField {

  var text: AnyPublisher<String?,Never> {
    Publishers
      .ControlProperty(control: base, event: [.editingChanged, .editingDidEnd, .editingDidEndOnExit], keyPath: \.text)
      .eraseToAnyPublisher()
  }

}

public extension Publishers {

  struct ControlProperty<Control: UIControl, Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    let control: Control
    let event: Control.Event
    let keyPath: KeyPath<Control,Value>

    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
      let subscription = Subscription(subscriber, control, event, keyPath)
      subscriber.receive(subscription: subscription)
    }
  }

}

extension Publishers.ControlProperty {

  class Subscription<S: Subscriber, Control: UIControl, Value>: Combine.Subscription where S.Input == Value {
    let subscriber: S
    weak var control: Control?
    let event: Control.Event
    let keyPath: KeyPath<Control,Value>

    init(_ subscriber: S,
         _ control: Control,
         _ event: Control.Event,
         _ keyPath: KeyPath<Control,Value>
    ) {
      self.subscriber = subscriber
      self.control = control
      self.event = event
      self.keyPath = keyPath
      setup()
    }
    func setup() {
      control?.addTarget(self, action: #selector(handleEvent), for: event)
    }

    var didEmitInitial = false

    func request(_ demand: Subscribers.Demand) {
      // Emit initial value upon first demand request
      guard let control = control else { return }
      if demand > .none {
        if !didEmitInitial {
          didEmitInitial = true
          _ = subscriber.receive(control[keyPath: keyPath])
        }
      }
      // We don't care about the demand at this point.
      // As far as we're concerned - UIControl events are endless until the control is deallocated.
    }

    func cancel() {
      control?.removeTarget(self, action: #selector(handleEvent), for: event)
    }

    @objc func handleEvent() {
      guard let control = control else { return }
      _ = subscriber.receive(control[keyPath: keyPath])
    }
  }

}
