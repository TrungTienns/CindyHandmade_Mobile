import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(parameters: [String: Any])
    case register(parameters: [String: Any])
    case getMe
    case updateProfile(parameters: [String: Any])
    
    var baseURL: String {
        return AppEnvironment.baseURL + "/auth"
    }
    
    var path: String {
        switch self {
        case .login: return "/login"
        case .register: return "/register"
        case .getMe: return "/me"
        case .updateProfile: return "/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register: return .post
        case .getMe: return .get
        case .updateProfile: return .put
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
        }
    }
}
