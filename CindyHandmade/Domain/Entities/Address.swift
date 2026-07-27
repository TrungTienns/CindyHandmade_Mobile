import Foundation

struct Address: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var street: String
    var ward: String
    var district: String
    var city: String
    var email: String?
    var isDefault: Bool
    
    var fullAddress: String {
        return "\(street), \(ward), \(district), \(city)"
    }
}
