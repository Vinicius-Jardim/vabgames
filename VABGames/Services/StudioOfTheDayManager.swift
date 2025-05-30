import Foundation
import SwiftUI

@MainActor
class StudioOfTheDayManager: ObservableObject {
    static let shared = StudioOfTheDayManager()
    
    @Published var currentStudio: Publisher?
    @Published var isLoading = false
    @Published var hasError = false
    
    private let defaults = UserDefaults.standard
    private let lastStudioDateKey = "lastStudioDate"
    private let viewedStudiosKey = "viewedStudios"
    private let currentStudioKey = "currentStudio"
    private let blacklistManager = BlacklistManager.shared
    private let apiService = APIService.shared
    
    private var lastStudioDate: Date {
        get {
            let timestamp = defaults.double(forKey: lastStudioDateKey)
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : .distantPast
        }
        set {
            defaults.set(newValue.timeIntervalSince1970, forKey: lastStudioDateKey)
            defaults.synchronize()
        }
    }
    
    private var viewedStudios: Set<Int64> {
        get {
            let array = defaults.array(forKey: viewedStudiosKey) as? [Int64] ?? []
            return Set(array)
        }
        set {
            defaults.set(Array(newValue), forKey: viewedStudiosKey)
            defaults.synchronize()
        }
    }
    
    private init() {
        // Tentar carregar o estúdio salvo
        if let savedData = defaults.data(forKey: currentStudioKey),
           let savedStudio = try? JSONDecoder().decode(Publisher.self, from: savedData) {
            self.currentStudio = savedStudio
        }
        
        // Iniciar carregamento assíncrono
        Task {
            await checkAndUpdateStudioOfTheDay()
        }
    }
    
    private func saveCurrentStudio() {
        if let studio = currentStudio,
           let encodedData = try? JSONEncoder().encode(studio) {
            defaults.set(encodedData, forKey: currentStudioKey)
            defaults.synchronize()
        }
    }
    
    func checkAndUpdateStudioOfTheDay() async {
        guard !isLoading else {
            print("Already loading studio of the day")
            return
        }
        
        isLoading = true
        hasError = false
        
        let calendar = Calendar.current
        let now = Date()
        
        print("Checking studio of the day - Last update: \(lastStudioDate)")
        print("Current studio: \(currentStudio?.name ?? "none")")
        
        if currentStudio == nil || !calendar.isDate(lastStudioDate, inSameDayAs: now) {
            print("Need to update studio of the day")
            await selectNewStudioOfTheDay()
        } else {
            print("Studio of the day is up to date")
        }
        
        isLoading = false
    }
    
    private func selectNewStudioOfTheDay() async {
        do {
            print("Selecting new studio of the day")
            var selectedPublisher: Publisher?
            var attempts = 0
            let maxAttempts = 5
            
            while selectedPublisher == nil && attempts < maxAttempts {
                print("Attempt \(attempts + 1) to fetch random publisher")
                let publisher = try await apiService.fetchRandomPublisher()
                
                if publisher.gamesCount > 0 && !publisher.imageBackground.isEmpty &&
                   !blacklistManager.isBlacklisted(Int64(publisher.id)) &&
                   !viewedStudios.contains(publisher.id) {
                    selectedPublisher = publisher
                    print("Found suitable publisher: \(publisher.name)")
                    break
                } else {
                    print("Publisher \(publisher.name) was rejected: games=\(publisher.gamesCount), hasImage=\(!publisher.imageBackground.isEmpty)")
                }
                attempts += 1
            }
            
            if let publisher = selectedPublisher {
                print("Setting new studio of the day: \(publisher.name)")
                self.currentStudio = publisher
                self.lastStudioDate = Date()
                var studios = self.viewedStudios
                studios.insert(publisher.id)
                self.viewedStudios = studios
                self.saveCurrentStudio()
                self.hasError = false
            } else {
                print("Failed to find a suitable publisher after \(attempts) attempts")
                self.hasError = true
                // Tentar usar qualquer publisher do cache
                let publishers = try await apiService.fetchPublishers(page: 1)
                if let randomPublisher = publishers.filter({ $0.gamesCount > 0 && !$0.imageBackground.isEmpty }).randomElement() {
                    print("Using cached publisher as fallback: \(randomPublisher.name)")
                    self.currentStudio = randomPublisher
                    self.lastStudioDate = Date()
                    self.saveCurrentStudio()
                    self.hasError = false
                }
            }
        } catch {
            print("Error selecting studio of the day: \(error)")
            self.hasError = true
        }
    }
    
    func markStudioAsViewed(_ publisher: Publisher) {
        var studios = viewedStudios
        studios.insert(publisher.id)
        viewedStudios = studios
    }
}
