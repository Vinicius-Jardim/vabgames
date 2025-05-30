//
//  Game.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation

struct Game: Codable, Identifiable {
    let id: Int
    let slug, name, description: String?
    let backgroundImage: String?
    let backgroundImageAdditional: String?
    let genres: [Genre]?
    let rating: Double?
    let released: String?
    let publishers: [Developer]?
    let ratings: [Rating]?
    let parentPlatforms: [ParentPlatform]?
    let platforms: [PlatformElement]?
    let metacriticURL: String?
    let redditURL: String?
    let shortScreenshots: [ShortScreenshot]?

    enum CodingKeys: String, CodingKey {
        case id, slug, name, description
        case backgroundImage = "background_image"
        case backgroundImageAdditional = "background_image_additional"
        case genres
        case rating
        case released
        case publishers
        case ratings
        case parentPlatforms = "parent_platforms"
        case platforms
        case metacriticURL = "metacritic_url"
        case redditURL = "reddit_url"
        case shortScreenshots = "short_screenshots"
    }
}

struct Developer: Codable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let imageBackground: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case imageBackground = "image_background"
    }
}

struct Rating: Codable, Equatable {
    let id: Int
    let title: String
    let count: Int
    let percent: Double
}

struct ParentPlatform: Codable {
    let platform: Platform
}

struct Platform: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
}

struct PlatformElement: Codable {
    let platform: Platform
    let requirements: Requirements?
}

struct Requirements: Codable {
    let minimum, recommended: String?
}

struct ShortScreenshot: Codable {
    let id: Int
    let image: String
}

struct GameResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Game]
}
