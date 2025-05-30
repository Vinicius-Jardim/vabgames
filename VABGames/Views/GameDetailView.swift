import SwiftUI
import UIKit

struct GameDetailView: View {
    let game: Game
    @AppStorage("MyLanguages") var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.dismiss) private var dismiss
    @State private var isSharePresented: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                if let imageUrl = game.backgroundImage {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                }
                
                // Game Info
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Rating
                    HStack(alignment: .top) {
                        Text(game.name ?? "")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        if let rating = game.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .bold()
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    if let released = game.released {
                        Text("Released: \(released)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Genres
                    if let genres = game.genres, !genres.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genres")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(genres) { genre in
                                        Text(genre.name)
                                            .font(.footnote)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Description
                    if let description = game.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            Text(description)
                                .font(.subheadline)
                                .lineLimit(3)
                        }
                    }
                    
                    // Platforms
                    if let platforms = game.parentPlatforms, !platforms.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Platforms")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(platforms, id: \.platform.id) { platform in
                                        HStack(spacing: 4) {
                                            getPlatformIcon(for: platform.platform.name)
                                            Text(platform.platform.name)
                                                .font(.footnote)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Screenshots
                    if let screenshots = game.shortScreenshots, !screenshots.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Screenshots")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(screenshots, id: \.id) { screenshot in
                                        AsyncImage(url: URL(string: screenshot.image)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Color.gray
                                        }
                                        .frame(width: 200, height: 120)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isSharePresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $isSharePresented) {
                    ActivityView(activityItems: [createShareText()])
                }
            }
        }
    }
    
    private func createShareText() -> String {
        var text = ""
        
        if let name = game.name {
            text += "Check out this game: \(name)\n"
        }
        
        if let rating = game.rating {
            text += "Rating: ⭐️ \(String(format: "%.1f", rating))\n"
        }
        
        if let released = game.released {
            text += "Released: \(released)\n"
        }
        
        if let genres = game.genres {
            let genreNames = genres.map { $0.name }.joined(separator: ", ")
            text += "Genres: \(genreNames)"
        }
        
        return text
    }
    
    private func getPlatformIcon(for platform: String) -> some View {
        let iconName: String
        switch platform.lowercased() {
        case "pc": iconName = "desktopcomputer"
        case "playstation", "ps4", "ps5": iconName = "playstation.logo"
        case "xbox": iconName = "xbox.logo"
        case "ios": iconName = "iphone"
        case "android": iconName = "candybarphone"
        case "linux": iconName = "terminal"
        case "nintendo": iconName = "gamecontroller"
        default: iconName = "gamecontroller"
        }
        return Image(systemName: iconName)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
