import Foundation

class ReviewRepositoryImpl: ReviewRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = AppDIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func getProductReviews(productId: Int) async throws -> [Review] {
        let endpoint = ReviewEndpoint.getReviews(productId: productId)
        let dtos = try await apiClient.request(endpoint: endpoint, responseType: [ReviewDTO].self)
        return dtos.map { $0.toDomain() }
    }
    
    func submitReview(productId: Int, rating: Int, comment: String?) async throws -> Review {
        let endpoint = ReviewEndpoint.submitReview(productId: productId, rating: rating, comment: comment)
        let dto = try await apiClient.request(endpoint: endpoint, responseType: ReviewDTO.self)
        return dto.toDomain()
    }
    
    func getMyReviews() async throws -> [Review] {
        let endpoint = ReviewEndpoint.getMyReviews
        let dtos = try await apiClient.request(endpoint: endpoint, responseType: [ReviewDTO].self)
        return dtos.map { $0.toDomain() }
    }
    
    func getMyReviewForProduct(productId: Int) async throws -> Review? {
        let endpoint = ReviewEndpoint.getMyReviewForProduct(productId: productId)
        do {
            let dto = try await apiClient.request(endpoint: endpoint, responseType: ReviewDTO?.self)
            return dto?.toDomain()
        } catch {
            // APIClient will throw if response is not 2xx. If it returns 200 with `null`, it works.
            return nil
        }
    }
}
