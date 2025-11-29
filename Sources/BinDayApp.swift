import SwiftUI
import UserNotifications

@main
struct BinDayApp: App {
    @StateObject private var appState = AppState()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appState)
            .tint(AppTheme.accent)   // uses your custom theme colour
            .task {
                await requestNotificationAuthorizationIfNeeded()
            }
        }
    }

    // MARK: - Notification permission

    private func requestNotificationAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        // If user has already allowed or denied, do nothing
        guard settings.authorizationStatus == .notDetermined else { return }

        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
}

