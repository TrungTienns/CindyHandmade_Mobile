import Foundation

enum ProductEndpoint: APIEndpoint {
    case getProducts
    
    var baseURL: String {
        return "http://localhost:8080/api"
    }
    
    var path: String {
        switch self {
        case .getProducts:
            return "/products"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProducts:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameters: [String : Any]? {
        return nil
    }
}
