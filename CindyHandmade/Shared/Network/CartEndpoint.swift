import Foundation
import Combine

enum CartEndpoint: APIEndpoint {
    case getCart
    case addToCart(productId: Int, quantity: Int, size: String?, color: String?)
    
    var baseURL: String {
        return "http://192.168.2.90:8080/api/cart"
    }
    
    var path: String {
        switch self {
        case .getCart:
            return ""
        case .addToCart:
            return "/add"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCart:
            return .get
        case .addToCart:
            return .post
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Content-Type": "application/json"]
        if let token = AppDIContainer.shared.tokenManager.getToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getCart:
            return nil
        case .addToCart(let productId, let quantity, let size, let color):
            var params: [String: Any] = [
                "productId": productId,
                "quantity": quantity
            ]
            if let size = size { params["size"] = size }
            if let color = color { params["color"] = color }
            return params
        }
    }
}
