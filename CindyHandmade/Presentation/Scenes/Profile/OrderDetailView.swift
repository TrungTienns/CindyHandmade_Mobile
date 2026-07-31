import SwiftUI

struct OrderDetailView: View {
    let order: OrderHistoryDTO
    @ObservedObject var viewModel: OrderHistoryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCancelAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Status Header
                orderStatusHeader
                
                // Timeline
                OrderTimelineView(status: order.status ?? "unknown")
                
                // Shipping Address
                shippingAddressCard
                
                // Order Items
                orderItemsCard
                
                // Order Summary
                orderSummaryCard
                
                // Cancel Button (Only for pending orders)
                if order.status?.lowercased() == "pending" {
                    Button(action: {
                        showingCancelAlert = true
                    }) {
                        Text(LocalizedStringKey("cancel_order"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.vertical)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(NSLocalizedString("order_detail", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingCancelAlert) {
            Alert(
                title: Text(LocalizedStringKey("cancel_order_title")),
                message: Text(LocalizedStringKey("cancel_order_message")),
                primaryButton: .destructive(Text(LocalizedStringKey("confirm_cancel"))) {
                    Task {
                        await viewModel.cancelOrder(orderId: order.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel(Text(LocalizedStringKey("keep_order")))
            )
        }
    }
    
    // MARK: - Components
    
    private var orderStatusHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(statusTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(statusDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
            Image(systemName: statusIcon)
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .background(statusColor)
        .shadow(color: statusColor.opacity(0.3), radius: 8, y: 4)
    }
    
    private var shippingAddressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.appPrimary)
                Text(LocalizedStringKey("shipping_info"))
                    .font(.headline)
            }
            
            Divider()
            
            Text(order.fullName ?? "")
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text(order.phone ?? NSLocalizedString("no_phone", comment: ""))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            let fullAddress = [order.address, order.ward, order.district, order.province]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
            
            Text(fullAddress.isEmpty ? NSLocalizedString("no_address", comment: "") : fullAddress)
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var orderItemsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bag")
                    .foregroundColor(.appPrimary)
                Text(LocalizedStringKey("products"))
                    .font(.headline)
            }
            
            Divider()
            
            if let items = order.items {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: 12) {
                        AsyncImage(url: URL(string: item.product?.imageUrl ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product?.name ?? NSLocalizedString("unknown_product", comment: ""))
                                .font(.subheadline)
                                .lineLimit(2)
                            
                            if let color = item.color, let size = item.size {
                                Text(String(format: NSLocalizedString("product_type", comment: ""), color, size))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text(formatPrice(item.priceAtPurchase ?? 0))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("x\(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    if item.id != items.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var orderSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text(LocalizedStringKey("order_code"))
                    .foregroundColor(.gray)
                Spacer()
                Text("#\(order.id)")
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text(LocalizedStringKey("order_date"))
                    .foregroundColor(.gray)
                Spacer()
                Text(order.createdAt?.prefix(10) ?? "") // simple date formatting for demo
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text(LocalizedStringKey("payment_method_title"))
                    .foregroundColor(.gray)
                Spacer()
                Text(order.paymentMethod ?? "COD")
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            HStack {
                Text(LocalizedStringKey("merchandise_subtotal"))
                    .foregroundColor(.gray)
                Spacer()
                Text(order.formattedTotalAmount)
            }
            
            HStack {
                Text(LocalizedStringKey("shipping_fee"))
                    .foregroundColor(.gray)
                Spacer()
                Text(LocalizedStringKey("free_shipping")) // mock
            }
            
            Divider()
            
            HStack {
                Text(LocalizedStringKey("order_total"))
                    .font(.headline)
                Spacer()
                Text(order.formattedTotalAmount)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.appPrimary)
            }
        }
        .font(.subheadline)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private var statusTitle: String {
        switch order.status?.lowercased() ?? "unknown" {
        case "pending": return NSLocalizedString("to_pay", comment: "")
        case "confirm", "processing": return NSLocalizedString("to_ship", comment: "")
        case "shipped": return NSLocalizedString("to_receive", comment: "")
        case "delivered": return NSLocalizedString("completed", comment: "")
        case "cancelled": return NSLocalizedString("cancelled", comment: "")
        default: return NSLocalizedString("status_unknown", comment: "")
        }
    }
    
    private var statusDescription: String {
        switch order.status?.lowercased() ?? "unknown" {
        case "pending": return NSLocalizedString("status_pending_desc", comment: "")
        case "confirm", "processing": return NSLocalizedString("status_processing_desc", comment: "")
        case "shipped": return NSLocalizedString("status_shipped_desc", comment: "")
        case "delivered": return NSLocalizedString("status_delivered_desc", comment: "")
        case "cancelled": return NSLocalizedString("status_cancelled_desc", comment: "")
        default: return ""
        }
    }
    
    private var statusIcon: String {
        switch order.status?.lowercased() ?? "unknown" {
        case "pending": return "clock.fill"
        case "confirm", "processing": return "shippingbox.fill"
        case "shipped": return "box.truck.fill"
        case "delivered": return "checkmark.circle.fill"
        case "cancelled": return "xmark.octagon.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch order.status?.lowercased() ?? "unknown" {
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

// MARK: - Timeline Component

struct OrderTimelineView: View {
    let status: String
    
    private var activeIndex: Int {
        switch status.lowercased() {
        case "pending": return 0
        case "confirm", "processing": return 1
        case "shipped": return 2
        case "delivered": return 3
        case "cancelled": return -1
        default: return 0
        }
    }
    
    var body: some View {
        if activeIndex >= 0 {
            HStack(spacing: 0) {
                TimelineItem(title: NSLocalizedString("timeline_placed", comment: ""), icon: "doc.text", isActive: activeIndex >= 0)
                TimelineLine(isActive: activeIndex >= 1)
                TimelineItem(title: NSLocalizedString("timeline_confirmed", comment: ""), icon: "shippingbox", isActive: activeIndex >= 1)
                TimelineLine(isActive: activeIndex >= 2)
                TimelineItem(title: NSLocalizedString("timeline_shipping", comment: ""), icon: "box.truck", isActive: activeIndex >= 2)
                TimelineLine(isActive: activeIndex >= 3)
                TimelineItem(title: NSLocalizedString("timeline_success", comment: ""), icon: "checkmark.circle", isActive: activeIndex >= 3)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
        } else {
            // Cancelled state
            HStack {
                Spacer()
                Text(LocalizedStringKey("timeline_cancelled"))
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct TimelineItem: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(isActive ? Color.appPrimary : Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(isActive ? .white : .gray)
                        .font(.system(size: 16))
                )
            
            Text(title)
                .font(.system(size: 10, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? .black : .gray)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60)
    }
}

struct TimelineLine: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? Color.appPrimary : Color.gray.opacity(0.3))
            .frame(height: 2)
            .offset(y: -12)
    }
}
