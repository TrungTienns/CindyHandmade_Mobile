import Foundation

struct User: Equatable {
    let id: Int
    let name: String
    let email: String
    let role: String
    let avatarUrl: String?
    let totalOrders: Int?
    let totalReviews: Int?
    let totalPoints: Int?
    let pointsHistory: [PointEntry]?
}

struct PointEntry: Identifiable, Equatable, Decodable {
    let id: String
    let icon: String
    let title: String
    let points: Int
    let date: String
    let isEarned: Bool
}
