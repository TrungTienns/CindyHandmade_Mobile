import Foundation
import Combine
import SwiftUI

@MainActor
class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [OrderHistoryDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let getMyOrdersUseCase: GetMyOrdersUseCase
    private let cancelOrderUseCase: CancelOrderUseCase
    private let getOrderByIdUseCase: GetOrderByIdUseCase
    
    init(
        getMyOrdersUseCase: GetMyOrdersUseCase = AppDIContainer.shared.makeGetMyOrdersUseCase(),
        cancelOrderUseCase: CancelOrderUseCase = AppDIContainer.shared.makeCancelOrderUseCase(),
        getOrderByIdUseCase: GetOrderByIdUseCase = AppDIContainer.shared.makeGetOrderByIdUseCase()
    ) {
        self.getMyOrdersUseCase = getMyOrdersUseCase
        self.cancelOrderUseCase = cancelOrderUseCase
        self.getOrderByIdUseCase = getOrderByIdUseCase
    }
    
    func fetchOrders() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedOrders = try await getMyOrdersUseCase.execute()
            
            // 🔔 Check for status changes and trigger notifications
            for order in fetchedOrders {
                NotificationManager.shared.checkOrderStatusChange(
                    orderId: order.id,
                    newStatus: order.status ?? "unknown",
                    orderNumber: "\(order.id)"
                )
            }
            
            self.orders = fetchedOrders
        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // Convenience alias for use with `.task {}` modifier
    func loadOrders() async {
        await fetchOrders()
    }
    
    func cancelOrder(orderId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let _ = try await cancelOrderUseCase.execute(orderId: orderId)
            await fetchOrders() // Refresh list after cancelling
        } catch {
            errorMessage = "Lỗi khi hủy đơn hàng: \(error.localizedDescription)"
            isLoading = false // fetchOrders handles false, but if error we need to set it here
        }
    }
    
    func getOrderById(orderId: Int) async throws -> OrderHistoryDTO {
        return try await getOrderByIdUseCase.execute(orderId: orderId)
    }
}
