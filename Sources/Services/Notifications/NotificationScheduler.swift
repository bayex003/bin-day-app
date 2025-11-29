import Foundation
import UserNotifications

protocol NotificationSchedulerProtocol {
    func requestAuthorization()
    func scheduleReminder(for pickup: BinPickup, leadTime: TimeInterval)
}

final class NotificationScheduler: NotificationSchedulerProtocol {
    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            // Errors intentionally ignored at this layer; surface them through analytics if needed.
        }
    }

    func scheduleReminder(for pickup: BinPickup, leadTime: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Bin Day reminder"
        content.body = "\(pickup.type.label) pickup is coming up."
        content.sound = .default

        let triggerDate = pickup.pickupDate.addingTimeInterval(-leadTime)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: pickup.id.uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
}
