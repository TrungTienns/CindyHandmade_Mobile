import Foundation
import Combine

@MainActor
class WishlistViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = AppDIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func fetchWishlist() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let dtos = try await apiClient.request(endpoint: WishlistEndpoint.getWishlist, responseType: [ProductDTO].self)
                self.products = dtos.map { $0.toDomain() }
                
                // Update WishlistManager just in case it's out of sync
                WishlistManager.shared.wishlistedProductIds = Set(self.products.map { $0.id })
            } catch {
                self.errorMessage = "Failed to load wishlist."
                print(error)
            }
            self.isLoading = false
        }
    }
}
