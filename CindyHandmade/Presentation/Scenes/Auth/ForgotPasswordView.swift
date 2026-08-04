import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.appText)
                                .padding(12)
                                .background(Color.appCardBackground)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 4)
                        }
                        Spacer()
                        Text(LocalizedStringKey("forgot_password"))
                            .font(.custom("Georgia", size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        Spacer()
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    ScrollView {
                        VStack(spacing: 28) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 44))
                                    .foregroundColor(.appPrimary)
                            }

                            // Description
                            VStack(spacing: 8) {
                                Text(LocalizedStringKey("forgot_password_title"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appText)
                                    .multilineTextAlignment(.center)
                                Text(LocalizedStringKey("forgot_password_desc"))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey("email_label"))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                    .textCase(.uppercase)

                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.gray)
                                    TextField(LocalizedStringKey("email_placeholder"), text: $viewModel.email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                }
                                .padding()
                                .background(Color.appCardBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                            }
                            .padding(.horizontal)

                            // Error Message
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            // Send OTP Button
                            Button(action: { viewModel.sendOtp() }) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text(LocalizedStringKey("send_otp"))
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.email.isEmpty ? Color.gray.opacity(0.3) : Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, y: 4)
                            }
                            .disabled(viewModel.email.isEmpty || viewModel.isLoading)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.navigateToOtp) {
                OtpVerifyView(email: viewModel.email)
            }
        }
    }
}
