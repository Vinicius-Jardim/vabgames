//
//  PublisherDetailViewModel.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation

@MainActor
class PublisherDetailViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadGames(for publisherId: Int64) async {
        isLoading = true
        do {
            games = try await APIService.shared.fetchGamesForPublisher(publisherId: publisherId)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
