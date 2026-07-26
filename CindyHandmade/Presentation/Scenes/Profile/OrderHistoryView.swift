import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    @State var selectedTab: OrderTabStatus = .all
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Scrollable Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(OrderTabStatus.allCases, id: \.self) { tab in
                            VStack(spacing: 8) {
                                Text(LocalizedStringKey(tab.rawValue))
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == tab ? .bold : .medium)
                                    .foregroundColor(selectedTab == tab ? .appPrimary : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.appPrimary : Color.clear)
                                    .frame(height: 2)
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView(LocalizedStringKey("loading_orders"))
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(LocalizedStringKey("retry")) {
                            Task {
                                await viewModel.fetchOrders()
                            }
                        }
                        .padding()
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    Spacer()
                } else {
                    let filteredOrders = viewModel.orders.filter { order in
                        if selectedTab == .all { return true }
                        return selectedTab.apiStatuses.contains(order.status.lowercased())
                    }
                    
                    if filteredOrders.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text(LocalizedStringKey("no_orders"))
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredOrders) { order in
                                    NavigationLink(destination: OrderDetailView(order: order)) {
                                        OrderCardView(order: order)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("order_my_orders", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchOrders()
        }
    }
}

struct OrderCardView: View {
    let order: OrderHistoryDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(String(format: NSLocalizedString("order_num", comment: ""), order.id))
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(LocalizedStringKey(statusText(for: order.status)))
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.status).opacity(0.1))
                    .foregroundColor(statusColor(for: order.status))
                    .cornerRadius(4)
            }
            
            Divider()
            
            // First Item Preview
            if let firstItem = order.items?.first {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: firstItem.product?.imageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstItem.product?.name ?? NSLocalizedString("unknown_product", comment: ""))
                            .font(.subheadline)
                            .lineLimit(2)
                        
                        Text(String(format: NSLocalizedString("product_type", comment: ""), firstItem.color ?? "", firstItem.size ?? ""))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text(formatPrice(firstItem.priceAtPurchase))
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("x\(firstItem.quantity)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if (order.items?.count ?? 0) > 1 {
                    Text(String(format: NSLocalizedString("see_more_items", comment: ""), (order.items?.count ?? 0) - 1))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                Text(String(format: NSLocalizedString("items_count", comment: ""), order.items?.reduce(0) { $0 + $1.quantity } ?? 0))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(LocalizedStringKey("total_amount"))
                    .font(.subheadline)
                Text(order.formattedTotalAmount)
                    .font(.headline)
                    .foregroundColor(.appPrimary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    private func statusText(for status: String) -> String {
        switch status.lowercased() {
        case "pending": return "to_pay"
        case "confirm", "processing": return "to_ship"
        case "shipped": return "to_receive"
        case "delivered": return "completed"
        case "cancelled": return "cancelled"
        default: return status
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "confirm", "processing": return .blue
        case "shipped": return .purple
        case "delivered": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
    
    private func formatPrice(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "\(formatter.string(from: NSNumber(value: amount)) ?? "\(amount)") ₫"
    }
}
