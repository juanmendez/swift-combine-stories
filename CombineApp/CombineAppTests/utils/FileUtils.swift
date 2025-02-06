//
//  FileUtils.swift
//  CombineApp
//
//  Created by Mendez, Juan on 1/31/25.
//
import XCTest
import Combine

/// An extension of XCTestCase to provide utility methods for parsing JSON files.
extension XCTestCase {
    /// Parses a JSON file and returns a Future with the decoded object.
    /// - Parameter jsonFile: The name of the JSON file to parse (without the .json extension).
    /// - Returns: A Future that will provide the decoded object or an error.
    func parseJson<T: Codable>(_ jsonFile: String) -> Future<T, Error> {
        return Future { promise in
            if let url = Bundle(for: type(of: self)).url(forResource: jsonFile, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let t = try JSONDecoder().decode(T.self, from: data)
                    promise(.success(t))
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.failure(FileNotFoundError(file: "\(jsonFile).json")))
            }
        }
    }
}

/// An error representing a file-related issue.
/// - file: The name of the file that caused the error.
struct FileNotFoundError: Error {
    var file: String
}
