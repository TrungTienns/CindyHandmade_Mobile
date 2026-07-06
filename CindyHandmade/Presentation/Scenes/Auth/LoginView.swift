import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
            
            // Wavy Header Background
            WavyHeaderShape()
                .fill(Color.appPrimary.opacity(0.8)) // Fallback color
                .overlay(
                    Image("login_pattern")
                        .resizable()
                        .scaledToFill()
                        .clipShape(WavyHeaderShape())
                        .opacity(0.4)
                )
                .frame(height: 350)
                .ignoresSafeArea(edges: .top)
            
            VStack {
                Spacer()
                    .frame(height: 200)
                
                // Sign In State
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sign in")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.appText)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 24) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
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
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.appTextSecondary)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(focusedField == .password ? .appPrimary : .gray)
                                SecureField("enter your password", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                                Image(systemName: "eye.slash") // Placeholder for eye icon
                                    .foregroundColor(.gray)
                            }
                            Divider()
                                .background(focusedField == .password ? Color.appPrimary : Color.gray.opacity(0.3))
                        }
                        
                        HStack {
                            Spacer()
                            Text("Forgot Password?")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.appPrimary)
                        }
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Login")
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
                        Text("Don't have an Account ? ")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        + Text("Sign up")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                        Spacer()
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .onChange(of: viewModel.loginSuccess) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    LoginView()
}
