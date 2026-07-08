import SwiftUI

struct ProductCardView: View {
    let productId: Int
    let category: String
    let name: String
    let price: String
    let imageUrl: String
    
    @EnvironmentObject var wishlistManager: WishlistManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 140, height: 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Wishlist Button
                Button(action: {
                    wishlistManager.toggleWishlist(for: productId)
                }) {
                    Image(systemName: wishlistManager.wishlistedProductIds.contains(productId) ? "heart.fill" : "heart")
                        .foregroundColor(wishlistManager.wishlistedProductIds.contains(productId) ? .red : .white)
                        .font(.system(size: 20))
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .padding(8)
                
                // Add to Cart Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            CartManager.shared.addToCart(productId: productId)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.appPrimary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(6)
                    }
                }
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.appTextSecondary)
                
                Text(name)
                    .font(.custom("Georgia", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)
                    .lineLimit(1)
                
                Text(price)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.appText)
            }
        }
        .frame(width: 140)
    }
}

#Preview {
    ProductCardView(
        productId: 1,
        category: "Amigurumi",
        name: "Little Brown Bear",
        price: "$24.00",
        imageUrl: "https://images.unsplash.com/photo-1595341595379-cf1cb694ea1f?q=80&w=2320&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    )
    .environmentObject(WishlistManager.shared)
}
