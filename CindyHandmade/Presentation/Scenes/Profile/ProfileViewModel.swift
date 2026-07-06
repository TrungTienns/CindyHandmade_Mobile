import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let getProfileUseCase: GetProfileUseCase
    
    init(getProfileUseCase: GetProfileUseCase = AppDIContainer.shared.makeGetProfileUseCase()) {
        self.getProfileUseCase = getProfileUseCase
    }
    
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedUser = try await getProfileUseCase.execute()
                self.user = fetchedUser
            } catch {
                self.errorMessage = "Không thể lấy thông tin người dùng"
            }
            self.isLoading = false
        }
    }
    
    func logout() {
        AppDIContainer.shared.tokenManager.deleteToken()
        self.user = nil
    }
}
