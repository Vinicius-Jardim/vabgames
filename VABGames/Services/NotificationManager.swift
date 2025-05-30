import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    @AppStorage("MyLanguages") var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"

    static let shared = NotificationManager()
    private var recommendedGame: Game?
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func getRandomGame() async -> Game? {
        do {
            let randomGame = try await APIService.shared.fetchRandomGame()
            print("Selected random game: \(randomGame.name ?? "Unknown")")
            return randomGame
        } catch {
            print("Error getting random game: \(error.localizedDescription)")
            return nil
        }
    }
    
    func setRecommendedGame(_ game: Game?) {
        self.recommendedGame = game
        if let game = game {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(game)
                UserDefaults.standard.set(data, forKey: "lastRecommendedGame")
                print("Game saved successfully: \(game.name ?? "Unknown")")
            } catch {
                print("Error saving game: \(error.localizedDescription)")
            }
        }
    }
    
    func getLastRecommendedGame() -> Game? {
        guard let data = UserDefaults.standard.data(forKey: "lastRecommendedGame") else {
            print("No saved game found")
            return nil
        }
        
        do {
            let game = try JSONDecoder().decode(Game.self, from: data)
            print("Game loaded successfully: \(game.name ?? "Unknown")")
            return game
        } catch {
            print("Error loading game: \(error.localizedDescription)")
            return nil
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
            print("Permission Granted: \(success)")
            
            if success {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func scheduleNotification(at date: Date) {
        Task {
            // Primeiro, vamos obter um jogo aleatório
            if let randomGame = await getRandomGame() {
                // Agora vamos verificar se temos permissão
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else {
                        print("Notifications not authorized")
                        self.requestNotificationPermission()
                        return
                    }
                    
                    let content = UNMutableNotificationContent()
                    content.title = "notification_title".localised(using: self.currentLanguages)
                    content.body = "notification_body".localised(using: self.currentLanguages) + " \(randomGame.name ?? "this game")! Check it out!"
                    content.sound = .default
                    content.badge = 1
                    content.categoryIdentifier = "gameRecommendation"
                    
                    // Criar componentes de data para notificação diária
                    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
                    dateComponents.second = 0 // Garantir que os segundos são 0
                    
                    print("Scheduling daily notification for \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)")
                    
                    // Criar trigger para notificação diária
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let request = UNNotificationRequest(identifier: "gameNotification", content: content, trigger: trigger)
                    
                    // Remover notificações antigas antes de agendar a nova
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        } else {
                            print("Notification scheduled successfully for \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)")
                            // Salvar o horário da notificação
                            UserDefaults.standard.set(dateComponents.hour, forKey: "notificationHour")
                            UserDefaults.standard.set(dateComponents.minute, forKey: "notificationMinute")
                            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                        }
                    }
                    
                    // Configurar ações da notificação
                    let viewAction = UNNotificationAction(
                        identifier: "VIEW_ACTION",
                        title: "View Game",
                        options: .foreground
                    )
                    
                    let category = UNNotificationCategory(
                        identifier: "gameRecommendation",
                        actions: [viewAction],
                        intentIdentifiers: [],
                        options: .customDismissAction
                    )
                    
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                }
                
                // Salvar o jogo para poder abrir quando a notificação for clicada
                self.setRecommendedGame(randomGame)
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All notifications cancelled")
    }
    
    func isNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    func getNotificationTime() -> (hour: Int, minute: Int)? {
        let hour = UserDefaults.standard.integer(forKey: "notificationHour")
        let minute = UserDefaults.standard.integer(forKey: "notificationMinute")
        if hour == 0 && minute == 0 {
            return nil
        }
        return (hour, minute)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will present")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received with identifier: \(response.actionIdentifier)")
        
        if response.actionIdentifier == "VIEW_ACTION" || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if let game = getLastRecommendedGame() {
                print("Opening game detail for: \(game.name ?? "Unknown")")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenGameDetail"),
                        object: nil,
                        userInfo: ["game": game]
                    )
                }
            }
        }
        
        completionHandler()
    }
    
    func sendRandomGameNotification() async throws {
        // Verifica permissões primeiro
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            throw NSError(domain: "NotificationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notifications not authorized"])
        }
        
        // Obtém um jogo aleatório
        guard let game = await getRandomGame() else {
            throw NSError(domain: "NotificationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not get random game"])
        }
        
        // Cria o conteúdo da notificação
        let content = UNMutableNotificationContent()
        content.title = "notification_title2".localised(using: currentLanguages)
        content.body = String(format: "notification_body".localised(using: currentLanguages), game.name ?? "Unknown")
        content.sound = .default
        
        // Cria o trigger para notificação imediata
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Cria o request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Agenda a notificação
        try await UNUserNotificationCenter.current().add(request)
        
        // Salva o jogo recomendado
        setRecommendedGame(game)
    }
}
