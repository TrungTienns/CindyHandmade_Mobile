import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddressBook = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.appText)
                            .padding(12)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 3)
                    }
                    
                    Spacer()
                    
                    Text(LocalizedStringKey("checkout_title"))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44) // For symmetry
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                // Customer Information
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey("shipping_information"))
                        .font(.headline)
                        .padding(.top)
                    
                    CustomTextField(placeholder: NSLocalizedString("full_name", comment: ""), text: $viewModel.fullName)
                    CustomTextField(placeholder: NSLocalizedString("phone_number", comment: ""), text: $viewModel.phone, keyboardType: .phonePad)
                    CustomTextField(placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                }
                
                // Address Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizedStringKey("shipping_info"))
                            .font(.headline)
                        Spacer()
                        Button(LocalizedStringKey("choose_address_book")) {
                            showAddressBook = true
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.appPrimary)
                    }
                    
                    // Province Picker
                    if viewModel.isLoadingLocations && viewModel.provinces.isEmpty {
                        ProgressView(LocalizedStringKey("loading_data"))
                    } else {
                        Menu {
                            ForEach(viewModel.provinces) { province in
                                Button(province.name) {
                                    viewModel.selectedProvince = province
                                }
                            }
                        } label: {
                            dropdownLabel(title: viewModel.selectedProvince?.name ?? NSLocalizedString("select_province", comment: ""))
                        }
                    }
                    
                    // District Picker
                    Menu {
                        ForEach(viewModel.districts) { district in
                            Button(district.name) {
                                viewModel.selectedDistrict = district
                            }
                        }
                    } label: {
                        dropdownLabel(title: viewModel.selectedDistrict?.name ?? NSLocalizedString("select_district", comment: ""))
                    }
                    .disabled(viewModel.districts.isEmpty)
                    
                    // Ward Picker
                    Menu {
                        ForEach(viewModel.wards) { ward in
                            Button(ward.name) {
                                viewModel.selectedWard = ward
                            }
                        }
                    } label: {
                        dropdownLabel(title: viewModel.selectedWard?.name ?? NSLocalizedString("select_ward", comment: ""))
                    }
                    .disabled(viewModel.wards.isEmpty)
                    
                    CustomTextField(placeholder: NSLocalizedString("street_address", comment: ""), text: $viewModel.addressDetail)
                    
                    CustomTextField(placeholder: NSLocalizedString("order_notes", comment: ""), text: $viewModel.notes)
                }
                
                // Payment Method
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey("payment_method_title"))
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.appText)
                        Text(LocalizedStringKey("cod_payment"))
                            .font(.subheadline)
                            .foregroundColor(.appText)
                        Spacer()
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appText, lineWidth: 1)
                    )
                }
                
                Button(action: {
                    Task {
                        await viewModel.submitOrder(cartItems: cartManager.cart?.items ?? [])
                    }
                }) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(LocalizedStringKey("place_order"))
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appText)
                .clipShape(Capsule())
                .disabled(viewModel.isSubmitting)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .background(Color.appBackground)
        .task {
            await viewModel.fetchProvinces()
        }
        .alert(LocalizedStringKey("checkout_success"), isPresented: $viewModel.checkoutSuccess) {
            Button("OK", role: .cancel) {
                cartManager.clearCart()
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cartManager.navigateToCatalog = true
                }
            }
        } message: {
            Text(LocalizedStringKey("checkout_success_desc"))
        }
        .sheet(isPresented: $showAddressBook) {
            NavigationView {
                AddressBookView(isSelectionMode: true) { selectedAddress in
                    viewModel.fillAddress(selectedAddress)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func dropdownLabel(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.appText)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.appText.opacity(0.05))
        .cornerRadius(8)
    }
}

// Reusable TextField
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding()
            .background(Color.appText.opacity(0.05))
            .cornerRadius(8)
            .foregroundColor(.appText)
    }
}
