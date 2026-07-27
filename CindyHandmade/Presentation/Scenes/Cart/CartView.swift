import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    // Derived properties for UI
    private var cartItems: [CartItemDTO] {
        cartManager.cart?.items ?? []
    }
    
    private var subtotal: Double {
        cartItems.reduce(0) { total, item in
            let price = item.product?.price ?? 0
            return total + (price * Double(item.quantity))
        }
    }
    
    private var total: Double {
        // Assuming delivery is Free for now as per design
        subtotal
    }
    
    // Static formatter — instantiated once, shared across all calls
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter
    }()
    
    private func formattedPrice(_ price: Double) -> String {
        let priceString = Self.priceFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return "\(priceString) ₫"
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Removed back button per user request
                    Spacer().frame(width: 44) // Keep space for alignment if needed, or just remove
                    
                    Spacer()
                    
                    Text("cart_title")
                        .font(.custom("PlayfairDisplay-Bold", size: 22))
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    Text("\(cartItems.count) \(NSLocalizedString("cart", comment: ""))")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Cart Items List
                ScrollView {
                    VStack(spacing: 20) {
                        if cartItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "cart")
                                    .font(.system(size: 60))
                                    .foregroundColor(.appTextSecondary.opacity(0.5))
                                Text("cart_empty")
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
                            .padding(.top, 60)
                        } else {
                            ForEach(cartItems) { item in
                                cartItemRow(item: item)
                                if item.id != cartItems.last?.id {
                                    Divider()
                                        .background(Color.appTextSecondary.opacity(0.2))
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Summary Section
                VStack(spacing: 16) {
                    summaryRow(title: NSLocalizedString("subtotal", comment: ""), value: formattedPrice(subtotal))
                    
                    HStack {
                        Text("delivery")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Text("delivery_free")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(UIColor(hex: "4A7056"))) // A darker green for highlight
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(UIColor(hex: "C4DECE")).opacity(0.5))
                            .clipShape(Capsule())
                    }
                    
                    Divider()
                        .background(Color.appTextSecondary.opacity(0.2))
                    
                    summaryRow(title: NSLocalizedString("total", comment: ""), value: formattedPrice(total), isTotal: true)
                    
                    NavigationLink(destination: CheckoutView()) {
                        Text("continue_checkout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appText)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cartManager.fetchCart()
        }
    }
    
    // MARK: - View Builders
    
    private func cartItemRow(item: CartItemDTO) -> some View {
        HStack(spacing: 16) {
            // Product Image
            let imageUrl = item.product?.images?.first ?? "https://images.unsplash.com/photo-1596766440742-996fffd0e261?q=80&w=400&auto=format&fit=crop"
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.product?.name ?? NSLocalizedString("unknown_product", comment: ""))
                    .font(.headline)
                    .foregroundColor(.appText)
                    .lineLimit(1)
                
                if let size = item.size {
                    Text(size)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                HStack {
                    Text(formattedPrice(item.product?.price ?? 0))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    // Quantity Selector
                    HStack(spacing: 16) {
                        Button(action: {
                            if item.quantity > 1 {
                                cartManager.updateQuantity(productId: item.productId, quantity: item.quantity - 1, size: item.size, color: item.color)
                            } else {
                                cartManager.removeItem(productId: item.productId, size: item.size, color: item.color)
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appText)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appText)
                        
                        Button(action: {
                            cartManager.updateQuantity(productId: item.productId, quantity: item.quantity + 1, size: item.size, color: item.color)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appText)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appCardBackground)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func summaryRow(title: String, value: String, isTotal: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .subheadline)
                .foregroundColor(isTotal ? .appText : .appTextSecondary)
            Spacer()
            Text(value)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(.appText)
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager.shared)
}
