import Foundation
import Combine

@MainActor
class MyReviewsViewModel: ObservableObject {
    @Published var myReviews: [Review] = []
    @Published var isLoading = false
    
    private let reviewUseCase: ReviewUseCase
    
    init(reviewUseCase: ReviewUseCase = AppDIContainer.shared.makeReviewUseCase()) {
        self.reviewUseCase = reviewUseCase
    }
    
    func fetchMyReviews() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.myReviews = try await reviewUseCase.getMyReviews()
        } catch {
            print("Failed to fetch my reviews: \(error)")
        }
    }
}
