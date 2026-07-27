import Foundation

class ProductRepositoryImpl: ProductRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getProducts() async throws -> [Product] {
        // Gọi API lấy mảng ProductDTO
        let dtos = try await apiClient.request(endpoint: ProductEndpoint.getProducts, responseType: [ProductDTO].self)
        
        // Map DTO sang Entity để UI sử dụng
        return dtos.map { $0.toDomain() }
    }
    func getCategories() async throws -> [Category] {
        let dtos = try await apiClient.request(endpoint: ProductEndpoint.getCategories, responseType: [CategoryDTO].self)
        
        return dtos.map { dto in
            Category(id: dto.id, name: dto.name, description: dto.description)
        }
    }
}
