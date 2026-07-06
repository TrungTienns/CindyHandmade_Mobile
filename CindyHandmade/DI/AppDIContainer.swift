import Foundation

// A simple DI Container to hold our services and inject them where needed.
class AppDIContainer {
    static let shared = AppDIContainer()
    
    let apiClient: APIClient
    let tokenManager: TokenManager
    
    private init() {
        self.tokenManager = UserDefaultsTokenManager()
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
}
