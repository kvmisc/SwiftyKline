//
//  MapToEvent.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Publisher where Failure == Never {

  func mapToEvent(_ h: @escaping (Output)->Bool) -> AnyPublisher<Void,Never> {
    filter(h)
      .map { _ in () }
      .eraseToAnyPublisher()
  }

}
