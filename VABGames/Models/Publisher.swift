//
//  Publisher.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation

struct Publisher: Codable, Identifiable {
    let id: Int64
    let name: String
    let imageBackground: String
    let gamesCount: Int
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageBackground = "image_background"
        case gamesCount = "games_count"
        case description
    }
}

struct PublisherResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Publisher]
}
