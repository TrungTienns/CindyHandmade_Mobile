import SwiftUI

struct FilterModalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AllProductsViewModel
    
    // Formatting max price
    private var formattedMaxPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let priceString = formatter.string(from: NSNumber(value: viewModel.maxPrice)) ?? "\(viewModel.maxPrice)"
        return "\(priceString) ₫"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Price Range Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("max_price")
                            .font(.headline)
                            .foregroundColor(.appText)
                        Spacer()
                        Text(formattedMaxPrice)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.appPrimary)
                    }
                    
                    Slider(value: $viewModel.maxPrice, in: 0...10000000, step: 100000)
                        .accentColor(.appPrimary)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                
                Divider()
                    .padding(.horizontal)
                
                // Sort Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("sort_by")
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    VStack(spacing: 12) {
                        SortOptionRow(
                            title: "none",
                            isSelected: viewModel.sortOption == .none,
                            action: { viewModel.sortOption = .none }
                        )
                        
                        SortOptionRow(
                            title: "price_low_high",
                            isSelected: viewModel.sortOption == .priceLowToHigh,
                            action: { viewModel.sortOption = .priceLowToHigh }
                        )
                        
                        SortOptionRow(
                            title: "price_high_low",
                            isSelected: viewModel.sortOption == .priceHighToLow,
                            action: { viewModel.sortOption = .priceHighToLow }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Apply Button
                Button(action: {
                    dismiss()
                }) {
                    Text("apply")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
    }
}

struct SortOptionRow: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .appPrimary : .appText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.appPrimary)
                }
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 1)
            )
        }
    }
}
