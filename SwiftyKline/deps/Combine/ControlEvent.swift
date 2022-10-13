//
//  ControlEvent.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Comb where Base: UIButton {

  var tap: AnyPublisher<Void,Never> {
    Publishers
      .ControlEvent(control: base, event: .touchUpInside)
      .eraseToAnyPublisher()
  }

}

public extension Publishers {

  struct ControlEvent<Control: UIControl>: Publisher {
    public typealias Output = Void
    public typealias Failure = Never

    let control: Control
    let event: Control.Event

    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
      let subscription = Subscription(subscriber, control, event)
      subscriber.receive(subscription: subscription)
    }
  }

}

extension Publishers.ControlEvent {

  class Subscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Void {
    let subscriber: S
    weak var control: Control?
    let event: Control.Event

    init(_ subscriber: S,
         _ control: Control,
         _ event: Control.Event
    ) {
      self.subscriber = subscriber
      self.control = control
      self.event = event
      setup()
    }
    func setup() {
      control?.addTarget(self, action: #selector(handleEvent), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
      // We don't care about the demand at this point.
      // As far as we're concerned - UIControl events are endless until the control is deallocated.
    }

    func cancel() {
      control?.removeTarget(self, action: #selector(handleEvent), for: event)
    }

    @objc func handleEvent() {
      guard control != nil else { return }
      _ = subscriber.receive()
    }
  }

}
