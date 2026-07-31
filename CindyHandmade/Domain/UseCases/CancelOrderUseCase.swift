import Foundation

class CancelOrderUseCase {
    private let orderRepository: OrderRepository
    
    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }
    
    func execute(orderId: Int) async throws -> String {
        return try await orderRepository.cancelOrder(orderId: orderId)
    }
}
