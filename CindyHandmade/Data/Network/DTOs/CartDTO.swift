import Foundation

struct CartDTO: Decodable {
    let id: Int
    let userId: Int
    let items: [CartItemDTO]
}

struct CartItemDTO: Decodable, Identifiable {
    let id: Int
    let cartId: Int
    let productId: Int
    let quantity: Int
    let size: String?
    let color: String?
    let product: ProductDTO?
}
