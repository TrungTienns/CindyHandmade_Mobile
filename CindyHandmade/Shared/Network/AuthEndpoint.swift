import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(parameters: [String: Any])
    case register(parameters: [String: Any])
    case getMe
    
    var baseURL: String {
        return "http://192.168.2.90:8080/api/auth"
    }
    
    var path: String {
        switch self {
        case .login: return "/login"
        case .register: return "/register"
        case .getMe: return "/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register: return .post
        case .getMe: return .get
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
        }
    }
}
