import SwiftUI

struct MainTabView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                PublishersListView()
            }
            .tabItem {
                Label("home".localised(using: settingsManager.selectedLanguage),
                      systemImage: "house.fill")
            }
            .tag(0)
            
            ShakeForGameView()
                .tabItem {
                    Label("random".localised(using: settingsManager.selectedLanguage),
                          systemImage: "dice.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("settings".localised(using: settingsManager.selectedLanguage),
                          systemImage: "gear")
                }
                .tag(2)
        }
    }
}
