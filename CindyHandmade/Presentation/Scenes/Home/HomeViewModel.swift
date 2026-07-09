import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var topSellers: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var userName: String = "Guest"
    @Published var userRole: String = ""
    
    private let fetchProductsUseCase: FetchProductsUseCase
    private let getProfileUseCase: GetProfileUseCase
    private let tokenManager: TokenManager
    
    init(
        fetchProductsUseCase: FetchProductsUseCase = AppDIContainer.shared.makeFetchProductsUseCase(),
        getProfileUseCase: GetProfileUseCase = AppDIContainer.shared.makeGetProfileUseCase(),
        tokenManager: TokenManager = AppDIContainer.shared.tokenManager
    ) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.getProfileUseCase = getProfileUseCase
        self.tokenManager = tokenManager
    }
    
    func fetchTopSellers() {
        isLoading = true
        errorMessage = nil
        
        Task {
            // Load user profile concurrently with products
            async let profileResult = try? getProfileUseCase.execute()
            async let productsResult = try? fetchProductsUseCase.execute()
            
            if let user = await profileResult {
                self.userName = user.name
                self.userRole = user.role
            } else {
                self.userName = "Guest"
                self.userRole = ""
            }
            
            if let products = await productsResult {
                self.topSellers = products
            } else {
                self.errorMessage = "Không thể tải sản phẩm."
            }
            
            self.isLoading = false
            self.isLoading = false
        }
    }
    
    func logout() {
        tokenManager.deleteToken()
        self.userName = "Guest"
        self.userRole = ""
    }
}
