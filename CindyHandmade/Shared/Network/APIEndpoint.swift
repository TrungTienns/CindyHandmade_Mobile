import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

extension APIEndpoint {
    var urlRequest: URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Default Content-Type if not provided
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let parameters = parameters {
            if method == .get {
                var components = URLComponents(string: url.absoluteString)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    print("Error encoding parameters: \(error)")
                    return nil
                }
            }
        }
        
        return request
    }
}
