import Foundation

// A simple DI Container to hold our services and inject them where needed.
class AppDIContainer {
    static let shared = AppDIContainer()
    
    let apiClient: APIClient
    let tokenManager: TokenManager
    
    private init() {
        self.tokenManager = KeychainTokenManager()
        self.apiClient = URLSessionAPIClient(tokenManager: self.tokenManager)
    }
    
    // Repository Factories
    func makeProductRepository() -> ProductRepository {
        return ProductRepositoryImpl(apiClient: apiClient)
    }
    
    func makeAuthRepository() -> AuthRepository {
        return AuthRepositoryImpl(apiClient: apiClient, tokenManager: tokenManager)
    }
    
    // Use Case Factories
    func makeFetchProductsUseCase() -> FetchProductsUseCase {
        return DefaultFetchProductsUseCase(productRepository: makeProductRepository())
    }
    
    func makeGetCategoriesUseCase() -> GetCategoriesUseCase {
        return DefaultGetCategoriesUseCase(productRepository: makeProductRepository())
    }
    
    func makeLoginUseCase() -> LoginUseCase {
        return DefaultLoginUseCase(authRepository: makeAuthRepository())
    }
    
    func makeGetProfileUseCase() -> GetProfileUseCase {
        return DefaultGetProfileUseCase(authRepository: makeAuthRepository())
    }
    
    func makeUpdateProfileUseCase() -> UpdateProfileUseCase {
        return DefaultUpdateProfileUseCase(authRepository: makeAuthRepository())
    }
    
    // Checkout & Location
    func makeLocationRepository() -> LocationRepository {
        return LocationRepositoryImpl(apiClient: apiClient)
    }
    
    func makeOrderRepository() -> OrderRepository {
        return OrderRepositoryImpl(apiClient: apiClient)
    }
    
    func makeFetchLocationsUseCase() -> FetchLocationsUseCase {
        return FetchLocationsUseCase(repository: makeLocationRepository())
    }
    
    func makeCheckoutUseCase() -> CheckoutUseCase {
        return CheckoutUseCase(repository: makeOrderRepository())
    }
    
    func makeGetMyOrdersUseCase() -> GetMyOrdersUseCase {
        return GetMyOrdersUseCase(repository: makeOrderRepository())
    }
}
