import Foundation

struct Product: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let formattedPrice: String
    let imageUrl: String
    let images: [String]
    let categoryName: String
    var avgRating: Double?      // Average review rating (nil if no reviews yet)
    var reviewCount: Int?       // Total number of reviews
    var reviews: [Review]       // Full review list (populated on detail fetch)
    
    /// Convenience: 0.0 when no rating available
    var displayRating: Double { avgRating ?? 0.0 }
    var displayReviewCount: Int { reviewCount ?? 0 }
}
