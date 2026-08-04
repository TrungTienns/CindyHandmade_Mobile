import Foundation
import Combine

class AuthRepositoryImpl: AuthRepository {
    private let apiClient: APIClient
    private let tokenManager: TokenManager
    
    init(apiClient: APIClient, tokenManager: TokenManager) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }
    
    func login(email: String, password: String) async throws -> User {
        let params: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let dto = try await apiClient.request(endpoint: AuthEndpoint.login(parameters: params), responseType: UserDTO.self)
        
        if let token = dto.token {
            tokenManager.saveToken(token)
        }
        
        return User(id: dto.id, name: dto.name, email: dto.email, role: dto.role, avatarUrl: dto.avtImgurl, totalOrders: dto.totalOrders, totalReviews: dto.totalReviews, totalPoints: dto.totalPoints, pointsHistory: dto.pointsHistory)
    }
    
    func register(name: String, email: String, password: String) async throws -> User {
        let params: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        let dto = try await apiClient.request(endpoint: AuthEndpoint.register(parameters: params), responseType: UserDTO.self)
        
        if let token = dto.token {
            tokenManager.saveToken(token)
        }
        
        return User(id: dto.id, name: dto.name, email: dto.email, role: dto.role, avatarUrl: dto.avtImgurl, totalOrders: dto.totalOrders, totalReviews: dto.totalReviews, totalPoints: dto.totalPoints, pointsHistory: dto.pointsHistory)
    }
    
    func getProfile() async throws -> User {
        let dto = try await apiClient.request(endpoint: AuthEndpoint.getMe, responseType: UserDTO.self)
        return User(id: dto.id, name: dto.name, email: dto.email, role: dto.role, avatarUrl: dto.avtImgurl, totalOrders: dto.totalOrders, totalReviews: dto.totalReviews, totalPoints: dto.totalPoints, pointsHistory: dto.pointsHistory)
    }
    
    func updateProfile(name: String) async throws -> User {
        let params: [String: Any] = [
            "name": name
        ]
        
        let dto = try await apiClient.request(endpoint: AuthEndpoint.updateProfile(parameters: params), responseType: UserDTO.self)
        
        return User(
            id: dto.id,
            name: dto.name,
            email: dto.email,
            role: dto.role,
            avatarUrl: dto.avtImgurl,
            totalOrders: dto.totalOrders,
            totalReviews: dto.totalReviews,
            totalPoints: dto.totalPoints,
            pointsHistory: dto.pointsHistory
        )
    }
    
    func forgotPassword(email: String) async throws -> String {
        struct MessageResponse: Decodable { let message: String }
        let response = try await apiClient.request(endpoint: AuthEndpoint.forgotPassword(email: email), responseType: MessageResponse.self)
        return response.message
    }
    
    func resetPassword(email: String, otp: String, newPassword: String) async throws -> String {
        struct MessageResponse: Decodable { let message: String }
        let response = try await apiClient.request(endpoint: AuthEndpoint.resetPassword(email: email, otp: otp, newPassword: newPassword), responseType: MessageResponse.self)
        return response.message
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws -> String {
        struct MessageResponse: Decodable { let message: String }
        let response = try await apiClient.request(endpoint: AuthEndpoint.changePassword(currentPassword: currentPassword, newPassword: newPassword), responseType: MessageResponse.self)
        return response.message
    }
}
