import Foundation
import Combine

@MainActor
class AllProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var isLoadingProducts: Bool = false
    @Published var isLoadingCategories: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategory: Category?
    @Published var searchText: String = ""
    
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
        
        if let selected = selectedCategory, selected.id != 0 {
            result = result.filter { $0.categoryName == selected.name }
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.lowercased().contains(searchText.lowercased()) }
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
