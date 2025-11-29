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

                VStack(alignment: .leading, spacing: 12) {
                    Text("""
Bin Day helps Salford households quickly check upcoming bin collections and set gentle reminders so nothing gets missed.
""")
                        .font(.body)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you can do")
                            .font(.subheadline.bold())
                        VStack(alignment: .leading, spacing: 4) {
                            Label("See your next collection at a glance", systemImage: "calendar")
                            Label("View the next few weeks to plan ahead", systemImage: "clock")
                            Label("Turn on reminders the evening before and morning of collection day", systemImage: "bell")
                        }
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .labelStyle(.titleAndIcon)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data & privacy")
                            .font(.subheadline.bold())
                        Text("""
Uses the publicly available Salford City Council schedule for your chosen address and keeps everything on your device. No analytics, ads, or tracking are included.
""")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips")
                            .font(.subheadline.bold())
                        Text("""
If collection dates look wrong (especially around bank holidays), refresh in Settings or double-check the council website. Reminders will update automatically when new schedules load.
""")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

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
