//
//  SettingsView.swift
//  VABGames
//
//  Created by user258294 on 1/14/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showingCacheAlert = false
    @State private var showingNotificationAlert = false
    @AppStorage("MyLanguages") private var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var notificationsEnabled = NotificationManager.shared.isNotificationsEnabled()
    @State private var selectedTime = Date()
    @State private var showTimePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.orange.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Language Settings
                            settingsCard(title: "language".localised(using: settingsManager.selectedLanguage)) {
                                languagePicker
                            }

                            // Page Size Settings
                            settingsCard(title: "page_size".localised(using: settingsManager.selectedLanguage)) {
                                pageSizeStepper
                            }

                            // Cache Settings
                            settingsCard(title: "cache".localised(using: settingsManager.selectedLanguage)) {
                                cacheSettings
                            }

                            // Notifications Settings
                            settingsCard(title: "notifications".localised(using: settingsManager.selectedLanguage)) {
                                notificationsToggle
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("settings".localised(using: settingsManager.selectedLanguage))
            .alert("Cache Cleared", isPresented: $showingCacheAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Notification Sent", isPresented: $showingNotificationAlert) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showTimePicker) {
                timePickerSheet
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    private var languagePicker: some View {
        Picker("choose_language".localised(using: settingsManager.selectedLanguage), selection: $settingsManager.selectedLanguage) {
            Text("English").tag("en")
                .foregroundColor(.primary)
            Text("Português").tag("pt")
                .foregroundColor(.primary)
        }
        .onChange(of: settingsManager.selectedLanguage) { newValue in
            currentLanguages = newValue
        }
        .pickerStyle(.segmented)
    }

    private var pageSizeStepper: some View {
        Stepper(
            String(format: "games_per_page".localised(using: settingsManager.selectedLanguage), settingsManager.pageSize),
            value: $settingsManager.pageSize,
            in: 10...50,
            step: 10
        )
        .font(.body)
        .foregroundColor(.primary)
    }

    private var cacheSettings: some View {
        VStack(alignment: .leading, spacing: 10) {
            Stepper(
                String(format: "cache_duration".localised(using: settingsManager.selectedLanguage), settingsManager.cacheExpirationHours / 24),
                value: Binding(
                    get: { settingsManager.cacheExpirationHours / 24 },
                    set: { settingsManager.cacheExpirationHours = $0 * 24 }
                ),
                in: 1...7,
                step: 1
            )
            Button("clear_cache".localised(using: settingsManager.selectedLanguage)) {
                settingsManager.clearCache()
                showingCacheAlert = true
            }
            .padding(8)
            .background(Color.orange.opacity(0.2))
            .foregroundColor(.orange)
            .cornerRadius(8)
        }
    }

    private var notificationsToggle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("daily_notification_time".localised(using: settingsManager.selectedLanguage), isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { newValue in
                    if newValue {
                        showTimePicker = true
                    } else {
                        NotificationManager.shared.cancelAllNotifications()
                        UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                    }
                }

            if notificationsEnabled {
                HStack {
                    Text("daily_notification_time".localised(using: settingsManager.selectedLanguage))
                    Spacer()
                    if let time = NotificationManager.shared.getNotificationTime() {
                        Text(String(format: "%02d:%02d", time.hour, time.minute))
                            .foregroundColor(.secondary)
                    }
                    Button("change".localised(using: settingsManager.selectedLanguage)) {
                        showTimePicker = true
                    }
                    .font(.footnote)
                    .foregroundColor(.orange)
                }
            }
        }
    }

    private var timePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()

                Button("Save") {
                    NotificationManager.shared.scheduleNotification(at: selectedTime)
                    showTimePicker = false
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Select Notification Time")
            .navigationBarItems(trailing: Button("Cancel") {
                showTimePicker = false
                if !NotificationManager.shared.isNotificationsEnabled() {
                    notificationsEnabled = false
                }
            })
        }
    }

    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.orange)

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                )
        )
    }
}
