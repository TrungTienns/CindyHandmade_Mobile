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
        
        return User(id: dto.id, name: dto.name, email: dto.email, role: dto.role, avatarUrl: dto.avtImgurl, totalOrders: dto.totalOrders, totalReviews: dto.totalReviews, totalPoints: dto.totalPoints)
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
        
        return User(id: dto.id, name: dto.name, email: dto.email, role: dto.role, avatarUrl: dto.avtImgurl, totalOrders: dto.totalOrders, totalReviews: dto.totalReviews, totalPoints: dto.totalPoints)
    }
    
    func getProfile() async throws -> User {
        let dto = try await apiClient.request(endpoint: AuthEndpoint.getMe, responseType: UserDTO.self)
        return User(id: dto.id, name: dto.name, email: dto.email, role: dto.role, avatarUrl: dto.avtImgurl, totalOrders: dto.totalOrders, totalReviews: dto.totalReviews, totalPoints: dto.totalPoints)
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
            totalPoints: dto.totalPoints
        )
    }
}
