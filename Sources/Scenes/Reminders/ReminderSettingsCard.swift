import SwiftUI

struct ReminderSettingsCard: View {
    @EnvironmentObject private var appState: AppState

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder Settings")
                .font(.headline)

            VStack(spacing: 10) {
                ReminderRow(
                    iconName: "moon.stars.fill",
                    iconColor: Color.blue,
                    title: "Evening before",
                    subtitle: "Primary reminder",
                    isOn: $appState.primaryReminderEnabled,
                    time: $appState.primaryReminderTime,
                    timeFormatter: timeFormatter
                )

                ReminderRow(
                    iconName: "sun.max.fill",
                    iconColor: Color.purple,
                    title: "Morning of",
                    subtitle: "Secondary reminder",
                    isOn: $appState.secondaryReminderEnabled,
                    time: $appState.secondaryReminderTime,
                    timeFormatter: timeFormatter
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Row

private struct ReminderRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String

    @Binding var isOn: Bool
    @Binding var time: Date

    let timeFormatter: DateFormatter

    @State private var showingTimePicker = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.18))
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(width: 34, height: 34)

            // Labels + time
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Button {
                    showingTimePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(timeFormatter.string(from: time))
                            .font(.caption)
                            .foregroundColor(.primary)

                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(title: title, time: $time)
        }
    }
}

// MARK: - Time picker sheet

private struct TimePickerSheet: View {
    let title: String
    @Binding var time: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 250)

                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
