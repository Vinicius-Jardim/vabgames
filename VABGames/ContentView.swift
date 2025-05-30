import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("MyLanguages") var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView {
            NavigationView {
                PublishersListView()
            }
            .tabItem {
                Label("publishers".localised(using: currentLanguages), systemImage: "building.2")
            }
            
            NavigationView {
                BlacklistView()
            }
            .tabItem {
                Label("blacklist".localised(using: currentLanguages), systemImage: "xmark.circle")
            }
            
            NavigationView {
                ShakeForGameView()
            }
            .tabItem {
                Label("shake_for_random".localised(using: currentLanguages),
                      systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("settings".localised(using: currentLanguages), systemImage: "gear")
            }
        }
        .environment(\.managedObjectContext, viewContext)
        .fullScreenCover(isPresented: $appState.showingGameDetail) {
            if let game = appState.selectedGame {
                NavigationView {
                    GameDetailView(game: game)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Close") {
                                    appState.showingGameDetail = false
                                    appState.selectedGame = nil
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("OpenGameDetail"),
                object: nil,
                queue: .main) { [weak appState] notification in
                    if let game = notification.userInfo?["game"] as? Game {
                        DispatchQueue.main.async {
                            appState?.selectedGame = game
                            appState?.showingGameDetail = true
                        }
                    }
                }
        }
    }
}

