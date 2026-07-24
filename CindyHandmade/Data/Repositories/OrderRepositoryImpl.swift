import Foundation

class OrderRepositoryImpl: OrderRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func checkout(request: CheckoutRequestDTO) async throws -> String {
        let endpoint = OrderEndpoint.checkout(request: request)
        let response = try await apiClient.request(endpoint: endpoint, responseType: OrderResponseDTO.self)
        return response.message
    }
    
    func getMyOrders() async throws -> [OrderHistoryDTO] {
        let endpoint = OrderEndpoint.getMyOrders
        return try await apiClient.request(endpoint: endpoint, responseType: [OrderHistoryDTO].self)
    }
}
