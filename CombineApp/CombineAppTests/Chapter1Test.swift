import Combine
import Testing
//
//  SwiftTeting101g.swift
//  unit testing
//
//  Created by Mendez, Juan on 1/30/25.
//
import XCTest

final class Chapter1Test: CombineTestCase {
    var cancellables = [] as Set<AnyCancellable>

    // "Just is similar to Rx.Just"
    func testHowJustWorks() {
        let _ = Just("Hello world").sink { print($0) }
    }

    // "Publisher is similar to a Flowable"
    func testHowPublisherEmitsResults() {
        let fruits = ["apple", "banana", "orange"]
        let publisher = Publishers.Sequence<[String], Never>(sequence: fruits)
        let _ = publisher.sink { print($0) }
    }

    func testFetchingBandsFromJson() {
        // in Kotlin we assign the type of T like this getJson<List<Band>>("bands")
        // in Swift, the call result is casted instead. (getJson("bands") as Future<[Band], Error>)
        
        let combineTestResult = getCombineTestResult(
            publisher: (parseJson("bands") as Future<[Band], Error>).delay(for: .milliseconds(10), scheduler: RunLoop.main)
        )
        
        XCTAssertTrue(combineTestResult.isCompleted)
        let bands = combineTestResult.values.first ?? []
        XCTAssertTrue(!bands.isEmpty)
    }

    func testFileNotFoundError() {
        let combineTestResult = getCombineTestResult(
            publisher: (parseJson("bandas") as Future<[Band], Error>).delay(for: .milliseconds(10), scheduler: RunLoop.main)
        )
        
        XCTAssertFalse(combineTestResult.isCompleted)
        XCTAssertNotNil(combineTestResult.failure)
    }

    func testFindSongsByExpectedBandWithSinglePublisher() {
        let bandName = "Guns n’ Roses"
        var selectedBand = Band()

        /**
         - fetch all bands
         - search for band which is named as bandName
         - fetch all songs
         - search for songs whose bandId matches band found
         */

        let publisher = (parseJson("bands") as Future<[Band], Error>)
            .map { bands in
                selectedBand = bands.first(where: { $0.name == bandName }) ?? Band(bandId: 0, name: "")
                return selectedBand
            }
            .flatMap {
                band in
                (self.parseJson("songs") as Future<[Song], Error>).map { songs in
                    songs.filter { $0.bandId == band.bandId }
                }
            }.eraseToAnyPublisher()

        let combineTestResult = getCombineTestResult(publisher: publisher)
        XCTAssertTrue(combineTestResult.isCompleted)

        let songs = combineTestResult.values.first ?? []
        XCTAssertTrue(!songs.isEmpty)
        XCTAssertTrue(songs.allSatisfy({ $0.bandId == selectedBand.bandId }))
    }

    func testFindSongsByExpectedBandHavingSeveralPublishers() {
        let bandName = "Guns n’ Roses"
        var selectedBand = Band()

        /**
         - fetch all bands
         - search for band which is named as bandName
         - fetch all songs
         - search for songs whose bandId matches band found
         */
        let bandsPublisher: Future<[Band], Error> = parseJson("bands")

        let matchBandPublisher = bandsPublisher.map { bands in
            selectedBand = bands.first(where: { $0.name == bandName }) ?? Band(bandId: 0, name: "")
            return selectedBand
        }

        let songsPublisher = (self.parseJson("songs") as Future<[Song], Error>)

        let matchSongsPublisher = matchBandPublisher.flatMap { band in
            songsPublisher.map { songs in
                songs.filter { $0.bandId == band.bandId }
            }
        }

        let combineTestResult = getCombineTestResult(publisher: matchSongsPublisher)
        XCTAssertTrue(combineTestResult.isCompleted)

        let songs = combineTestResult.values.first ?? []
        XCTAssertTrue(!songs.isEmpty)
        XCTAssertTrue(songs.allSatisfy({ $0.bandId == selectedBand.bandId }))
    }

    /**
     Combine clearly has highly been influenced by Rx. Subject and Behavior in Rx  are detached publishers which can emit values when initialized.
     Here we see a subject emitting a value after it is being subscribed.
     */
    func testPassThroughSubjectTest() {
        var receivedValue: [Int] = []
        let subject = PassthroughSubject<Int, Never>()

        let _ = sink(publisher: subject, receiveValue: { receivedValue.append($0) })

        subject.send(1)
    }
}
