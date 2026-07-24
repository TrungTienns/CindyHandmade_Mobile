import Foundation

class CheckoutUseCase {
    private let repository: OrderRepository
    
    init(repository: OrderRepository) {
        self.repository = repository
    }
    
    func execute(request: CheckoutRequestDTO) async throws -> String {
        return try await repository.checkout(request: request)
    }
}
