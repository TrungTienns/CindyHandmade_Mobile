import Foundation

enum OrderEndpoint: APIEndpoint {
    case checkout(request: CheckoutRequestDTO)
    case getMyOrders
    case cancelOrder(id: Int)
    
    var baseURL: String {
        return AppEnvironment.baseURL
    }
    
    var path: String {
        switch self {
        case .checkout:
            return "/orders/checkout"
        case .getMyOrders:
            return "/orders/myorders"
        case .cancelOrder(let id):
            return "/orders/\(id)/cancel"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkout:
            return .post
        case .getMyOrders:
            return .get
        case .cancelOrder:
            return .put
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .checkout(let request):
            guard let data = try? JSONEncoder().encode(request),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }
            return dict
        case .getMyOrders, .cancelOrder:
            return nil
        }
    }
}
