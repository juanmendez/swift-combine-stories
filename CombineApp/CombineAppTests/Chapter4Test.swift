import Combine
//
//  Chapter4Test.swift
//  CombineApp
//
//  Created by Mendez, Juan on 2/5/25.
//
import Foundation
import XCTest

class Chapter4Test: CombineTestCase {
    func testRunOnScheduler() {
        _ = getCombineTestResult(
            publisher: getUrlPublisher(url: "https://jsonplaceholder.typicode.com/posts")
                .subscribe(on: DispatchQueue(label: "A queue"))
        )
    }

    func testCustomPublisher() {
        _ = [0].publisher
            .isPrimeInteger()
            .sink {
                if let value = $0 {
                    print(value)
                } else {
                    print("nil")
                }
            }
    }

    func testSumOfIntengers() {
        let result = getCombineTestResult(
            publisher: [0, 1, 2, 3, 4]
                .publisher
                .sumOfIntegers()
        )
        
        XCTAssert(result.isCompleted, "subscription completes")
        XCTAssert(result.values.first == 10, "sum is equal to 10")
    }

}
