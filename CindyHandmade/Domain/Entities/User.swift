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
}
