import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let price: Double
    let stock: Int?
    let images: [String]?
    let category: CategoryDTO?
}

struct CategoryDTO: Decodable {
    let id: Int
    let name: String
}
