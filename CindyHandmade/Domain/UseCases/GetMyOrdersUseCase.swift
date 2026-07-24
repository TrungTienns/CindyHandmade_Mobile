import Foundation

class GetMyOrdersUseCase {
    private let repository: OrderRepository
    
    init(repository: OrderRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [OrderHistoryDTO] {
        return try await repository.getMyOrders()
    }
}
