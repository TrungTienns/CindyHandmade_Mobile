import Foundation
import Combine

@MainActor
class WishlistManager: ObservableObject {
    @Published var wishlistedProductIds: Set<Int> = []
    @Published var isLoading = false
    
    static let shared = WishlistManager()
    private let apiClient: APIClient
    
    private init(apiClient: APIClient = AppDIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func fetchWishlist() async {
        isLoading = true
        do {
            let products = try await apiClient.request(endpoint: WishlistEndpoint.getWishlist, responseType: [ProductDTO].self)
            self.wishlistedProductIds = Set(products.map { $0.id })
        } catch {
            print("Failed to fetch wishlist: \(error)")
        }
        isLoading = false
    }
    
    func toggleWishlist(for productId: Int) {
        // Optimistic UI update
        let isCurrentlyWishlisted = wishlistedProductIds.contains(productId)
        if isCurrentlyWishlisted {
            wishlistedProductIds.remove(productId)
        } else {
            wishlistedProductIds.insert(productId)
        }
        
        Task {
            do {
                let response = try await apiClient.request(endpoint: WishlistEndpoint.toggleWishlist(productId: productId), responseType: ToggleWishlistResponse.self)
                // Sync with actual response
                if response.isWishlisted {
                    self.wishlistedProductIds.insert(productId)
                } else {
                    self.wishlistedProductIds.remove(productId)
                }
            } catch {
                print("Failed to toggle wishlist: \(error)")
                // Revert optimistic update on failure
                if isCurrentlyWishlisted {
                    self.wishlistedProductIds.insert(productId)
                } else {
                    self.wishlistedProductIds.remove(productId)
                }
            }
        }
    }
}
