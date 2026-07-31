import SwiftUI

struct ProductCardView: View {
    let productId: Int
    let category: String
    let name: String
    let price: String
    let imageUrl: String
    var avgRating: Double? = nil
    
    @EnvironmentObject var wishlistManager: WishlistManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 140, height: 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Wishlist Button
                Image(systemName: wishlistManager.wishlistedProductIds.contains(productId) ? "heart.fill" : "heart")
                    .foregroundColor(wishlistManager.wishlistedProductIds.contains(productId) ? .red : .white)
                    .font(.system(size: 20))
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    .padding(12) // Slightly larger hit area
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.impact(style: .medium)
                        wishlistManager.toggleWishlist(for: productId)
                    }
                
                // Add to Cart Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.appPrimary)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticManager.shared.impact(style: .light)
                                CartManager.shared.addToCart(productId: productId)
                            }
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
                
                
                HStack(spacing: 4) {
                    Text(price)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    if let rating = avgRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.appText)
                        }
                    }
                }
            }
            .frame(width: 140)
        }
        .frame(width: 140)
        .clipped()
        .contentShape(Rectangle())
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
