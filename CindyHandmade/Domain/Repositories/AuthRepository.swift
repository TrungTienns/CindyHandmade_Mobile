import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func getProfile() async throws -> User
}
