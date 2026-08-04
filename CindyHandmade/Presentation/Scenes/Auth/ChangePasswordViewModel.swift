import Foundation
import Combine

@MainActor
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess: Bool = false

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = AppDIContainer.shared.makeAuthRepository()) {
        self.authRepository = authRepository
    }

    func changePassword() {
        errorMessage = nil
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = NSLocalizedString("error_fill_all_fields", comment: "")
            return
        }
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
                let _ = try await authRepository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                isSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
