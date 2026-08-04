import SwiftUI

struct ResetPasswordView: View {
    let email: String
    let otp: String
    @Environment(\.dismiss) var dismiss
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showNewPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isSuccess: Bool = false

    private let authRepository: AuthRepository = AppDIContainer.shared.makeAuthRepository()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.appText)
                            .padding(12)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.06), radius: 4)
                    }
                    Spacer()
                    Text(LocalizedStringKey("reset_password"))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)

                if isSuccess {
                    successView
                } else {
                    formView
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var formView: some View {
        ScrollView {
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.green)
                }

                VStack(spacing: 8) {
                    Text(LocalizedStringKey("reset_password_title"))
                        .font(.title2).fontWeight(.bold).foregroundColor(.appText)
                        .multilineTextAlignment(.center)
                    Text(LocalizedStringKey("reset_password_desc"))
                        .font(.subheadline).foregroundColor(.gray)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }

                VStack(spacing: 16) {
                    // New password
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey("new_password_label"))
                            .font(.caption).fontWeight(.semibold).foregroundColor(.gray).textCase(.uppercase)
                        HStack {
                            if showNewPassword {
                                TextField(LocalizedStringKey("password_placeholder"), text: $newPassword)
                            } else {
                                SecureField(LocalizedStringKey("password_placeholder"), text: $newPassword)
                            }
                            Button(action: { showNewPassword.toggle() }) {
                                Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                    }

                    // Confirm password
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey("confirm_password_label"))
                            .font(.caption).fontWeight(.semibold).foregroundColor(.gray).textCase(.uppercase)
                        HStack {
                            if showConfirmPassword {
                                TextField(LocalizedStringKey("password_placeholder"), text: $confirmPassword)
                            } else {
                                SecureField(LocalizedStringKey("password_placeholder"), text: $confirmPassword)
                            }
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                            confirmPassword.isEmpty ? Color.gray.opacity(0.2) :
                                (newPassword == confirmPassword ? Color.green : Color.red)
                        ))
                    }
                }
                .padding(.horizontal)

                if let error = errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }

                Button(action: { submitReset() }) {
                    HStack {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text(LocalizedStringKey("reset_password_btn")).fontWeight(.bold) }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(newPassword.isEmpty || confirmPassword.isEmpty ? Color.gray.opacity(0.3) : Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(newPassword.isEmpty || confirmPassword.isEmpty || isLoading)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var successView: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle().fill(Color.green.opacity(0.15)).frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60)).foregroundColor(.green)
            }
            Text(LocalizedStringKey("reset_password_success"))
                .font(.title2).fontWeight(.bold).foregroundColor(.appText).multilineTextAlignment(.center)
            Text(LocalizedStringKey("reset_password_success_desc"))
                .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)

            Button(action: {
                // Pop to root (back to Login)
                NotificationCenter.default.post(name: NSNotification.Name("popToRoot"), object: nil)
            }) {
                Text(LocalizedStringKey("back_to_login"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.appPrimary).foregroundColor(.white).cornerRadius(14)
            }
            .padding(.horizontal)
            Spacer()
        }
    }

    private func submitReset() {
        errorMessage = nil
        guard newPassword == confirmPassword else {
            errorMessage = NSLocalizedString("error_password_mismatch", comment: "")
            return
        }
        guard newPassword.count >= 6 else {
            errorMessage = NSLocalizedString("error_password_too_short", comment: "")
            return
        }
        Task {
            isLoading = true
            do {
                _ = try await authRepository.resetPassword(email: email, otp: otp, newPassword: newPassword)
                isSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
