import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, password: String) async throws -> User
    func getProfile() async throws -> User
    func updateProfile(name: String) async throws -> User
}
