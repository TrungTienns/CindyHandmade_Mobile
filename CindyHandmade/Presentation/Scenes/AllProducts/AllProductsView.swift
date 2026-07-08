import SwiftUI
import Combine

struct AllProductsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AllProductsViewModel()
    @State private var currentBannerIndex = 0
    @State private var showFilterModal = false
    
    private let bannerImages = ["BannerProducts1", "BannerProducts2", "BannerProducts3"]
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Custom Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.appText)
                            .frame(width: 44, height: 44)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("all_products")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    // Invisible view for symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
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
                .onReceive(timer) { _ in
                    withAnimation {
                        currentBannerIndex = (currentBannerIndex + 1) % bannerImages.count
                    }
                }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("search_product", text: $viewModel.searchText)
                    
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
                            ProgressView()
                                .padding()
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
                    ProgressView()
                        .padding(.top, 40)
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
                                imageUrl: product.imageUrl
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchData()
        }
        .sheet(isPresented: $showFilterModal) {
            FilterModalView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
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
