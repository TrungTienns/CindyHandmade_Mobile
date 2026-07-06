import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loginSuccess = false
    
    private let loginUseCase: LoginUseCase
    
    init(loginUseCase: LoginUseCase = AppDIContainer.shared.makeLoginUseCase()) {
        self.loginUseCase = loginUseCase
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ email và mật khẩu."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await loginUseCase.execute(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
                self.loginSuccess = true
            } catch {
                self.errorMessage = "Đăng nhập thất bại: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
