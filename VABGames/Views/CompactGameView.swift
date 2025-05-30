import SwiftUI

struct CompactGameView: View {
    let game: Game
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = game.backgroundImage {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(game.name ?? "")
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.white)
                
                HStack {
                    if let rating = game.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .bold()
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                    }
                    
                    if let released = game.released {
                        Text(released)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .background(Color.clear)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
