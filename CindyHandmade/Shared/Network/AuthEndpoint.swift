import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(parameters: [String: Any])
    case register(parameters: [String: Any])
    case getMe
    case updateProfile(parameters: [String: Any])
    case forgotPassword(email: String)
    case resetPassword(email: String, otp: String, newPassword: String)
    case changePassword(currentPassword: String, newPassword: String)
    
    var baseURL: String {
        return AppEnvironment.baseURL + "/auth"
    }
    
    var path: String {
        switch self {
        case .login: return "/login"
        case .register: return "/register"
        case .getMe: return "/me"
        case .updateProfile: return "/me"
        case .forgotPassword: return "/forgot-password"
        case .resetPassword: return "/reset-password"
        case .changePassword: return "/change-password"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .forgotPassword, .resetPassword: return .post
        case .getMe: return .get
        case .updateProfile, .changePassword: return .put
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .login(let params): return params
        case .register(let params): return params
        case .getMe: return nil
        case .updateProfile(let params): return params
        case .forgotPassword(let email): return ["email": email]
        case .resetPassword(let email, let otp, let newPassword):
            return ["email": email, "otp": otp, "newPassword": newPassword]
        case .changePassword(let currentPassword, let newPassword):
            return ["currentPassword": currentPassword, "newPassword": newPassword]
        }
    }
}
