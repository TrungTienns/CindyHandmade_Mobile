import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCurrent: Bool = false
    @State private var showNew: Bool = false
    @State private var showConfirm: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3).foregroundColor(.appText)
                            .padding(12).background(Color.appCardBackground)
                            .clipShape(Circle()).shadow(color: Color.black.opacity(0.06), radius: 4)
                    }
                    Spacer()
                    Text(LocalizedStringKey("change_password"))
                        .font(.custom("Georgia", size: 20)).fontWeight(.bold).foregroundColor(.appText)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal).padding(.top, 16).padding(.bottom, 24)

                if viewModel.isSuccess {
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
                    Circle().fill(Color.appPrimary.opacity(0.1)).frame(width: 100, height: 100)
                    Image(systemName: "key.fill").font(.system(size: 44)).foregroundColor(.appPrimary)
                }

                Text(LocalizedStringKey("change_password_desc"))
                    .font(.subheadline).foregroundColor(.gray)
                    .multilineTextAlignment(.center).padding(.horizontal)

                VStack(spacing: 16) {
                    passwordField(
                        label: "current_password_label",
                        placeholder: "password_placeholder",
                        text: $viewModel.currentPassword,
                        showText: $showCurrent
                    )

                    passwordField(
                        label: "new_password_label",
                        placeholder: "password_placeholder",
                        text: $viewModel.newPassword,
                        showText: $showNew
                    )

                    passwordField(
                        label: "confirm_password_label",
                        placeholder: "password_placeholder",
                        text: $viewModel.confirmPassword,
                        showText: $showConfirm,
                        borderColor: viewModel.confirmPassword.isEmpty ? Color.gray.opacity(0.2) :
                            (viewModel.newPassword == viewModel.confirmPassword ? Color.green : Color.red)
                    )
                }
                .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }

                Button(action: { viewModel.changePassword() }) {
                    HStack {
                        if viewModel.isLoading { ProgressView().tint(.white) }
                        else { Text(LocalizedStringKey("save_password")).fontWeight(.bold) }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.appPrimary).foregroundColor(.white)
                    .cornerRadius(14).shadow(color: Color.appPrimary.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(viewModel.isLoading)
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
                Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundColor(.green)
            }
            Text(LocalizedStringKey("change_password_success"))
                .font(.title2).fontWeight(.bold).foregroundColor(.appText).multilineTextAlignment(.center)
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text(LocalizedStringKey("btn_done"))
                    .fontWeight(.bold).frame(maxWidth: .infinity).padding()
                    .background(Color.appPrimary).foregroundColor(.white).cornerRadius(14)
            }
            .padding(.horizontal)
            Spacer()
        }
    }

    @ViewBuilder
    private func passwordField(label: String, placeholder: String, text: Binding<String>, showText: Binding<Bool>, borderColor: Color = Color.gray.opacity(0.2)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(label))
                .font(.caption).fontWeight(.semibold).foregroundColor(.gray).textCase(.uppercase)
            HStack {
                if showText.wrappedValue {
                    TextField(LocalizedStringKey(placeholder), text: text)
                } else {
                    SecureField(LocalizedStringKey(placeholder), text: text)
                }
                Button(action: { showText.wrappedValue.toggle() }) {
                    Image(systemName: showText.wrappedValue ? "eye.slash" : "eye").foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor))
        }
    }
}
