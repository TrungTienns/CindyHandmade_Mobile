import Foundation

enum ProductEndpoint: APIEndpoint {
    case getProducts
    case getCategories
    
    var baseURL: String {
        return "http://192.168.2.90:8080/api"
    }
    
    var path: String {
        switch self {
        case .getProducts:
            return "/products"
        case .getCategories:
            return "/categories"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProducts, .getCategories:
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
