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
        return dtos.map { dto in
            // Lấy ảnh đầu tiên hoặc dùng ảnh placeholder nếu mảng rỗng/null
            let imageUrl = dto.images?.first ?? "https://images.unsplash.com/photo-1596766440742-996fffd0e261?q=80&w=400&auto=format&fit=crop"
            
            // Format giá tiền Việt Nam
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            let priceString = formatter.string(from: NSNumber(value: dto.price)) ?? "\(dto.price)"
            let formattedPrice = "\(priceString) ₫"
            
            return Product(
                id: dto.id,
                name: dto.name,
                description: dto.description ?? "",
                price: dto.price,
                formattedPrice: formattedPrice,
                imageUrl: imageUrl,
                categoryName: dto.category?.name ?? "Khác"
            )
        }
    }
    func getCategories() async throws -> [Category] {
        let dtos = try await apiClient.request(endpoint: ProductEndpoint.getCategories, responseType: [CategoryDTO].self)
        
        return dtos.map { dto in
            Category(id: dto.id, name: dto.name, description: dto.description)
        }
    }
}
