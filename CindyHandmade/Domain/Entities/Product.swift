import Foundation

struct Product: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let formattedPrice: String
    let imageUrl: String
    let categoryName: String
}
