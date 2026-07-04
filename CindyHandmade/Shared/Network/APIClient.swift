import Foundation

protocol APIClient {
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

class URLSessionAPIClient: APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw APIError.invalidURL
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
                // If it's empty, and T is e.g. EmptyResponse, we might need special handling.
                // For now, assume if data is empty we might throw decoding error unless expected.
                if responseType == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
            }
            do {
                let decoder = JSONDecoder()
                // Assuming typical snake_case from backend, if not, remove or change this
                decoder.keyDecodingStrategy = .convertFromSnakeCase
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

// A simple empty response struct in case some APIs return 204 or no body
struct EmptyResponse: Decodable {}
