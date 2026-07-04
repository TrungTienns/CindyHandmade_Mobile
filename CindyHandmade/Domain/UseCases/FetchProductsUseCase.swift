import Foundation

protocol FetchProductsUseCase {
    func execute() async throws -> [Product]
}

final class DefaultFetchProductsUseCase: FetchProductsUseCase {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func execute() async throws -> [Product] {
        // Business Logic có thể đặt ở đây.
        // Ví dụ: Chỉ lấy các sản phẩm còn hàng (stock > 0), hoặc tính toán lại giá khuyến mãi...
        // Tạm thời trả về nguyên danh sách từ Repository.
        return try await productRepository.getProducts()
    }
}
