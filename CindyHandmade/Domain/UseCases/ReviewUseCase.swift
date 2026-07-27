import Foundation

protocol ReviewUseCase {
    func getProductReviews(productId: Int) async throws -> [Review]
    func submitReview(productId: Int, rating: Int, comment: String?) async throws -> Review
    func getMyReviews() async throws -> [Review]
    func getMyReviewForProduct(productId: Int) async throws -> Review?
}

class ReviewUseCaseImpl: ReviewUseCase {
    private let repository: ReviewRepository
    
    init(repository: ReviewRepository = AppDIContainer.shared.makeReviewRepository()) {
        self.repository = repository
    }
    
    func getProductReviews(productId: Int) async throws -> [Review] {
        return try await repository.getProductReviews(productId: productId)
    }
    
    func submitReview(productId: Int, rating: Int, comment: String?) async throws -> Review {
        return try await repository.submitReview(productId: productId, rating: rating, comment: comment)
    }
    
    func getMyReviews() async throws -> [Review] {
        return try await repository.getMyReviews()
    }
    
    func getMyReviewForProduct(productId: Int) async throws -> Review? {
        return try await repository.getMyReviewForProduct(productId: productId)
    }
}
