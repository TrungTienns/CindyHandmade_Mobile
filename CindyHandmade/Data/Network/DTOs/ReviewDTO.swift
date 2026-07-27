import Foundation

// Review from API
struct ReviewDTO: Decodable {
    let id: Int
    let rating: Int
    let comment: String?
    let productId: Int
    let createdAt: String
    let user: ReviewUserDTO?
    let product: ReviewProductDTO? // Included in my-reviews endpoint
    
    func toDomain() -> Review {
        // Extract image from product.images JSON array (first item)
        let productImageUrl: String? = product?.images?.first
        
        return Review(
            id: id,
            rating: rating,
            comment: comment,
            userName: user?.name ?? "Người dùng",
            userAvatarUrl: user?.name,
            productId: productId,
            productName: product?.name,
            productImageUrl: productImageUrl,
            createdAt: createdAt
        )
    }
}

struct ReviewUserDTO: Decodable {
    let id: Int
    let name: String
}

struct ReviewProductDTO: Decodable {
    let id: Int
    let name: String
    let images: [String]?
    let price: Double?
}

// Request body for submitting a review
struct SubmitReviewRequest: Encodable {
    let rating: Int
    let comment: String?
}
