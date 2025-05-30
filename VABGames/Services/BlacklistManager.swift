//
//  BlacklistManager.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import CoreData
import SwiftUI

class BlacklistManager: ObservableObject {
    static let shared = BlacklistManager()
    @Published private(set) var blacklistedIds: Set<Int64> = []
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = PersistenceController.shared.container.viewContext
        loadBlacklistedIds()
    }
    
    private func loadBlacklistedIds() {
        let request = NSFetchRequest<BlacklistedPublisher>(entityName: "BlacklistedPublisher")
        
        do {
            let blacklistedPublishers = try viewContext.fetch(request)
            blacklistedIds = Set(blacklistedPublishers.compactMap { $0.id })
        } catch {
            print("Error loading blacklisted publishers: \(error)")
        }
    }
    
    func isBlacklisted(_ publisherId: Int64) -> Bool {
        blacklistedIds.contains(publisherId)
    }
    
    func addToBlacklist(_ publisherId: Int64, name: String) {
        guard !isBlacklisted(publisherId) else { return }
        
        viewContext.perform {
            let blacklistedPublisher = BlacklistedPublisher(context: self.viewContext)
            blacklistedPublisher.id = publisherId
            blacklistedPublisher.name = name
            blacklistedPublisher.timestamp = Date()
            
            do {
                try self.viewContext.save()
                DispatchQueue.main.async {
                    self.blacklistedIds.insert(publisherId)
                    self.objectWillChange.send()
                }
            } catch {
                print("Error saving blacklisted publisher: \(error)")
            }
        }
    }
    
    func removeFromBlacklist(_ publisherId: Int64) {
        let request = NSFetchRequest<BlacklistedPublisher>(entityName: "BlacklistedPublisher")
        request.predicate = NSPredicate(format: "id == %lld", publisherId)
        
        viewContext.perform {
            do {
                let publishers = try self.viewContext.fetch(request)
                publishers.forEach { self.viewContext.delete($0) }
                try self.viewContext.save()
                
                DispatchQueue.main.async {
                    self.blacklistedIds.remove(publisherId)
                    self.objectWillChange.send()
                }
            } catch {
                print("Error removing publisher from blacklist: \(error)")
            }
        }
    }
}
