import Foundation

protocol UpdateProfileUseCase {
    func execute(name: String) async throws -> User
}

class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(name: String) async throws -> User {
        return try await authRepository.updateProfile(name: name)
    }
}
