import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var topSellers: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var userName: String = "Guest"
    
    private let fetchProductsUseCase: FetchProductsUseCase
    private let getProfileUseCase: GetProfileUseCase
    
    init(
        fetchProductsUseCase: FetchProductsUseCase = AppDIContainer.shared.makeFetchProductsUseCase(),
        getProfileUseCase: GetProfileUseCase = AppDIContainer.shared.makeGetProfileUseCase()
    ) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.getProfileUseCase = getProfileUseCase
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
            } else {
                self.userName = "Guest"
            }
            
            if let products = await productsResult {
                self.topSellers = products
            } else {
                self.errorMessage = "Không thể tải sản phẩm."
            }
            
            self.isLoading = false
        }
    }
}
