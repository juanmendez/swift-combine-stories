//
//  CombineTestCase.swift
//  CombineApp
//
//  Created by Mendez, Juan on 1/31/25.
//
import Foundation
import Combine
import XCTest

/// A test case class for testing Combine publishers.
/// This class provides utility methods to subscribe to publishers and handle their events.
/// This class extends XCTestCase.
class CombineTestCase: XCTestCase {
    private var cancellables: [AnyCancellable] = []

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }

    /// Subscribes to a publisher and handles its completion and value events.
    /// - Parameters:
    ///   - timeout: delay time to wait for expectation to complete
    ///   - publisher: The publisher to subscribe to.
    ///   - receiveCompletion: A closure to handle the completion event of the publisher.
    ///   - receiveValue: A closure to handle the value event of the publisher.
    func sink<O, F>(
        timeout: TimeInterval = 1,
        publisher: any Publisher<O, F>,
        receiveCompletion: @escaping ((Subscribers.Completion<F>) -> Void),
        receiveValue: @escaping ((O) -> Void)
    ) {
        let expectation = expectation(description: String(describing: publisher))
        publisher.sink(
            receiveCompletion: { receive in
                receiveCompletion(receive)
                expectation.fulfill()
            },
            receiveValue: { value in
                receiveValue(value)
            }
        ).store(in: &cancellables)

        waitForExpectations(timeout: timeout)
    }

    /// Subscribes to a publisher and handles its value events.
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - receiveValue: A closure to handle the value event of the publisher.
    func sink<O>(
        publisher: any Publisher<O, Never>,
        receiveValue: @escaping ((O) -> Void)
    ) {
        publisher.sink(
            receiveValue: { value in
                receiveValue(value)
            }
        ).store(in: &cancellables)
    }

    /// Retrieves the result of a Combine publisher.
    /// - Parameters:
    ///   - timeout: The time interval to wait for the expectation to complete.
    ///   - publisher: The publisher to subscribe to.
    /// - Returns: A `CombineTestResult` containing the values emitted by the publisher, a completion status, and an optional failure error.
    func getCombineTestResult<O, F>(
        timeout: TimeInterval = 1,
        publisher: any Publisher<O, F>
    ) -> CombineTestResult<O, F> where F: Error {
        let expectation = expectation(description: String(describing: publisher))
        var values = [O]()
        var isCompleted = false
        var failure: F? = nil

        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    isCompleted = true
                case .failure(let error):
                    failure = error
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                values.append(value)
            }
        ).store(in: &cancellables)

        waitForExpectations(timeout: timeout)

        return CombineTestResult<O, F>(values: values, isCompleted: isCompleted, failure: failure)
    }

    /// Retrieves the result of a Combine publisher that never fails.
    /// - Parameter publisher: The publisher to subscribe to.
    /// - Returns: A `CombineTestResult` containing the values emitted by the publisher and a completion status.
    func getCombineTestResult<O>(publisher: any Publisher<O, Never>) -> CombineTestResult<O, Never> {
        var values = [O]()

        publisher.sink(
            receiveValue: { value in
                values.append(value)
            }
        ).store(in: &cancellables)

        return CombineTestResult<O, Never>(values: values, isCompleted: true)
    }
}
