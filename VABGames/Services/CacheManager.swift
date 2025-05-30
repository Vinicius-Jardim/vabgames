//
//  CacheManager.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation

@MainActor
class CacheManager {
    static let shared = CacheManager()
    private let userDefaults = UserDefaults.standard
    private let settings = SettingsManager.shared
    
    private init() {}
    
    // Chaves para cache
    private struct CacheKey {
        static let publishers = "cached_publishers"
        static let publisherGames = "cached_publisher_games_"
        static let timestamp = "_timestamp"
    }
    
    // MARK: - Cache Operations
    
    func cachePublishers(_ publishers: [Publisher]) {
        if let encoded = try? JSONEncoder().encode(publishers) {
            userDefaults.set(encoded, forKey: CacheKey.publishers)
            userDefaults.set(Date(), forKey: CacheKey.publishers + CacheKey.timestamp)
        }
    }
    
    func cacheGames(_ games: [Game], forPublisher publisherId: Int64) {
        if let encoded = try? JSONEncoder().encode(games) {
            let key = CacheKey.publisherGames + "\(publisherId)"
            userDefaults.set(encoded, forKey: key)
            userDefaults.set(Date(), forKey: key + CacheKey.timestamp)
        }
    }
    
    func getCachedPublishers() -> [Publisher]? {
        guard let timestamp = userDefaults.object(forKey: CacheKey.publishers + CacheKey.timestamp) as? Date,
              isValid(timestamp),
              let data = userDefaults.data(forKey: CacheKey.publishers),
              let publishers = try? JSONDecoder().decode([Publisher].self, from: data)
        else {
            return nil
        }
        return publishers
    }
    
    func getCachedGames(forPublisher publisherId: Int64) -> [Game]? {
        let key = CacheKey.publisherGames + "\(publisherId)"
        guard let timestamp = userDefaults.object(forKey: key + CacheKey.timestamp) as? Date,
              isValid(timestamp),
              let data = userDefaults.data(forKey: key),
              let games = try? JSONDecoder().decode([Game].self, from: data)
        else {
            return nil
        }
        return games
    }
    
    // MARK: - Helper Methods
    
    private func isValid(_ timestamp: Date) -> Bool {
        let expirationHours = settings.cacheExpirationHours
        let expirationDate = timestamp.addingTimeInterval(TimeInterval(expirationHours * 3600))
        return Date() < expirationDate
    }
    
    func clearExpiredCache() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        
        for key in allKeys {
            if key.hasPrefix("cached_") && key.hasSuffix("_timestamp") {
                if let timestamp = userDefaults.object(forKey: key) as? Date,
                   !isValid(timestamp) {
                    let baseKey = key.replacingOccurrences(of: CacheKey.timestamp, with: "")
                    userDefaults.removeObject(forKey: baseKey)
                    userDefaults.removeObject(forKey: key)
                }
            }
        }
    }
}
