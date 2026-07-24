import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading Orders...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        Task {
                            await viewModel.fetchOrders()
                        }
                    }
                    .padding()
                    .background(Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if viewModel.orders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No orders found.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.orders) { order in
                            OrderCardView(order: order)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchOrders()
        }
    }
}

struct OrderCardView: View {
    let order: OrderHistoryDTO
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Order #\(order.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(order.status.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.status).opacity(0.2))
                    .foregroundColor(statusColor(for: order.status))
                    .cornerRadius(8)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            
            Divider()
            
            if let items = order.items {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: item.product?.imageUrl ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product?.name ?? "Unknown Product")
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Text("Qty: \(item.quantity)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Customer Information")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    detailRow(title: "Name", value: order.fullName)
                    detailRow(title: "Phone", value: order.phone ?? "N/A")
                    
                    let fullAddress = [order.address, order.ward, order.district, order.province]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                    
                    detailRow(title: "Address", value: fullAddress.isEmpty ? "N/A" : fullAddress)
                    detailRow(title: "Payment", value: order.paymentMethod ?? "COD")
                }
                .font(.footnote)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(order.formattedTotalAmount)
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(title):")
                .foregroundColor(.gray)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .foregroundColor(.black)
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "confirm", "processing":
            return .blue
        case "shipped":
            return .purple
        case "delivered":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}
