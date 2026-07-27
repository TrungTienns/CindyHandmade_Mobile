import Foundation
import Combine

@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var cart: CartDTO?
    @Published var isAddingToCart = false
    @Published var lastAddedProductId: Int?
    @Published var showSuccessMessage = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var navigateToCatalog = false
    
    private let apiClient: APIClient
    
    // Store tasks so they can be cancelled if needed
    private var fetchCartTask: Task<Void, Never>?
    private var addToCartTask: Task<Void, Never>?
    
    private init(apiClient: APIClient = AppDIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func fetchCart() {
        // Cancel any in-flight fetch before starting a new one
        fetchCartTask?.cancel()
        fetchCartTask = Task {
            guard !Task.isCancelled else { return }
            do {
                let fetchedCart = try await apiClient.request(endpoint: CartEndpoint.getCart, responseType: CartDTO.self)
                if !Task.isCancelled {
                    self.cart = fetchedCart
                }
            } catch {
                if !Task.isCancelled {
                    print("Failed to fetch cart: \(error)")
                }
            }
        }
    }
    
    func addToCart(productId: Int, quantity: Int = 1, size: String? = nil, color: String? = nil) {
        guard !isAddingToCart else { return } // Prevent spam clicks
        self.isAddingToCart = true
        addToCartTask = Task {
            do {
                let updatedCart = try await apiClient.request(
                    endpoint: CartEndpoint.addToCart(productId: productId, quantity: quantity, size: size, color: color),
                    responseType: CartDTO.self
                )
                guard !Task.isCancelled else { return }
                self.cart = updatedCart
                
                // Show a quick visual feedback
                self.lastAddedProductId = productId
                self.showSuccessMessage = true
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if self.lastAddedProductId == productId {
                    self.lastAddedProductId = nil
                    self.showSuccessMessage = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                print("Failed to add to cart: \(error)")
                self.errorMessage = "Failed to add to cart: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
            self.isAddingToCart = false
        }
    }

    func updateQuantity(productId: Int, quantity: Int, size: String? = nil, color: String? = nil) {
        Task {
            do {
                let updatedCart = try await apiClient.request(
                    endpoint: CartEndpoint.updateCartItem(productId: productId, quantity: quantity, size: size, color: color),
                    responseType: CartDTO.self
                )
                self.cart = updatedCart
            } catch {
                print("Failed to update cart item: \(error)")
            }
        }
    }
    
    func removeItem(productId: Int, size: String? = nil, color: String? = nil) {
        Task {
            do {
                let updatedCart = try await apiClient.request(
                    endpoint: CartEndpoint.removeCartItem(productId: productId, size: size, color: color),
                    responseType: CartDTO.self
                )
                self.cart = updatedCart
            } catch {
                print("Failed to remove cart item: \(error)")
            }
        }
    }
    
    func clearCart() {
        // Cancel any pending fetch and immediately refresh after checkout
        fetchCartTask?.cancel()
        fetchCart()
    }
}
