import Combine
//
//  Chapter2.swift
//  CombineApp
//
//  Created by Mendez, Juan on 2/2/25.
//
import Foundation
import XCTest
import Combine

final class Chapter3Test: CombineTestCase {
    func testDataPublisher() {
        sink(
            publisher: getUrlPublisher(url: "https://jsonplaceholder.typicode.com/posts"),
            receiveCompletion: { completion in },
            receiveValue: { value in
                XCTAssertTrue(!value.isEmpty)
            }
        )
    }

    func testHandlingPublisherError() {

        let urlPublisher = getUrlPublisher(url: "https://jsonplaceholder.typicode.com/postssss")
            .mapError { error in
                switch error {
                case URLError.cannotFindHost:
                    return APIError.networkError(error: error.localizedDescription)
                default:
                    return APIError.responseError(error: error.localizedDescription)
                }
            }

        let assertion = getCombineTestResult(publisher: urlPublisher)
        XCTAssertFalse(assertion.isCompleted)
        XCTAssertTrue(assertion.values.isEmpty)
    }

    func testSwitchingToAnotherPublisher() {

        let urlPublisher = getUrlPublisher(url: "https://jsonplaceholder.typicode.com/postssss")
            .catch { _ in
                getUrlPublisher(url: "https://jsonplaceholder.typicode.com/posts")
            }
            .mapError { error in
                switch error {
                case URLError.cannotFindHost:
                    return APIError.networkError(error: error.localizedDescription)
                default:
                    return APIError.responseError(error: error.localizedDescription)
                }
            }.eraseToAnyPublisher()

        sink(
            publisher: urlPublisher,
            receiveCompletion: { completion in
                print("completion \(completion)")
            },
            receiveValue: { value in
                XCTAssertTrue(!value.isEmpty)
            }
        )
    }
    
    func testChallenge() {
        let urlPublisher = getUrlPublisher(url: "https://jsonplaceholder.typicode.com/posts")
            .map{ posts in
                posts.first?.title ?? ""
            }
        
        let result = getCombineTestResult(publisher: urlPublisher)
        XCTAssertTrue(result.isCompleted)
        XCTAssertTrue(result.values.first?.isEmpty == false)
    }
}
