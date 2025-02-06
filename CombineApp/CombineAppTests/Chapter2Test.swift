import Combine
//
//  Chapter2.swift
//  CombineApp
//
//  Created by Mendez, Juan on 2/2/25.
//
import Foundation
import XCTest

class Chapter2Test: CombineTestCase {

    func testJust() {
        let _ = Just("Hello World")
            .sink { value in
                print("value is \(value)")
            }
    }

    func testNotificationCenter() {
        let notification = Notification(name: .NSSystemClockDidChange, object: nil)

        var isReceived = false

        sink(
            publisher: NotificationCenter.default.publisher(for: .NSSystemClockDidChange)
        ) { value in
            print("Notification received: \(value)")
            isReceived = true
        }

        NotificationCenter.default.post(notification)
        XCTAssertTrue(isReceived)
    }

    func testManipulateDataOperators() {
        let _ = [1, 5, 9]
            .publisher
            .map { $0 * $0 }
            .sink { print($0) }
    }

    func testDecoding() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

        struct Task: Decodable {
            let id: Int
            let title: String
            let userId: Int
            let body: String
        }

        let dataPublisher = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Task].self, decoder: JSONDecoder())

        sink(
            publisher: dataPublisher,
            receiveCompletion: { completion in
                print(completion)
            },
            receiveValue: { value in
                print(value)
            }
        )
    }

    func testSubjects() {
        let subject = PassthroughSubject<Int, Never>()

        sink(publisher: subject) { value in
            print("value is \(value)")
        }

        let _ = Just(29)
            .subscribe(subject)
    }

    func testFuture() {
        // (3) A simple use of Future, in a function
        enum FutureError: Error {
            case notMultiple
        }

        let future = Future<String, FutureError> { promise in
            let calendar = Calendar.current
            let second = calendar.component(.second, from: Date())
            print("second is \(second)")
            if second.isMultiple(of: 3) {
                promise(.success("We are successful: \(second)"))
            } else {
                promise(.failure(.notMultiple))
            }
        }.catch { error in
            Just("Caught the error")
        }
        .delay(for: .init(1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()

        sink(timeout: 2, publisher: future) { completion in
            print("completion \(completion)")
        } receiveValue: { value in
            print(value)
        }
    }
    
    
    func testChallenge() {
        let booleans = [true, false, true, false, true, true, false, true, false, true]
        
        var booleansReceived = [Bool]()
        
        sink(publisher: booleans.publisher.dropFirst(2)) { value in
            print("value is enabled \(value)")
            booleansReceived.append(value)
        }
        
        XCTAssertEqual(booleansReceived.count, booleans.count - 2)
    }
}
