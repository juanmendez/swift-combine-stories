//
//  Band.swift
//
//  Created by Mendez, Juan on 1/29/25.
//

import Foundation

struct Band: Codable {
    let bandId: Int
    let name: String

    init(bandId: Int = 0, name: String = "") {
        self.bandId = bandId
        self.name = name
    }
}
