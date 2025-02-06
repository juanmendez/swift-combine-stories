//
//  CombineTestResult.swift
//  CombineApp
//
//  Created by Mendez, Juan on 2/5/25.
//

/// A struct representing the result of a Combine publisher test.
/// - Parameters:
///   - O: The type of values emitted by the publisher.
///   - F: The type of error that the publisher might emit.
struct CombineTestResult<O, F> where F : Error {
    var values = [O]()
    var isCompleted = false
    var failure: F? = nil

    init(values: [O], isCompleted: Bool = false, failure: F? = nil) {
        self.values = values
        self.isCompleted = isCompleted
        self.failure = failure
    }
}
