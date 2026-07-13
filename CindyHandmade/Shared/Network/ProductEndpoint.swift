import Foundation

enum ProductEndpoint: APIEndpoint {
    case getProducts
    case getCategories
    
    var baseURL: String {
        return AppEnvironment.baseURL
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
