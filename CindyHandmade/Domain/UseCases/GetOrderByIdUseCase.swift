import Foundation

class GetOrderByIdUseCase {
    private let orderRepository: OrderRepository
    
    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }
    
    func execute(orderId: Int) async throws -> OrderHistoryDTO {
        return try await orderRepository.getOrderById(orderId: orderId)
    }
}
