import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let price: Double
    let stock: Int?
    let images: [String]?
    let category: CategoryDTO?
    
    func toDomain() -> Product {
        let imageUrl = self.images?.first ?? "https://images.unsplash.com/photo-1596766440742-996fffd0e261?q=80&w=400&auto=format&fit=crop"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let priceString = formatter.string(from: NSNumber(value: self.price)) ?? "\(self.price)"
        let formattedPrice = "\(priceString) ₫"
        
        return Product(
            id: self.id,
            name: self.name,
            description: self.description ?? "",
            price: self.price,
            formattedPrice: formattedPrice,
            imageUrl: imageUrl,
            categoryName: self.category?.name ?? "Khác"
        )
    }
}

struct CategoryDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
}
