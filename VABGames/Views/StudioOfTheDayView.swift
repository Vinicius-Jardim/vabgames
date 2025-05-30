import SwiftUI

struct StudioOfTheDayView: View {
    @StateObject private var studioManager = StudioOfTheDayManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        Group {
            if studioManager.isLoading {
                loadingView
            } else if let studio = studioManager.currentStudio {
                studioCard(studio)
            } else if studioManager.hasError {
                errorView
            } else {
                emptyView
            }
        }
        .onAppear {
            if studioManager.currentStudio == nil && !studioManager.isLoading {
                Task {
                    await studioManager.checkAndUpdateStudioOfTheDay()
                }
            }
        }
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(.white)
            Spacer()
        }
        .frame(height: 80)
        .background(cardBackground)
    }
    
    private func studioCard(_ studio: Publisher) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label("studio_of_the_day".localised(using: settingsManager.selectedLanguage),
                      systemImage: "star.fill")
                    .font(.headline)
                    .foregroundColor(.yellow)
                Spacer()
            }
            
            HStack(spacing: 15) {
                AsyncImage(url: URL(string: studio.imageBackground)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(studio.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                        Text("\(studio.gamesCount) \("games".localised(using: settingsManager.selectedLanguage))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    
                    if let description = studio.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                }
            }
            
            NavigationLink(destination: PublisherDetailView(publisher: studio)) {
                HStack {
                    Text("view_details".localised(using: settingsManager.selectedLanguage))
                    Image(systemName: "arrow.right")
                }
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.purple.opacity(0.6))
                )
            }
        }
        .padding()
        .background(cardBackground)
    }
    
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundColor(.orange)
            
            Text("failed_to_load_studio".localised(using: settingsManager.selectedLanguage))
                .foregroundColor(.white)
            
            Button("retry".localised(using: settingsManager.selectedLanguage)) {
                Task {
                    await studioManager.checkAndUpdateStudioOfTheDay()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }
    
    private var emptyView: some View {
        Text("no_studio_available".localised(using: settingsManager.selectedLanguage))
            .foregroundColor(.white.opacity(0.7))
            .padding()
            .frame(maxWidth: .infinity)
            .background(cardBackground)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white.opacity(0.2))
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}
