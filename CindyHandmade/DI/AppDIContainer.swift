import Foundation

// A simple DI Container to hold our services and inject them where needed.
class AppDIContainer {
    static let shared = AppDIContainer()
    
    let apiClient: APIClient
    
    private init() {
        // Initialize the URLSessionAPIClient
        // In a real app, you might configure the URLSession here
        self.apiClient = URLSessionAPIClient()
    }
    
    // Repository Factories
    func makeProductRepository() -> ProductRepository {
        return ProductRepositoryImpl(apiClient: apiClient)
    }
    
    // Use Case Factories
    func makeFetchProductsUseCase() -> FetchProductsUseCase {
        return DefaultFetchProductsUseCase(productRepository: makeProductRepository())
    }
}
