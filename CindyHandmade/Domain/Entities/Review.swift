import Foundation

struct Review: Identifiable, Equatable {
    let id: Int
    let rating: Int        // 1–5
    let comment: String?
    let userName: String
    let userAvatarUrl: String?
    let productId: Int
    let productName: String?     // For MyReviews (returned by my-reviews endpoint)
    let productImageUrl: String? // For MyReviews
    let createdAt: String
    
    /// Formatted date string for display
    var displayDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: createdAt) {
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            return fmt.string(from: date)
        }
        return createdAt
    }
}
