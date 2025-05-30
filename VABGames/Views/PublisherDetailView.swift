//
//  PublisherDetailView.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import SwiftUI

struct PublisherDetailView: View {
    let publisher: Publisher
    @StateObject private var viewModel = PublisherDetailViewModel()
    @StateObject private var blacklistManager = BlacklistManager.shared
    @AppStorage("MyLanguages") var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        List {
            // Publisher Header
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: URL(string: publisher.imageBackground)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .clipped()
                
                Text(publisher.name)
                    .font(.title)
                    .bold()
                
                if let description = publisher.description {
                    Text(description)
                        .font(.body)
                } else {
                    Text("no_description".localised(using: currentLanguages))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Text(String(format: "games_per_page".localised(using: currentLanguages), publisher.gamesCount))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .listRowInsets(EdgeInsets())
            
            // Games List
            Section("games".localised(using: currentLanguages)) {
                if viewModel.games.isEmpty {
                    Text("no_results".localised(using: currentLanguages))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.games) { game in
                        NavigationLink {
                            GameDetailView(game: game)
                        } label: {
                            GameRowView(game: game)
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView("loading".localised(using: currentLanguages))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadGames(for: publisher.id)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    blacklistManager.addToBlacklist(publisher.id, name: publisher.name)
                }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct GameRowView: View {
    let game: Game
    @AppStorage("MyLanguages") var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = game.backgroundImage {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 120)
                .clipped()
            }
            
            Text(game.name ?? "")
                .font(.headline)
                .lineLimit(2)
            
            if let released = game.released {
                Text("Released: \(released)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let rating = game.rating {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                }
            }
        }
        .padding(.vertical, 8)
    }
}
