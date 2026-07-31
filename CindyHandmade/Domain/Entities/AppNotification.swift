import Foundation

// MARK: - Notification Type
enum AppNotificationType: String, Codable {
    case orderPlaced    = "order_placed"
    case orderProcessing = "order_processing"
    case orderShipped   = "order_shipped"
    case orderDelivered = "order_delivered"
    case reviewSent     = "review_sent"
    
    var icon: String {
        switch self {
        case .orderPlaced:    return "bag.fill"
        case .orderProcessing: return "shippingbox"
        case .orderShipped:   return "truck.box.fill"
        case .orderDelivered: return "checkmark.seal.fill"
        case .reviewSent:     return "star.fill"
        }
    }
    
    var accentColorHex: String {
        switch self {
        case .orderPlaced:    return "4A7056"
        case .orderProcessing: return "F5A623"
        case .orderShipped:   return "2196F3"
        case .orderDelivered: return "4CAF50"
        case .reviewSent:     return "FFB300"
        }
    }
}

// MARK: - AppNotification Entity
struct AppNotification: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let body: String
    let type: AppNotificationType
    var isRead: Bool
    let date: Date
    
    init(id: UUID = UUID(), title: String, body: String, type: AppNotificationType, isRead: Bool = false, date: Date = Date()) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.isRead = isRead
        self.date = date
    }
    
    /// Formatted relative date string (e.g. "2 phút trước", "Hôm qua")
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
