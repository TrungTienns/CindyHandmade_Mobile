import Foundation
import Combine

enum CartEndpoint: APIEndpoint {
    case getCart
    case addToCart(productId: Int, quantity: Int, size: String?, color: String?)
    case updateCartItem(productId: Int, quantity: Int, size: String?, color: String?)
    case removeCartItem(productId: Int, size: String?, color: String?)
    
    var baseURL: String {
        return AppEnvironment.baseURL + "/cart"
    }
    
    var path: String {
        switch self {
        case .getCart:
            return ""
        case .addToCart:
            return "/add"
        case .updateCartItem:
            return "/update"
        case .removeCartItem(let productId, let size, let color):
            var queryItems = [String]()
            if let size = size { queryItems.append("size=\(size)") }
            if let color = color { queryItems.append("color=\(color)") }
            let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
            return "/remove/\(productId)" + queryString
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCart:
            return .get
        case .addToCart:
            return .post
        case .updateCartItem:
            return .put
        case .removeCartItem:
            return .delete
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
        case .getCart, .removeCartItem:
            return nil
        case .addToCart(let productId, let quantity, let size, let color),
             .updateCartItem(let productId, let quantity, let size, let color):
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
