import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var wishlistManager: WishlistManager
    
    @State private var selectedImageIndex = 0
    @State private var selectedSize: String = "M"
    @State private var selectedColor: String = "Default"
    @State private var quantity: Int = 1
    
    @StateObject private var viewModel: ProductDetailViewModel
    
    // Review form state
    @State private var rating: Int = 0
    @State private var reviewComment: String = ""
    
    // Mock sizes and colors
    let sizes = ["S", "M", "L"]
    let colors = ["Default", "Pink", "Blue"]
    
    init(product: Product) {
        self.product = product
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: product.id))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Image Gallery
                    ZStack(alignment: .topLeading) {
                        TabView(selection: $selectedImageIndex) {
                            ForEach(0..<product.images.count, id: \.self) { index in
                                AsyncImage(url: URL(string: product.images[index])) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 350)
                        .clipped()
                        
                        // Back Button (Custom Navigation)
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4)
                        }
                        .padding(.top, 50) // Adjust for safe area if hiding nav bar
                        .padding(.leading, 16)
                    }
                    
                    // MARK: - Product Info
                    VStack(alignment: .leading, spacing: 16) {
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(product.categoryName.uppercased())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.appTextSecondary)
                                
                                Text(product.name)
                                    .font(.custom("Georgia", size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.appText)
                            }
                            Spacer()
                            
                            // Wishlist Button
                            Button(action: {
                                HapticManager.shared.impact(style: .medium)
                                wishlistManager.toggleWishlist(for: product.id)
                            }) {
                                Image(systemName: wishlistManager.wishlistedProductIds.contains(product.id) ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(wishlistManager.wishlistedProductIds.contains(product.id) ? .red : .appTextSecondary)
                                    .padding(8)
                                    .background(Color.appCardBackground)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 2)
                            }
                        }
                        
                        Text(product.formattedPrice)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.appPrimary)
                        
                        Divider()
                        
                        // MARK: - Variants (Mocked)
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Size")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                HStack {
                                    ForEach(sizes, id: \.self) { size in
                                        Button(action: { selectedSize = size }) {
                                            Text(size)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 40, height: 40)
                                                .background(selectedSize == size ? Color.appText : Color.appCardBackground)
                                                .foregroundColor(selectedSize == size ? .white : .appText)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        
                        Divider()
                        
                        // MARK: - Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(product.description.isEmpty ? "No description available for this product." : product.description)
                                .font(.body)
                                .foregroundColor(.appTextSecondary)
                                .lineSpacing(4)
                        }
                        
                        Divider()
                        
                        // MARK: - Reviews Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Đánh giá")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                if let avg = product.avgRating, product.reviewCount ?? 0 > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill").foregroundColor(.yellow)
                                        Text(String(format: "%.1f", avg))
                                            .fontWeight(.bold)
                                        Text("(\(product.reviewCount!))")
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                            
                            if viewModel.isLoadingReviews {
                                ProgressView().frame(maxWidth: .infinity)
                            } else {
                                // 1. Submit form (if not reviewed yet)
                                if let myReview = viewModel.myReview {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Đánh giá của bạn")
                                            .font(.subheadline)
                                            .foregroundColor(.appTextSecondary)
                                        
                                        ReviewRow(review: myReview)
                                            .padding()
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(12)
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3)))
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        Text("Bạn nghĩ gì về sản phẩm này?")
                                            .font(.subheadline)
                                            .foregroundColor(.appTextSecondary)
                                        
                                        // Star Selector
                                        HStack {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= rating ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.title2)
                                                    .onTapGesture { rating = star }
                                            }
                                        }
                                        
                                        if rating > 0 {
                                            TextField("Nhập bình luận...", text: $reviewComment)
                                                .padding(12)
                                                .background(Color.appBackground)
                                                .cornerRadius(8)
                                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                                            
                                            Button(action: {
                                                Task {
                                                    await viewModel.submitReview(rating: rating, comment: reviewComment)
                                                }
                                            }) {
                                                if viewModel.isSubmitting {
                                                    ProgressView()
                                                } else {
                                                    Text("Gửi đánh giá")
                                                        .fontWeight(.bold)
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.appPrimary)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .disabled(viewModel.isSubmitting)
                                            
                                            if let error = viewModel.submitError {
                                                Text(error)
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.appCardBackground)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 3)
                                }
                                
                                // 2. Other Reviews List
                                if !viewModel.reviews.isEmpty {
                                    ForEach(viewModel.reviews.filter { $0.id != viewModel.myReview?.id }) { review in
                                        ReviewRow(review: review)
                                        Divider()
                                    }
                                } else if viewModel.myReview == nil {
                                    Text("Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá!")
                                        .font(.subheadline)
                                        .foregroundColor(.appTextSecondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical)
                                }
                            }
                        }
                        
                        // Extra padding at bottom to clear the Add to Cart bar
                        Spacer().frame(height: 100)
                    }
                    .padding(20)
                    .background(Color.appBackground)
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .offset(y: -24) // Overlap the image slightly
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                Task {
                    await viewModel.fetchReviews()
                }
            }
            
            // MARK: - Bottom Bar
            VStack {
                Divider()
                HStack(spacing: 20) {
                    // Quantity Control
                    HStack(spacing: 16) {
                        Button(action: { if quantity > 1 { quantity -= 1 } }) {
                            Image(systemName: "minus")
                                .foregroundColor(.appText)
                        }
                        Text("\(quantity)")
                            .font(.headline)
                            .frame(width: 24)
                        Button(action: { quantity += 1 }) {
                            Image(systemName: "plus")
                                .foregroundColor(.appText)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.appCardBackground)
                    .cornerRadius(30)
                    
                    // Add to Cart Button
                    Button(action: {
                        HapticManager.shared.impact(style: .heavy)
                        cartManager.addToCart(productId: product.id, quantity: quantity, size: selectedSize, color: selectedColor)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                            Text("Add to Cart")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: Color.appPrimary.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.appCardBackground)
            }
        }
        .navigationBarHidden(true)
    }
}

// Helper to round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - ReviewRow Component
struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Avatar Placeholder
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.userName.prefix(1)).uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.appTextSecondary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(i <= review.rating ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
                Spacer()
                Text(review.displayDate)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
            
            if let comment = review.comment, !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.appText)
            }
        }
    }
}

// Preview
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: Product(
            id: 1,
            name: "Cute Amigurumi Bear",
            description: "A very cute amigurumi bear made with 100% cotton yarn. Perfect for a gift or a collectible item. Handcrafted with love.",
            price: 150000,
            formattedPrice: "150.000 ₫",
            imageUrl: "https://images.unsplash.com/photo-1595341595379-cf1cb694ea1f",
            images: ["https://images.unsplash.com/photo-1595341595379-cf1cb694ea1f", "https://images.unsplash.com/photo-1584916201218-f4242ceb4809"],
            categoryName: "Amigurumi",
            avgRating: 4.5,
            reviewCount: 12,
            reviews: []
        ))
        .environmentObject(CartManager.shared)
        .environmentObject(WishlistManager.shared)
    }
}
