import Combine
//
//  PostUtils.swift
//  CombineApp
//
//  Created by Mendez, Juan on 2/5/25.
//
import Foundation
import XCTest

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

enum APIError: Error {
    case networkError(error: String)
    case responseError(error: String)
    case unknownError
}

func getUrlPublisher(url: String) -> AnyPublisher<[Post], Error> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
        .map { $0.data }
        .decode(type: [Post].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

extension Publishers.Sequence {

    func isPrimeInteger<T:BinaryInteger>() -> Publishers.CompactMap<Self, T?> where T == Self.Output {
        compactMap { self.getAnyPrime($0) }
    }
    
    func getAnyPrime<T: BinaryInteger>(_ n: T) -> T? {
        guard n != 2 else { return n }
        guard n % 2 != 0 && n > 1 else { return nil }

        var i = 3
        while i * i <= n {
            if (Int(n) % i) == 0 {
                return nil
            }
            i += 2
        }

        return n
    }
    
    func sumOfIntegers<T:BinaryInteger>() -> Publishers.Map<Publishers.Collect<Self>, T> where T == Self.Output {
        collect()
            .map { values in
                return  values.reduce(0, +)
            }
    }
}
