import Foundation

protocol GetCategoriesUseCase {
    func execute() async throws -> [Category]
}

class DefaultGetCategoriesUseCase: GetCategoriesUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute() async throws -> [Category] {
        return try await productRepository.getCategories()
    }
}
