import SwiftUI

struct AllProductsView: View {
    var initialCategoryName: String? = nil
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AllProductsViewModel()
    @State private var currentBannerIndex = 0
    @State private var showFilterModal = false
    @State private var bannerTimer: Timer?
    @State private var selectedProduct: Product? = nil
    
    @FocusState private var isSearchFocused: Bool
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let bannerImages = ["BannerProducts1", "BannerProducts2", "BannerProducts3"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Custom Navigation Bar
                HStack {
                    Spacer()
                    
                    Text(LocalizedStringKey("all_products"))
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Slogan Banner Carousel
                TabView(selection: $currentBannerIndex) {
                    ForEach(0..<bannerImages.count, id: \.self) { index in
                        ZStack {
                            // Background image
                            Image(bannerImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.4), .clear]), startPoint: .leading, endPoint: .trailing)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("crafts_that_wow")
                                    .font(.custom("Georgia", size: 28))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(24)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .aspectRatio(1.6, contentMode: .fit) // Automatically calculates height to avoid gaps
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        bannerTimer?.invalidate()
                    }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField(LocalizedStringKey("search_product"), text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            if !viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                viewModel.saveSearchTerm(viewModel.searchText)
                            }
                            isSearchFocused = false
                        }
                    
                    Button(action: {
                        showFilterModal = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.appText)
                            .padding(8)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 16)
                .overlay(
                    Group {
                        if isSearchFocused {
                            VStack(spacing: 0) {
                                if viewModel.searchText.isEmpty {
                                    searchHistoryView
                                } else {
                                    searchSuggestionsView
                                }
                            }
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 16)
                            .offset(y: 70) // Push it below the search bar
                        }
                    },
                    alignment: .top
                )
                .zIndex(2) // Ensure dropdown appears above the content below
                
                // Content Below Search Bar (Categories + Grid)
                ZStack(alignment: .top) {
                    VStack(spacing: 24) {
                        // Categories Header
                HStack {
                    Text("categories")
                        .font(.custom("Georgia", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Button(action: {}) {
                        Text("see_all")
                            .font(.footnote)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.horizontal, 16)
                
                // Categories List (No Images, just text)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if viewModel.isLoadingCategories {
                            ForEach(0..<5, id: \.self) { _ in
                                CategorySkeleton()
                            }
                        } else {
                            ForEach(viewModel.categories) { category in
                                let isSelected = viewModel.selectedCategory?.id == category.id
                                
                                Button(action: {
                                    viewModel.selectedCategory = category
                                }) {
                                    Text(category.name)
                                        .font(.subheadline)
                                        .fontWeight(isSelected ? .bold : .medium)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(isSelected ? Color.appPrimary : Color.appCardBackground)
                                        .foregroundColor(isSelected ? .white : .appText)
                                        .cornerRadius(20)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                
                // Products Grid
                if viewModel.isLoadingProducts {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<6, id: \.self) { _ in
                            ProductCardSkeleton()
                        }
                    }
                    .padding(.horizontal, 16)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredProducts) { product in
                            ProductCardView(
                                productId: product.id,
                                category: product.categoryName,
                                name: product.name,
                                price: product.formattedPrice,
                                imageUrl: product.imageUrl,
                                avgRating: product.avgRating
                            )
                            .onTapGesture {
                                selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Hidden Navigation Link for programmatic navigation
                    NavigationLink(
                        destination: Group {
                            if let product = selectedProduct {
                                ProductDetailView(product: product)
                            } else {
                                EmptyView()
                            }
                        },
                        isActive: Binding(
                            get: { selectedProduct != nil },
                            set: { if !$0 { selectedProduct = nil } }
                        )
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    .padding(.horizontal, 16)
                }
            }
            
            if isSearchFocused {
                Color.black.opacity(0.3)
                    // Make it cover the rest of the screen
                    .frame(height: UIScreen.main.bounds.height)
                    .onTapGesture {
                        isSearchFocused = false
                    }
            }
        }
        .zIndex(1)
            }
            .padding(.vertical, 16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if let initial = initialCategoryName {
                viewModel.initialCategoryName = initial
            }
            viewModel.fetchData()
            // Start banner timer when view appears
            bannerTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                withAnimation {
                    currentBannerIndex = (currentBannerIndex + 1) % bannerImages.count
                }
            }
        }
        .onDisappear {
            // Stop and release timer when view disappears
            bannerTimer?.invalidate()
            bannerTimer = nil
        }
        .sheet(isPresented: $showFilterModal) {
            FilterModalView(viewModel: viewModel)
                .presentationDetents([.large])
        }
    }
    
    // MARK: - Search History View
    private var searchHistoryView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(LocalizedStringKey("recent_searches"))
                    .font(.headline)
                    .foregroundColor(.appText)
                
                Spacer()
                
                if !viewModel.searchHistory.isEmpty {
                    Button(action: {
                        withAnimation {
                            viewModel.clearSearchHistory()
                        }
                    }) {
                        Text(LocalizedStringKey("clear_history"))
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            
            if viewModel.searchHistory.isEmpty {
                Text(LocalizedStringKey("no_recent_searches"))
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .padding()
            } else {
                ForEach(viewModel.searchHistory, id: \.self) { term in
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(term)
                            .foregroundColor(.appText)
                        Spacer()
                        Button(action: {
                            viewModel.removeSearchTerm(term)
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.searchText = term
                        viewModel.saveSearchTerm(term)
                        isSearchFocused = false
                    }
                    Divider().padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Search Suggestions View
    private var searchSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(LocalizedStringKey("suggestions"))
                .font(.headline)
                .foregroundColor(.appText)
                .padding()
            
            if viewModel.searchSuggestions.isEmpty {
                Text(LocalizedStringKey("no_products_found"))
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .padding()
            } else {
                ForEach(viewModel.searchSuggestions) { product in
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.appPrimary)
                        Text(product.name)
                            .foregroundColor(.appText)
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.searchText = product.name
                        viewModel.saveSearchTerm(product.name)
                        isSearchFocused = false
                        selectedProduct = product
                    }
                    Divider().padding(.horizontal)
                }
            }
        }
    }
}

// Enable swipe to back when navigation bar is hidden
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct AllProductsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllProductsView()
        }
    }
}
