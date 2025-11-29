import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notifications
                Section {
                    Toggle(isOn: $appState.notificationsEnabled) {
                        Text("Enable bin reminders")
                    }

                    if appState.notificationsEnabled {
                        ReminderSettingsCard()
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    } else {
                        Text("Turn on reminders to get a gentle nudge the evening before and on the morning of your collection day.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Reminder times are used when new bin schedules are loaded for your saved address.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // MARK: - Help & Info
                Section {
                    NavigationLink {
                        HelpMenuView()
                    } label: {
                        Label("Help & Info", systemImage: "questionmark.circle")
                    }
                }

                // MARK: - About
                Section {
                    NavigationLink {
                        AboutAppView()
                    } label: {
                        Label("About this app", systemImage: "info.circle")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Simple About screen

struct AboutAppView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About this app")
                    .font(.title2.bold())

                Text("""
This app helps Salford households quickly check their next bin collections and set simple reminders so bins aren’t missed.

It uses public schedule data for your address and stores everything privately on your device.
""")
                    .font(.body)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Version")
                        .font(.subheadline.bold())
                    Text(appVersionString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
