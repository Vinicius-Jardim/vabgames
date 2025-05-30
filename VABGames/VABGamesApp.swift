//
//  VABGamesApp.swift
//  VABGames
//
//  Created by user258294 on 12/19/24.
//

import SwiftUI
import UserNotifications

@main
struct VABGamesApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var appState = AppState()

    init() {
        // Configurar o delegate de notificações ao iniciar o app
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(languageManager)
                .environmentObject(settingsManager)
                .environmentObject(appState)
                .onAppear {
                    // Solicitar permissões de notificação ao abrir o app
                    NotificationManager.shared.requestNotificationPermission()
                }
        }
    }
}

// Classe para gerenciar o estado global do app
class AppState: ObservableObject {
    @Published var selectedGame: Game?
    @Published var showingGameDetail = false
    
    init() {
        // Observar notificações para abrir detalhes do jogo
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OpenGameDetail"),
            object: nil,
            queue: .main) { [weak self] notification in
                if let game = notification.userInfo?["game"] as? Game {
                    self?.selectedGame = game
                    self?.showingGameDetail = true
                }
            }
    }
}
