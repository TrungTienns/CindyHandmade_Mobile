import Foundation

protocol ReviewRepository {
    func getProductReviews(productId: Int) async throws -> [Review]
    func submitReview(productId: Int, rating: Int, comment: String?) async throws -> Review
    func getMyReviews() async throws -> [Review]
    func getMyReviewForProduct(productId: Int) async throws -> Review?
}
