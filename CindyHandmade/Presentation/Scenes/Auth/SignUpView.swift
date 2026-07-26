import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, confirmPassword
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
            
            // Wavy Header Background
            ZStack {
                Image("login_pattern")
                    .resizable()
                    .scaledToFill()
                
                Color.appPrimary.opacity(0.8)
            }
            .clipShape(WavyHeaderShape())
            .frame(height: 300)
            .ignoresSafeArea(edges: .top)
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                    .frame(height: 180)
                
                // Sign Up State
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStringKey("sign_up"))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.appText)
                            .padding(.bottom, 10)
                        
                        VStack(spacing: 20) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey("full_name"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(focusedField == .name ? .appPrimary : .gray)
                                    TextField(NSLocalizedString("enter_name", comment: ""), text: $viewModel.name)
                                        .autocapitalization(.words)
                                        .focused($focusedField, equals: .name)
                                }
                                Divider()
                                    .background(focusedField == .name ? Color.appPrimary : Color.gray.opacity(0.3))
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey("email"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(focusedField == .email ? .appPrimary : .gray)
                                    TextField("demo@email.com", text: $viewModel.email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .focused($focusedField, equals: .email)
                                }
                                Divider()
                                    .background(focusedField == .email ? Color.appPrimary : Color.gray.opacity(0.3))
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey("password"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(focusedField == .password ? .appPrimary : .gray)
                                    SecureField(NSLocalizedString("enter_password", comment: ""), text: $viewModel.password)
                                        .focused($focusedField, equals: .password)
                                }
                                Divider()
                                    .background(focusedField == .password ? Color.appPrimary : Color.gray.opacity(0.3))
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey("confirm_password"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack {
                                    Image(systemName: "lock.shield")
                                        .foregroundColor(focusedField == .confirmPassword ? .appPrimary : .gray)
                                    SecureField(NSLocalizedString("re_enter_password", comment: ""), text: $viewModel.confirmPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                }
                                Divider()
                                    .background(focusedField == .confirmPassword ? Color.appPrimary : Color.gray.opacity(0.3))
                            }
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.top, 4)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        Button(action: {
                            viewModel.register()
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text(LocalizedStringKey("sign_up"))
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.appPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                        .disabled(viewModel.isLoading)
                        
                        HStack {
                            Spacer()
                            Text(LocalizedStringKey("already_have_account"))
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                            Button(action: {
                                dismiss()
                            }) {
                                Text(LocalizedStringKey("login"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appPrimary)
                            }
                            Spacer()
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.registerSuccess) { success in
            if success {
                // Return to previous screen (LoginView) which will also detect token and dismiss, or just dismiss
                dismiss()
            }
        }
    }
}

#Preview {
    SignUpView()
}
