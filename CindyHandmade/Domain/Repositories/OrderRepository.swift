import Foundation

protocol OrderRepository {
    func checkout(request: CheckoutRequestDTO) async throws -> String
    func getMyOrders() async throws -> [OrderHistoryDTO]
    func cancelOrder(orderId: Int) async throws -> String
}
