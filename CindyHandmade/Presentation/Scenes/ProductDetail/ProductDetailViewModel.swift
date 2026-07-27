import Foundation
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var myReview: Review?
    @Published var isLoadingReviews = false
    @Published var isSubmitting = false
    @Published var submitError: String?
    
    let productId: Int
    private let reviewUseCase: ReviewUseCase
    
    init(productId: Int, reviewUseCase: ReviewUseCase = AppDIContainer.shared.makeReviewUseCase()) {
        self.productId = productId
        self.reviewUseCase = reviewUseCase
    }
    
    func fetchReviews() async {
        isLoadingReviews = true
        defer { isLoadingReviews = false }
        
        do {
            async let fetchedReviews = reviewUseCase.getProductReviews(productId: productId)
            async let fetchedMyReview = reviewUseCase.getMyReviewForProduct(productId: productId)
            
            let (allReviews, my) = try await (fetchedReviews, fetchedMyReview)
            self.reviews = allReviews
            self.myReview = my
        } catch {
            print("Failed to fetch reviews: \(error)")
        }
    }
    
    func submitReview(rating: Int, comment: String) async {
        guard myReview == nil else { return } // Already reviewed
        
        isSubmitting = true
        submitError = nil
        
        do {
            let newReview = try await reviewUseCase.submitReview(
                productId: productId,
                rating: rating,
                comment: comment.isEmpty ? nil : comment
            )
            self.myReview = newReview
            self.reviews.insert(newReview, at: 0) // Prepend to list
        } catch {
            submitError = error.localizedDescription
        }
        
        isSubmitting = false
    }
}
