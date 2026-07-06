import Foundation

protocol TokenManager {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}

class UserDefaultsTokenManager: TokenManager {
    private let tokenKey = "jwt_token"
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
