import Foundation

protocol GetProfileUseCase {
    func execute() async throws -> User
}

final class DefaultGetProfileUseCase: GetProfileUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute() async throws -> User {
        return try await authRepository.getProfile()
    }
}
