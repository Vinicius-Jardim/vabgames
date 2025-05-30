import SwiftUI

struct ShakeForGameView: View {
    @StateObject private var motionManager = MotionManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var currentGame: Game?
    @State private var isLoading = false
    @State private var showingGameDetail = false

    var body: some View {
        ZStack {
            // Gradiente de fundo
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.orange.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Ícone que muda com o shake
                    Image(systemName: motionManager.isShaking ? "iphone.gen3.radiowaves.left.and.right" : "iphone.gen3")
                        .font(.system(size: 60))
                        .foregroundColor(motionManager.isShaking ? .orange : .white)
                        .animation(.default, value: motionManager.isShaking)
                    
                    // Texto "Shake for Random"
                    Text("shake_for_random".localised(using: settingsManager.selectedLanguage))
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                    
                    // Botão de teste
                    Button(action: getRandomGame) {
                        Text("test_notification".localised(using: settingsManager.selectedLanguage))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    
                    // Loading ou exibição do jogo
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if let game = currentGame {
                        NavigationLink(destination: GameDetailView(game: game)) {
                            CompactGameView(game: game)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.3)) // Fundo translúcido
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                                )
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("shake_for_random".localised(using: settingsManager.selectedLanguage))
        .onAppear {
            motionManager.onShake = getRandomGame
        }
    }

    private func getRandomGame() {
        motionManager.isShaking = true
        isLoading = true

        Task {
            do {
                currentGame = try await APIService.shared.fetchRandomGame()
                // Envia notificação quando o jogo for obtido
                if let game = currentGame {
                    try await NotificationManager.shared.sendRandomGameNotification()
                }
            } catch {
                print("Error getting random game: \(error)")
            }

            isLoading = false
            // Reset do estado de shake após meio segundo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                motionManager.isShaking = false
            }
        }
    }
}
