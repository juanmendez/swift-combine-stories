//
//  CombineTestCase.swift
//  CombineApp
//
//  Created by Mendez, Juan on 1/31/25.
//

import Combine
import Foundation
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

    /// Subscribes to a publisher and handles its completion and value events.
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - receiveCompletion: A closure to handle the completion event of the publisher.
    ///   - receiveValue: A closure to handle the value event of the publisher.
    func subscribe<O, F>(
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

        waitForExpectations(timeout: 1)
    }

    /// Subscribes to a publisher and handles its value events.
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - receiveValue: A closure to handle the value event of the publisher.
    func subscribe<O>(
        publisher: any Publisher<O, Never>,
        receiveValue: @escaping ((O) -> Void)
    ) {
        publisher.sink(
            receiveValue: { value in
                receiveValue(value)
            }
        ).store(in: &cancellables)
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}
