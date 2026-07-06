import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    @EnvironmentObject var wishlistManager: WishlistManager
    
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
                    } else if let error = viewModel.errorMessage, viewModel.products.isEmpty {
                        Text(error)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        // Filter products dynamically so they disappear if un-hearted
                        let activeWishlist = viewModel.products.filter { wishlistManager.wishlistedProductIds.contains($0.id) }
                        
                        if activeWishlist.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart.slash")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("Your wishlist is empty.")
                                    .font(.headline)
                                    .foregroundColor(.appTextSecondary)
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
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
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
        }
    }
}

#Preview {
    WishlistView()
        .environmentObject(WishlistManager.shared)
}
