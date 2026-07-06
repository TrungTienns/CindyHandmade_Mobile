import Foundation

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let email: String
    let role: String
    let token: String? // Trả về khi login/register
}
