import Foundation

enum WishlistEndpoint: APIEndpoint {
    case getWishlist
    case toggleWishlist(productId: Int)

    var baseURL: String {
        return AppEnvironment.baseURL
    }

    var path: String {
        switch self {
        case .getWishlist:
            return "/wishlist"
        case .toggleWishlist(let productId):
            return "/wishlist/\(productId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getWishlist:
            return .get
        case .toggleWishlist:
            return .post
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var parameters: [String: Any]? {
        return nil
    }
}

struct ToggleWishlistResponse: Decodable {
    let message: String
    let isWishlisted: Bool
}
