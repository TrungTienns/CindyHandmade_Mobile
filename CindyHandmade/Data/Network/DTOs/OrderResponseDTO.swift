import Foundation

struct OrderResponseDTO: Decodable {
    let message: String
    // We can add Order details if needed, but for now we just care about the success message
}
