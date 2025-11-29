import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // HOME
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // SETTINGS
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(1)

            // ABOUT
            NavigationStack {
                AboutAppView()
            }
            .tabItem {
                Label("About", systemImage: "info.circle.fill")
            }
            .tag(2)
        }
    }
}
