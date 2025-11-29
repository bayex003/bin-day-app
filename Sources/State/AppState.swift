import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool

    // Master toggle
    @Published var notificationsEnabled: Bool

    // Two reminders: primary (day before), secondary (day of)
    @Published var primaryReminderEnabled: Bool      // day before
    @Published var secondaryReminderEnabled: Bool    // day of

    // Times of day for each reminder
    @Published var primaryReminderTime: Date         // only hour/minute used
    @Published var secondaryReminderTime: Date       // only hour/minute used

    // The pickups currently scheduled/known to the app.
    @Published var scheduledPickups: [BinPickup]

    init(
        isOnboardingComplete: Bool = false,
        notificationsEnabled: Bool = true,
        primaryReminderEnabled: Bool = true,
        secondaryReminderEnabled: Bool = false,
        primaryReminderTime: Date? = nil,
        secondaryReminderTime: Date? = nil,
        scheduledPickups: [BinPickup] = []
    ) {
        self.isOnboardingComplete = isOnboardingComplete
        self.notificationsEnabled = notificationsEnabled
        self.primaryReminderEnabled = primaryReminderEnabled
        self.secondaryReminderEnabled = secondaryReminderEnabled

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let defaultPrimary = calendar.date(
            bySettingHour: 19,
            minute: 0,
            second: 0,
            of: today
        ) ?? Date()

        let defaultSecondary = calendar.date(
            bySettingHour: 7,
            minute: 0,
            second: 0,
            of: today
        ) ?? Date()

        self.primaryReminderTime = primaryReminderTime ?? defaultPrimary
        self.secondaryReminderTime = secondaryReminderTime ?? defaultSecondary

        self.scheduledPickups = scheduledPickups
    }
}
