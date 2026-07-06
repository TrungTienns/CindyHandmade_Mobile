import Foundation

protocol APIClient {
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let tokenManager: TokenManager?

    init(session: URLSession = .shared, tokenManager: TokenManager? = nil) {
        self.session = session
        self.tokenManager = tokenManager
    }

    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Cấu hình Header
        var allHeaders = endpoint.headers ?? [:]
        if let token = tokenManager?.getToken() {
            allHeaders["Authorization"] = "Bearer \(token)"
        }
        
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        allHeaders["Accept-Language"] = language
        
        for (key, value) in allHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Cấu hình HTTP Body
        if let parameters = endpoint.parameters, request.httpMethod != "GET" {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                throw APIError.unknown(error)
            }
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            if data.isEmpty {
               
                if responseType == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
            }
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

struct EmptyResponse: Decodable {}
