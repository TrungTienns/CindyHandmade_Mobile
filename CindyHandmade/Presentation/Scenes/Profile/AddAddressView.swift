import SwiftUI

struct AddAddressView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var addressManager: AddressManager
    
    @StateObject private var viewModel = AddAddressViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.appText)
                            .padding(12)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 3)
                    }
                    Spacer()
                    Text(LocalizedStringKey("new_address"))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Contact Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(LocalizedStringKey("contact_info"))
                                .font(.headline)
                                .foregroundColor(.appText)
                            
                            CustomTextField(placeholder: NSLocalizedString("full_name", comment: ""), text: $viewModel.fullName)
                            CustomTextField(placeholder: NSLocalizedString("phone_number", comment: ""), text: $viewModel.phone, keyboardType: .phonePad)
                            CustomTextField(placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                        }
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                        
                        // Shipping Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(LocalizedStringKey("shipping_info"))
                                .font(.headline)
                                .foregroundColor(.appText)
                            
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
                        }
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                        
                        // Settings Section
                        VStack {
                            Toggle(LocalizedStringKey("set_default_address"), isOn: $viewModel.setAsDefault)
                                .tint(.appPrimary)
                                .foregroundColor(.appText)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            
            // Bottom Action Button
            VStack {
                Spacer()
                Button(action: saveAddress) {
                    Text(LocalizedStringKey("save_address"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isFormValid ? Color.appText : Color.gray)
                        .clipShape(Capsule())
                        .shadow(color: viewModel.isFormValid ? Color.appText.opacity(0.3) : Color.clear, radius: 10, y: 5)
                }
                .disabled(!viewModel.isFormValid)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.appBackground.opacity(0), Color.appBackground]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchProvinces()
        }
    }
    
    private func saveAddress() {
        if let newAddress = viewModel.createAddress() {
            addressManager.addAddress(newAddress)
            dismiss()
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
