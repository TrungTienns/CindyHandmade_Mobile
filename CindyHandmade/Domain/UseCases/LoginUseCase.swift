import Foundation

protocol LoginUseCase {
    func execute(email: String, password: String) async throws -> User
}

final class DefaultLoginUseCase: LoginUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(email: String, password: String) async throws -> User {
        return try await authRepository.login(email: email, password: password)
    }
}
