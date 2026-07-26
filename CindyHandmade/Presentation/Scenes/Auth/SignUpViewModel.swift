import Foundation
import Combine

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registerSuccess = false
    
    private let registerUseCase: RegisterUseCase
    
    init(registerUseCase: RegisterUseCase = AppDIContainer.shared.makeRegisterUseCase()) {
        self.registerUseCase = registerUseCase
    }
    
    func register() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ thông tin."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Mật khẩu xác nhận không khớp."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await registerUseCase.execute(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                self.registerSuccess = true
            } catch {
                self.errorMessage = "Đăng ký thất bại: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
