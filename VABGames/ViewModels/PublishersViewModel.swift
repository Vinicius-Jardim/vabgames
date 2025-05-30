//
//  PublishersViewModel.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation

@MainActor
class PublishersViewModel: ObservableObject {
    @Published var publishers: [Publisher] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasMorePages = false
    private var currentPage = 1
    
    private let defaults = UserDefaults.standard
    private let publishersKey = "cached_publishers"
    
    init() {
        loadCachedPublishers()
        Task {
            await loadPublishers()
        }
    }
    
    private func loadCachedPublishers() {
        if let data = defaults.data(forKey: publishersKey),
           let cachedPublishers = try? JSONDecoder().decode([Publisher].self, from: data) {
            self.publishers = cachedPublishers
            print("Loaded \(cachedPublishers.count) publishers from cache")
        }
    }
    
    private func savePublishers() {
        if let data = try? JSONEncoder().encode(publishers) {
            defaults.set(data, forKey: publishersKey)
            defaults.synchronize()
            print("Saved \(publishers.count) publishers to cache")
        }
    }
    
    func loadPublishers() async {
        guard !isLoading else {
            print("Already loading publishers")
            return
        }
        
        isLoading = true
        do {
            print("Fetching publishers from API")
            publishers = try await APIService.shared.fetchPublishers()
            hasMorePages = !publishers.isEmpty
            currentPage = 1
            savePublishers()
            error = nil
        } catch {
            print("Error loading publishers: \(error)")
            self.error = error
            // Se falhar e não tivermos publishers no cache, tentar novamente
            if publishers.isEmpty {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
                await loadPublishers()
            }
        }
        isLoading = false
    }
    
    func loadMorePublishers() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        do {
            print("Loading more publishers, page: \(currentPage + 1)")
            let newPublishers = try await APIService.shared.fetchPublishers(page: currentPage + 1)
            if !newPublishers.isEmpty {
                publishers.append(contentsOf: newPublishers)
                currentPage += 1
                hasMorePages = true
                savePublishers()
            } else {
                hasMorePages = false
            }
            error = nil
        } catch {
            print("Error loading more publishers: \(error)")
            self.error = error
            hasMorePages = false
        }
        isLoading = false
    }
    
    func refreshPublishers() async {
        print("Refreshing publishers")
        currentPage = 1
        await loadPublishers()
    }
}
