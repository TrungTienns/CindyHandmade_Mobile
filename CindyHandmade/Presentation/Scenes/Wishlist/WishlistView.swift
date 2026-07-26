import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var cartManager: CartManager
    @State private var showLogin = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading && viewModel.products.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if viewModel.errorMessage != nil && viewModel.products.isEmpty {
                        VStack {
                            LoginPromptView(
                                iconName: "heart.slash",
                                titleKey: "login_required_title",
                                descriptionKey: "login_required_desc_wishlist",
                                onLoginTapped: {
                                    showLogin = true
                                }
                            )
                            .padding(.top, 40)
                            
                            NavigationLink(destination: LoginView(), isActive: $showLogin) {
                                EmptyView()
                            }
                            .hidden()
                        }
                    } else {
                        // Filter products dynamically so they disappear if un-hearted
                        let activeWishlist = viewModel.products.filter { wishlistManager.wishlistedProductIds.contains($0.id) }
                        
                        if activeWishlist.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart.slash")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("wishlist_empty")
                                    .font(.headline)
                                    .foregroundColor(.appTextSecondary)
                                
                                Button(action: {
                                    cartManager.navigateToCatalog = true
                                }) {
                                    Text("Shop Now")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 12)
                                        .background(Color.appPrimary)
                                        .clipShape(Capsule())
                                }
                                .padding(.top, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(activeWishlist) { product in
                                    ProductCardView(
                                        productId: product.id,
                                        category: product.categoryName,
                                        name: product.name,
                                        price: product.formattedPrice,
                                        imageUrl: product.imageUrl
                                    )
                                    .background(
                                        NavigationLink(destination: ProductDetailView(product: product)) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("wishlist")
                        .font(.custom("Georgia", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                }
            }
            .onAppear {
                viewModel.fetchWishlist()
            }
            .refreshable {
                viewModel.fetchWishlist()
            }
            .onChange(of: showLogin) { isShowing in
                if !isShowing {
                    viewModel.fetchWishlist()
                }
            }
        }
    }
}

#Preview {
    WishlistView()
        .environmentObject(WishlistManager.shared)
}
