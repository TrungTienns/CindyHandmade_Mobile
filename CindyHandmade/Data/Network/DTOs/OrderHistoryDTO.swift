import Foundation

struct OrderHistoryDTO: Decodable, Identifiable {
    let id: Int
    let userId: Int?
    let totalAmount: Double
    let fullName: String
    let phone: String?
    let province: String?
    let district: String?
    let ward: String?
    let address: String?
    let paymentMethod: String?
    let paymentStatus: String?
    let status: String
    let createdAt: String
    let items: [OrderHistoryItemDTO]?
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let priceString = formatter.string(from: NSNumber(value: totalAmount)) ?? "\(totalAmount)"
        return "\(priceString) ₫"
    }
}

struct OrderHistoryItemDTO: Decodable, Identifiable {
    let id: Int
    let orderId: Int?
    let productId: Int
    let quantity: Int
    let priceAtPurchase: Double
    let size: String?
    let color: String?
    let product: ProductSimpleDTO?
}

struct ProductSimpleDTO: Decodable {
    let id: Int
    let name: String
    let images: [String]?
    
    var imageUrl: String {
        return images?.first ?? "https://images.unsplash.com/photo-1596766440742-996fffd0e261?q=80&w=400&auto=format&fit=crop"
    }
}
