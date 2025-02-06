//
//  Bands.swift
//
//  Created by Mendez, Juan on 1/29/25.
//

import Foundation

struct Song: Codable {
    let songId: Int
    let name: String
    let time: String
    let bandId: Int
    let albumId: Int
}
