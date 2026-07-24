import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Customer Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Thông tin giao hàng")
                        .font(.headline)
                        .padding(.top)
                    
                    CustomTextField(placeholder: "Họ và tên *", text: $viewModel.fullName)
                    CustomTextField(placeholder: "Số điện thoại *", text: $viewModel.phone, keyboardType: .phonePad)
                    CustomTextField(placeholder: "Email (Tùy chọn)", text: $viewModel.email, keyboardType: .emailAddress)
                }
                
                // Address Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Địa chỉ")
                        .font(.headline)
                    
                    // Province Picker
                    if viewModel.isLoadingLocations && viewModel.provinces.isEmpty {
                        ProgressView("Đang tải danh sách Tỉnh/TP...")
                    } else {
                        Menu {
                            ForEach(viewModel.provinces) { province in
                                Button(province.name) {
                                    viewModel.selectedProvince = province
                                }
                            }
                        } label: {
                            dropdownLabel(title: viewModel.selectedProvince?.name ?? "Chọn Tỉnh / Thành phố *")
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
                        dropdownLabel(title: viewModel.selectedDistrict?.name ?? "Chọn Quận / Huyện *")
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
                        dropdownLabel(title: viewModel.selectedWard?.name ?? "Chọn Phường / Xã *")
                    }
                    .disabled(viewModel.wards.isEmpty)
                    
                    CustomTextField(placeholder: "Số nhà, Tên đường *", text: $viewModel.addressDetail)
                    
                    CustomTextField(placeholder: "Ghi chú đơn hàng (Tùy chọn)", text: $viewModel.notes)
                }
                
                // Payment Method
                VStack(alignment: .leading, spacing: 16) {
                    Text("Phương thức thanh toán")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.appText)
                        Text("Thanh toán khi nhận hàng (COD)")
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
                
                // Submit Button
                Button(action: {
                    Task {
                        await viewModel.submitOrder(cartItems: cartManager.cart?.items ?? [])
                    }
                }) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("ĐẶT HÀNG NGAY")
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
            .padding()
        }
        .navigationTitle("Thanh toán")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .task {
            await viewModel.fetchProvinces()
        }
        .alert("Checkout Successful!", isPresented: $viewModel.checkoutSuccess) {
            Button("OK", role: .cancel) {
                cartManager.clearCart()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your order has been placed successfully.")
        }
    }
    
    // MARK: - Helper Views
    private func dropdownLabel(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(title.contains("Chọn") ? .gray : .black)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
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
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
    }
}
