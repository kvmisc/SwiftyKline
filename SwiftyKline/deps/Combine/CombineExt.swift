//
//  CombExt.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public func comb_pack<O, P>(_ o: O,
                            _ p: P
) -> AnyPublisher<(O.Output,P.Output),O.Failure> where O: Publisher, P: Publisher, O.Failure == P.Failure {
  o.combineLatest(p).eraseToAnyPublisher()
}

public func comb_pack<O, P, Q>(_ o: O,
                               _ p: P,
                               _ q: Q
) -> AnyPublisher<(O.Output,P.Output,Q.Output),O.Failure> where O: Publisher, P: Publisher, Q: Publisher, O.Failure == P.Failure, P.Failure == Q.Failure {
  o.combineLatest(p, q).eraseToAnyPublisher()
}

public func comb_pack<O, P, Q, R>(_ o: O,
                                  _ p: P,
                                  _ q: Q,
                                  _ r: R
) -> AnyPublisher<(O.Output,P.Output,Q.Output,R.Output),O.Failure> where O: Publisher, P: Publisher, Q: Publisher, R: Publisher, O.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
  o.combineLatest(p, q, r).eraseToAnyPublisher()
}


public extension Subscribers.Completion {

  var isFinished: Bool {
    if case .finished = self {
      return true
    }
    return false
  }

  var isFailure: Bool {
    if case .failure = self {
      return true
    }
    return false
  }

}
