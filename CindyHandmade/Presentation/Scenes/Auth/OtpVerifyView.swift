import SwiftUI
import Combine

struct OtpVerifyView: View {
    let email: String
    @Environment(\.presentationMode) var presentationMode
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToReset: Bool = false
    // Countdown timer: 15 minutes = 900 seconds
    @State private var remainingSeconds: Int = 900
    @State private var canResend: Bool = false
    let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let authRepository: AuthRepository = AppDIContainer.shared.makeAuthRepository()

    private var otpCode: String { otpDigits.joined() }
    private var isOtpComplete: Bool { otpCode.count == 6 }

    private var timerText: String {
        let min = remainingSeconds / 60
        let sec = remainingSeconds % 60
        return String(format: "%02d:%02d", min, sec)
    }

    var body: some View {
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
                    Text(LocalizedStringKey("verify_otp"))
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
                            Image(systemName: "envelope.badge")
                                .font(.system(size: 44))
                                .foregroundColor(.appPrimary)
                        }

                        VStack(spacing: 8) {
                            Text(LocalizedStringKey("otp_title"))
                                .font(.title2).fontWeight(.bold).foregroundColor(.appText)
                                .multilineTextAlignment(.center)
                            Text(email)
                                .font(.subheadline).foregroundColor(.appPrimary).fontWeight(.semibold)
                        }

                        // 6 OTP Boxes
                        HStack(spacing: 10) {
                            ForEach(0..<6, id: \.self) { i in
                                OtpDigitBox(
                                    digit: $otpDigits[i],
                                    isFocused: focusedIndex == i,
                                    onTap: { focusedIndex = i }
                                )
                                .focused($focusedIndex, equals: i)
                                .onChange(of: otpDigits[i]) { _, newVal in
                                    if newVal.count > 1 {
                                        otpDigits[i] = String(newVal.last!)
                                    }
                                    if !newVal.isEmpty && i < 5 {
                                        focusedIndex = i + 1
                                    } else if newVal.isEmpty && i > 0 {
                                        focusedIndex = i - 1
                                    }
                                }
                            }
                        }

                        // Timer + Resend
                        VStack(spacing: 6) {
                            if !canResend {
                                Text(timerText)
                                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                                    .foregroundColor(.appPrimary)
                                Text(LocalizedStringKey("otp_expires_in"))
                                    .font(.caption).foregroundColor(.gray)
                            } else {
                                Text(LocalizedStringKey("otp_expired"))
                                    .font(.caption).foregroundColor(.red)
                            }

                            Button(action: { resendOtp() }) {
                                Text(LocalizedStringKey("resend_otp"))
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(canResend ? .appPrimary : .gray)
                            }
                            .disabled(!canResend)
                        }

                        // Error
                        if let error = errorMessage {
                            Text(error).foregroundColor(.red).font(.caption)
                                .multilineTextAlignment(.center).padding(.horizontal)
                        }

                        // Verify button
                        Button(action: { verifyOtp() }) {
                            HStack {
                                if isLoading { ProgressView().tint(.white) }
                                else { Text(LocalizedStringKey("verify_btn")).fontWeight(.bold) }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isOtpComplete ? Color.appPrimary : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, y: 4)
                        }
                        .disabled(!isOtpComplete || isLoading)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToReset) {
            ResetPasswordView(email: email, otp: otpCode)
        }
        .onReceive(timerPublisher) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                canResend = true
            }
        }
        .onAppear { focusedIndex = 0 }
    }

    private func verifyOtp() {
        // Just navigate — actual validation happens in ResetPasswordView when submitting
        navigateToReset = true
    }

    private func resendOtp() {
        Task {
            _ = try? await authRepository.forgotPassword(email: email)
            remainingSeconds = 900
            canResend = false
            otpDigits = Array(repeating: "", count: 6)
            focusedIndex = 0
        }
    }
}

// MARK: - Single OTP digit box
struct OtpDigitBox: View {
    @Binding var digit: String
    var isFocused: Bool
    var onTap: () -> Void

    var body: some View {
        TextField("", text: $digit)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.appText)
            .frame(width: 48, height: 56)
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.appPrimary : Color.gray.opacity(0.25), lineWidth: isFocused ? 2 : 1)
            )
            .onTapGesture { onTap() }
    }
}
