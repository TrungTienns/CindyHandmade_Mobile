import Foundation

struct CheckoutRequestDTO: Encodable {
    let fullName: String
    let phone: String
    let province: String
    let district: String
    let ward: String
    let address: String
    let paymentMethod: String
}
