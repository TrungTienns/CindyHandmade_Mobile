import SwiftUI

struct AddressBookView: View {
    @EnvironmentObject var addressManager: AddressManager
    @Environment(\.dismiss) var dismiss
    @State private var showAddAddress = false
    
    // Support selecting an address from Checkout
    var isSelectionMode: Bool = false
    var onAddressSelected: ((Address) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    if addressManager.addresses.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "map")
                                .font(.system(size: 60))
                                .foregroundColor(.appTextSecondary.opacity(0.5))
                            Text(LocalizedStringKey("no_saved_addresses"))
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(addressManager.addresses) { address in
                            AddressRowView(address: address, isSelectionMode: isSelectionMode) {
                                if isSelectionMode {
                                    onAddressSelected?(address)
                                    dismiss()
                                } else {
                                    // Make default action if not in selection mode
                                    addressManager.setDefaultAddress(id: address.id)
                                }
                            } onDelete: {
                                addressManager.removeAddress(id: address.id)
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Add New Address Button
            VStack {
                Divider()
                Button(action: {
                    showAddAddress = true
                }) {
                    Text(LocalizedStringKey("add_new_address"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appText)
                        .clipShape(Capsule())
                }
                .padding()
            }
            .background(Color.appBackground)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(isSelectionMode ? NSLocalizedString("select_address", comment: "") : NSLocalizedString("address_book", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddAddress) {
            AddAddressView()
        }
    }
}

struct AddressRowView: View {
    let address: Address
    let isSelectionMode: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(address.name)
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    if address.isDefault {
                        Text(LocalizedStringKey("default_badge"))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appPrimary)
                            .clipShape(Capsule())
                    }
                }
                
                Text(address.phone)
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                
                Text(address.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isSelectionMode {
                Button(action: onSelect) {
                    Text(LocalizedStringKey("select_btn"))
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
            } else {
                Menu {
                    if !address.isDefault {
                        Button(LocalizedStringKey("set_as_default"), action: onSelect)
                    }
                    Button(LocalizedStringKey("delete"), role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.appTextSecondary)
                        .padding(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
