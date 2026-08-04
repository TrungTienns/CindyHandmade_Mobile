import Foundation
import Combine

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var navigateToOtp: Bool = false

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = AppDIContainer.shared.makeAuthRepository()) {
        self.authRepository = authRepository
    }

    func sendOtp() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = NSLocalizedString("error_email_required", comment: "")
            return
        }
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let message = try await authRepository.forgotPassword(email: email.lowercased().trimmingCharacters(in: .whitespaces))
                successMessage = message
                navigateToOtp = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
