import Foundation
import Combine
import UserNotifications
import SwiftUI

// MARK: - NotificationManager
@MainActor
final class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    @Published private(set) var notifications: [AppNotification] = []
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    private let storageKey = "cindy_notifications"
    // Key: "orderStatus_<orderId>" -> last known status string
    private let statusCacheKeyPrefix = "orderStatus_"
    
    private init() {
        loadFromStorage()
    }
    
    // MARK: - Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Add In-App Notification + System Banner
    func addNotification(title: String, body: String, type: AppNotificationType) {
        let notification = AppNotification(title: title, body: body, type: type)
        notifications.insert(notification, at: 0)
        saveToStorage()
        scheduleSystemNotification(title: title, body: body, identifier: notification.id.uuidString)
    }
    
    // MARK: - Mark as Read
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            saveToStorage()
            updateBadgeCount()
        }
    }
    
    func markAllAsRead() {
        notifications = notifications.map {
            var n = $0; n.isRead = true; return n
        }
        saveToStorage()
        updateBadgeCount()
    }
    
    func clearAll() {
        notifications.removeAll()
        saveToStorage()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        updateBadgeCount()
    }
    
    // MARK: - Order Status Change Detection
    /// Call this after fetching orders. Compares new status vs cached; triggers notification if changed.
    func checkOrderStatusChange(orderId: Int, newStatus: String, orderNumber: String) {
        let cacheKey = "\(statusCacheKeyPrefix)\(orderId)"
        let previousStatus = UserDefaults.standard.string(forKey: cacheKey)
        
        guard let prev = previousStatus, prev != newStatus else {
            // Save current status for future comparison
            UserDefaults.standard.set(newStatus, forKey: cacheKey)
            return
        }
        
        // Status changed — create notification
        UserDefaults.standard.set(newStatus, forKey: cacheKey)
        
        let (title, body, type) = notificationContent(for: newStatus, orderNumber: orderNumber)
        addNotification(title: title, body: body, type: type)
    }
    
    /// Call this when an order is first placed so we cache its initial status.
    func cacheOrderStatus(orderId: Int, status: String) {
        let cacheKey = "\(statusCacheKeyPrefix)\(orderId)"
        UserDefaults.standard.set(status, forKey: cacheKey)
    }
    
    // MARK: - Private Helpers
    private func notificationContent(for status: String, orderNumber: String) -> (String, String, AppNotificationType) {
        switch status.lowercased() {
        case "processing":
            return (NSLocalizedString("noti_processing_title", comment: ""),
                    String(format: NSLocalizedString("noti_processing_body", comment: ""), orderNumber),
                    .orderProcessing)
        case "shipped":
            return (NSLocalizedString("noti_shipped_title", comment: ""),
                    String(format: NSLocalizedString("noti_shipped_body", comment: ""), orderNumber),
                    .orderShipped)
        case "delivered":
            return (NSLocalizedString("noti_delivered_title", comment: ""),
                    String(format: NSLocalizedString("noti_delivered_body", comment: ""), orderNumber),
                    .orderDelivered)
        default:
            return (NSLocalizedString("noti_update_title", comment: ""),
                    String(format: NSLocalizedString("noti_update_body", comment: ""), orderNumber, status),
                    .orderPlaced)
        }
    }
    
    private func scheduleSystemNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Trigger immediately (0.5s delay to ensure app state is ready)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(unreadCount) { _ in }
    }
    
    // MARK: - Persistence
    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            notifications = decoded
        }
    }
}
