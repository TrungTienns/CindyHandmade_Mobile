import Foundation
import Combine

@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var cart: CartDTO?
    @Published var isAddingToCart = false
    @Published var lastAddedProductId: Int?
    
    private let apiClient: APIClient
    
    private init(apiClient: APIClient = AppDIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func fetchCart() {
        Task {
            do {
                let fetchedCart = try await apiClient.request(endpoint: CartEndpoint.getCart, responseType: CartDTO.self)
                self.cart = fetchedCart
            } catch {
                print("Failed to fetch cart: \(error)")
            }
        }
    }
    
    func addToCart(productId: Int, quantity: Int = 1, size: String? = nil, color: String? = nil) {
        self.isAddingToCart = true
        Task {
            do {
                let updatedCart = try await apiClient.request(
                    endpoint: CartEndpoint.addToCart(productId: productId, quantity: quantity, size: size, color: color),
                    responseType: CartDTO.self
                )
                self.cart = updatedCart
                
                // Show a quick visual feedback
                self.lastAddedProductId = productId
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if self.lastAddedProductId == productId {
                    self.lastAddedProductId = nil
                }
            } catch {
                print("Failed to add to cart: \(error)")
            }
            self.isAddingToCart = false
        }
    }
}
