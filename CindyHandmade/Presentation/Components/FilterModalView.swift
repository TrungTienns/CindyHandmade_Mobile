import SwiftUI

struct FilterModalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AllProductsViewModel
    
    // Formatting price range
    private var formattedPriceRange: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        
        let minString = formatter.string(from: NSNumber(value: viewModel.minPrice)) ?? "\(viewModel.minPrice)"
        let maxString = formatter.string(from: NSNumber(value: viewModel.maxPrice)) ?? "\(viewModel.maxPrice)"
        
        return "\(minString) ₫ - \(maxString) ₫"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Price Range Section
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("price_range")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                Text(formattedPriceRange)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.appPrimary)
                            }
                            
                            RangeSlider(
                                lowerBound: $viewModel.minPrice,
                                upperBound: $viewModel.maxPrice,
                                range: 0...20000000,
                                step: 100000,
                                tintColor: .appPrimary
                            )
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
                        .padding(.bottom, 24)
                    } // End ScrollView
                    
                    // Action Buttons
                    VStack(spacing: 12) {
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
                        
                        // Reset Button
                        Button(action: {
                            viewModel.minPrice = 0
                            viewModel.maxPrice = 20000000
                            viewModel.sortOption = .none
                        }) {
                            Text("reset")
                                .font(.headline)
                                .foregroundColor(.appPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appCardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appPrimary, lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                    .background(Color.appBackground.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5))
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
}
