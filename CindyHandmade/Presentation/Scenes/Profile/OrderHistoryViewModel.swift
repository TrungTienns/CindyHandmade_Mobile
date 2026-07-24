import Foundation
import Combine
import SwiftUI

@MainActor
class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [OrderHistoryDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let getMyOrdersUseCase: GetMyOrdersUseCase
    
    init(getMyOrdersUseCase: GetMyOrdersUseCase = AppDIContainer.shared.makeGetMyOrdersUseCase()) {
        self.getMyOrdersUseCase = getMyOrdersUseCase
    }
    
    func fetchOrders() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedOrders = try await getMyOrdersUseCase.execute()
            self.orders = fetchedOrders
        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
