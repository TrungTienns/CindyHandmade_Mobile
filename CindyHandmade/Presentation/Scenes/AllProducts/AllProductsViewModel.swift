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
    
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 20000000
    @Published var sortOption: SortOption = .none
    
    // Cached filtered result — updated by Combine pipeline with debounce
    @Published private(set) var filteredProducts: [Product] = []
    
    var initialCategoryName: String?
    
    private let fetchProductsUseCase: FetchProductsUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchProductsUseCase: FetchProductsUseCase = AppDIContainer.shared.makeFetchProductsUseCase(),
        getCategoriesUseCase: GetCategoriesUseCase = AppDIContainer.shared.makeGetCategoriesUseCase()
    ) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        
        setupFilterPipeline()
    }
    
    // MARK: - Combine Pipeline
    /// Observes all filter-related changes and re-applies them with a debounce on search text.
    /// This prevents running the filter logic on every single keystroke.
    private func setupFilterPipeline() {
        // Debounce search text so filter only runs 300ms after user stops typing
        let debouncedSearch = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
        
        Publishers.CombineLatest4(
            $products,
            $selectedCategory,
            debouncedSearch,
            $sortOption
        )
        .combineLatest($minPrice.combineLatest($maxPrice))
        .map { [weak self] combined, priceRange -> [Product] in
            guard let self = self else { return [] }
            let (products, selectedCategory, searchText, sortOption) = combined
            let (minPrice, maxPrice) = priceRange
            return self.applyFilters(
                products: products,
                category: selectedCategory,
                search: searchText,
                sort: sortOption,
                minPrice: minPrice,
                maxPrice: maxPrice
            )
        }
        .receive(on: RunLoop.main)
        .assign(to: &$filteredProducts)
    }
    
    private func applyFilters(
        products: [Product],
        category: Category?,
        search: String,
        sort: SortOption,
        minPrice: Double,
        maxPrice: Double
    ) -> [Product] {
        var result = products
        
        // 1. Filter by category
        if let selected = category, selected.id != 0 {
            result = result.filter { $0.categoryName == selected.name }
        }
        
        // 2. Filter by search text
        if !search.isEmpty {
            result = result.filter { $0.name.lowercased().contains(search.lowercased()) }
        }
        
        // 3. Filter by price range
        result = result.filter { $0.price >= minPrice && $0.price <= maxPrice }
        
        // 4. Sort
        switch sort {
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
                
                if let initial = self.initialCategoryName,
                   let matched = result.first(where: { $0.name.trimmingCharacters(in: .whitespaces).lowercased() == initial.trimmingCharacters(in: .whitespaces).lowercased() }) {
                    self.selectedCategory = matched
                    self.initialCategoryName = nil // clear after use
                } else if self.selectedCategory == nil {
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
