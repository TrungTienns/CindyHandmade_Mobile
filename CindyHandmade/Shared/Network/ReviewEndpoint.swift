import Foundation

enum ReviewEndpoint: APIEndpoint {
    case getReviews(productId: Int)
    case submitReview(productId: Int, rating: Int, comment: String?)
    case getMyReviews
    case getMyReviewForProduct(productId: Int)
    
    var baseURL: String { AppEnvironment.baseURL }
    
    var path: String {
        switch self {
        case .getReviews(let productId):
            return "/products/\(productId)/reviews"
        case .submitReview(let productId, _, _):
            return "/products/\(productId)/reviews"
        case .getMyReviews:
            return "/reviews/my-reviews"
        case .getMyReviewForProduct(let productId):
            return "/products/\(productId)/reviews/my-review"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .submitReview: return .post
        default:            return .get
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .submitReview(_, let rating, let comment):
            var params: [String: Any] = ["rating": rating]
            if let c = comment, !c.isEmpty { params["comment"] = c }
            return params
        default:
            return nil
        }
    }
}
