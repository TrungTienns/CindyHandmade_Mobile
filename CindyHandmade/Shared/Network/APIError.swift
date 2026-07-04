import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .noData:
            return "No data was returned from the server."
        case .invalidResponse:
            return "Invalid response from the server."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)"
        case .unauthorized:
            return "Unauthorized access. Please login again."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
