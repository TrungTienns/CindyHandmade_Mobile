import Foundation
import Combine

protocol RegisterUseCase {
    func execute(name: String, email: String, password: String) async throws -> User
}

final class DefaultRegisterUseCase: RegisterUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(name: String, email: String, password: String) async throws -> User {
        return try await authRepository.register(name: name, email: email, password: password)
    }
}
