import Foundation
import UserNotifications

final class NotificationsManager {

    static let shared = NotificationsManager()

    private init() {}

    /// Schedule bin notifications with:
    /// - primary: day before, at primaryReminderTime
    /// - secondary: day of, at secondaryReminderTime
    func scheduleNotifications(
        for collections: [BinCollection],
        address: AddressItem,
        primaryEnabled: Bool,
        secondaryEnabled: Bool,
        primaryTime: Date,
        secondaryTime: Date
    ) async {
        // If neither is enabled, don't do anything
        guard primaryEnabled || secondaryEnabled else { return }

        let center = UNUserNotificationCenter.current()

        // Check current settings
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted != true { return }
        case .denied:
            return
        case .authorized, .provisional, .ephemeral:
            break
        @unknown default:
            break
        }

        // Clear previous bin notifications (simple approach for this app)
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()

        // Extract hour/minute from the chosen times
        let primaryComponents = calendar.dateComponents([.hour, .minute], from: primaryTime)
        let secondaryComponents = calendar.dateComponents([.hour, .minute], from: secondaryTime)

        for collection in collections {
            let collectionDay = calendar.startOfDay(for: collection.date)

            // PRIMARY: day before
            if primaryEnabled {
                if let dayBefore = calendar.date(byAdding: .day, value: -1, to: collectionDay) {
                    var comps = calendar.dateComponents([.year, .month, .day], from: dayBefore)
                    comps.hour = primaryComponents.hour
                    comps.minute = primaryComponents.minute

                    if let fireDate = calendar.date(from: comps), fireDate > now {
                        let id = "bin-primary-\(collection.id.uuidString)"
                        await scheduleSingleNotification(
                            center: center,
                            identifier: id,
                            components: comps,
                            type: collection.type,
                            address: address,
                            whenDescription: "tomorrow"
                        )
                    }
                }
            }

            // SECONDARY: day of
            if secondaryEnabled {
                var comps = calendar.dateComponents([.year, .month, .day], from: collectionDay)
                comps.hour = secondaryComponents.hour
                comps.minute = secondaryComponents.minute

                if let fireDate = calendar.date(from: comps), fireDate > now {
                    let id = "bin-secondary-\(collection.id.uuidString)"
                    await scheduleSingleNotification(
                        center: center,
                        identifier: id,
                        components: comps,
                        type: collection.type,
                        address: address,
                        whenDescription: "today"
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func scheduleSingleNotification(
        center: UNUserNotificationCenter,
        identifier: String,
        components: DateComponents,
        type: BinType,
        address: AddressItem,
        whenDescription: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "Bin day \(whenDescription)"
        content.body = "Put out your \(type.rawValue.lowercased()) bin for \(address.postcode)."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification:", error)
        }
    }
}
