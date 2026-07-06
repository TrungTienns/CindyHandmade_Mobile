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
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.appTextSecondary)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)
                    .lineLimit(1)
                
                Text(price)
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
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
        imageUrl: "https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=400&auto=format&fit=crop"
    )
    .environmentObject(WishlistManager.shared)
}
