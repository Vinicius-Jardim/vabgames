//
//  SettingsManager.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation
import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var pageSize: Int = UserDefaults.standard.integer(forKey: "pageSize") {
        didSet {
            UserDefaults.standard.set(pageSize, forKey: "pageSize")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var notificationTime: Date = {
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            return savedTime
        }
        var components = DateComponents()
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }() {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var cacheExpirationHours: Int = UserDefaults.standard.integer(forKey: "cacheExpirationHours") {
        didSet {
            UserDefaults.standard.set(cacheExpirationHours, forKey: "cacheExpirationHours")
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var selectedLanguage: String = {
        if let languages = UserDefaults.standard.stringArray(forKey: "MyLanguages"),
           let first = languages.first {
            return first
        }
        return Locale.current.language.languageCode?.identifier ?? "en"
    }() {
        didSet {
            UserDefaults.standard.set([selectedLanguage], forKey: "MyLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        // Set default values if not already set
        if UserDefaults.standard.integer(forKey: "pageSize") == 0 {
            pageSize = 20
            UserDefaults.standard.set(pageSize, forKey: "pageSize")
        }
        
        if UserDefaults.standard.integer(forKey: "cacheExpirationHours") == 0 {
            cacheExpirationHours = 24
            UserDefaults.standard.set(cacheExpirationHours, forKey: "cacheExpirationHours")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func clearCache() {
        print("Clearing cache...")
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        
        // Remove cache-related keys
        let keysToRemove = ["cached_publishers", "currentStudio", "lastStudioDate", "viewedStudios"]
        keysToRemove.forEach { key in
            defaults.removeObject(forKey: key)
            print("Removed cache for key: \(key)")
        }
        
        // Remove any other cached data
        allKeys.forEach { key in
            if key.hasPrefix("cached_") {
                defaults.removeObject(forKey: key)
                print("Removed cache for key: \(key)")
            }
        }
        
        defaults.synchronize()
        
        // Notify other objects that cache was cleared
        NotificationCenter.default.post(name: NSNotification.Name("CacheCleared"), object: nil)
        
        objectWillChange.send()
        print("Cache cleared successfully")
    }
    
    func isCacheExpired(for key: String) -> Bool {
        guard let lastUpdate = UserDefaults.standard.object(forKey: "\(key)_lastUpdate") as? Date else {
            return true
        }
        
        let expirationInterval = TimeInterval(cacheExpirationHours * 3600)
        return Date().timeIntervalSince(lastUpdate) > expirationInterval
    }
    
    func updateCacheTimestamp(for key: String) {
        UserDefaults.standard.set(Date(), forKey: "\(key)_lastUpdate")
        UserDefaults.standard.synchronize()
    }
}
