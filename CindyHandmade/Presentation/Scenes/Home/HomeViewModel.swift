import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var topSellers: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let fetchProductsUseCase: FetchProductsUseCase
    
    init(fetchProductsUseCase: FetchProductsUseCase = AppDIContainer.shared.makeFetchProductsUseCase()) {
        self.fetchProductsUseCase = fetchProductsUseCase
    }
    
    func fetchTopSellers() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let products = try await fetchProductsUseCase.execute()
                self.topSellers = products
            } catch {
                self.errorMessage = "Lỗi khi lấy dữ liệu: \(error.localizedDescription)"
                print(error)
            }
            self.isLoading = false
        }
    }
}
