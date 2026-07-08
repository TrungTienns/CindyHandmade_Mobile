import Foundation
import Combine

enum SortOption: String, CaseIterable, Identifiable {
    case none = "none"
    case priceLowToHigh = "price_low_high"
    case priceHighToLow = "price_high_low"
    
    var id: String { self.rawValue }
}

@MainActor
class AllProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var isLoadingProducts: Bool = false
    @Published var isLoadingCategories: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategory: Category?
    @Published var searchText: String = ""
    
    @Published var maxPrice: Double = 5000000
    @Published var sortOption: SortOption = .none
    
    private let fetchProductsUseCase: FetchProductsUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase
    
    init(
        fetchProductsUseCase: FetchProductsUseCase = AppDIContainer.shared.makeFetchProductsUseCase(),
        getCategoriesUseCase: GetCategoriesUseCase = AppDIContainer.shared.makeGetCategoriesUseCase()
    ) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
    }
    
    var filteredProducts: [Product] {
        var result = products
        
        // 1. Filter by category
        if let selected = selectedCategory, selected.id != 0 {
            result = result.filter { $0.categoryName == selected.name }
        }
        
        // 2. Filter by search text
        if !searchText.isEmpty {
            result = result.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // 3. Filter by max price
        result = result.filter { $0.price <= maxPrice }
        
        // 4. Sort
        switch sortOption {
        case .none:
            break
        case .priceLowToHigh:
            result.sort { $0.price < $1.price }
        case .priceHighToLow:
            result.sort { $0.price > $1.price }
        }
        
        return result
    }
    
    func fetchData() {
        fetchCategories()
        fetchProducts()
    }
    
    private func fetchCategories() {
        isLoadingCategories = true
        Task {
            do {
                let fetchedCategories = try await getCategoriesUseCase.execute()
                // Thêm danh mục "Tất cả" (All) ở đầu
                let allCategory = Category(id: 0, name: "All", description: nil)
                var result = [allCategory]
                result.append(contentsOf: fetchedCategories)
                
                self.categories = result
                if self.selectedCategory == nil {
                    self.selectedCategory = allCategory
                }
            } catch {
                print("Error fetching categories: \(error)")
            }
            isLoadingCategories = false
        }
    }
    
    private func fetchProducts() {
        isLoadingProducts = true
        errorMessage = nil
        Task {
            do {
                let fetchedProducts = try await fetchProductsUseCase.execute()
                self.products = fetchedProducts
            } catch {
                self.errorMessage = "Không thể tải danh sách sản phẩm."
            }
            isLoadingProducts = false
        }
    }
}
