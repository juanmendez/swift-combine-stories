//
//  Album.swift
//
//  Created by Mendez, Juan on 1/29/25.
//

import Foundation

struct Album: Codable {
    let albumId: Int
    let bandId: Int
    let name: String
    let year: Int
    let url: String
}
