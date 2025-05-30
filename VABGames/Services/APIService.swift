//
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

@MainActor
class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.rawg.io/api"
    private let apiKey = "12dab7a87f544b8fb0bb5849d926660e"
    private let cacheManager = CacheManager.shared
    private let settings = SettingsManager.shared
    
    private init() {}
    
    func fetchPublishers(page: Int = 1) async throws -> [Publisher] {
        // Se for página 1, tentar obter do cache primeiro
        if page == 1, let cachedPublishers = await cacheManager.getCachedPublishers() {
            return cachedPublishers
        }
        
        // Se não estiver no cache ou for outra página, buscar da API
        let pageSize = settings.pageSize
        let endpoint = "\(baseURL)/publishers?key=\(apiKey)&page=\(page)&page_size=\(pageSize)"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let publisherResponse = try JSONDecoder().decode(PublisherResponse.self, from: data)
            // Salvar no cache apenas a primeira página
            if page == 1 {
                await cacheManager.cachePublishers(publisherResponse.results)
            }
            return publisherResponse.results
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func fetchGamesForPublisher(publisherId: Int64) async throws -> [Game] {
        // Tentar obter do cache primeiro
        if let cachedGames = await cacheManager.getCachedGames(forPublisher: publisherId) {
            return cachedGames
        }
        
        // Se não estiver no cache, buscar da API
        let endpoint = "\(baseURL)/games?key=\(apiKey)&publishers=\(publisherId)"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let gameResponse = try JSONDecoder().decode(GameResponse.self, from: data)
            await cacheManager.cacheGames(gameResponse.results, forPublisher: publisherId)
            return gameResponse.results
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func fetchRandomPublisher() async throws -> Publisher {
        print("Fetching random publisher")
        let pageSize = 40 // Aumentando o tamanho da página para ter mais opções
        let page = Int.random(in: 1...5)
        let endpoint = "\(baseURL)/publishers?key=\(apiKey)&page=\(page)&page_size=\(pageSize)&ordering=-games_count"
        
        print("Random publisher endpoint: \(endpoint)")
        guard let url = URL(string: endpoint) else {
            print("Invalid URL for random publisher")
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response for random publisher")
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let publisherResponse = try decoder.decode(PublisherResponse.self, from: data)
            
            // Filtrar publishers com jogos e imagens
            let validPublishers = publisherResponse.results.filter { publisher in
                publisher.gamesCount > 0 && !publisher.imageBackground.isEmpty
            }
            
            print("Found \(validPublishers.count) valid publishers")
            
            guard let randomPublisher = validPublishers.randomElement() else {
                print("No valid publishers found")
                throw APIError.invalidResponse
            }
            
            print("Selected random publisher: \(randomPublisher.name)")
            return randomPublisher
        } catch {
            print("Error fetching random publisher: \(error)")
            throw error
        }
    }
    
    func fetchRandomGame() async throws -> Game {
        // Primeiro tentar obter publishers do cache
        let endpoint = "\(baseURL)/publishers?key=\(apiKey)&page=1&page_size=20"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let results = json?["results"] as? [[String: Any]] {
                let publishers = results.compactMap { publisherDict -> Publisher? in
                    guard let publisherData = try? JSONSerialization.data(withJSONObject: publisherDict) else { return nil }
                    return try? decoder.decode(Publisher.self, from: publisherData)
                }
                
                // Filtrar publishers que não estão na blacklist
                let availablePublishers = publishers.filter {
                    !BlacklistManager.shared.isBlacklisted($0.id)
                }
                
                // Selecionar um publisher aleatório
                guard let randomPublisher = availablePublishers.randomElement() else {
                    throw APIError.invalidResponse
                }
                
                // Buscar jogos do publisher
                let gamesEndpoint = "\(baseURL)/games?key=\(apiKey)&publishers=\(randomPublisher.id)"
                guard let gamesUrl = URL(string: gamesEndpoint) else {
                    throw APIError.invalidURL
                }
                
                let (gamesData, gamesResponse) = try await URLSession.shared.data(from: gamesUrl)
                
                guard let gamesHttpResponse = gamesResponse as? HTTPURLResponse,
                      (200...299).contains(gamesHttpResponse.statusCode) else {
                    throw APIError.invalidResponse
                }
                
                if let gamesJson = try JSONSerialization.jsonObject(with: gamesData) as? [String: Any],
                   let gamesResults = gamesJson["results"] as? [[String: Any]] {
                    let games = gamesResults.compactMap { gameDict -> Game? in
                        guard let gameData = try? JSONSerialization.data(withJSONObject: gameDict) else { return nil }
                        return try? decoder.decode(Game.self, from: gameData)
                    }
                    
                    // Selecionar um jogo aleatório
                    guard let randomGame = games.randomElement() else {
                        throw APIError.invalidResponse
                    }
                    
                    return randomGame
                }
            }
            
            throw APIError.invalidResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
