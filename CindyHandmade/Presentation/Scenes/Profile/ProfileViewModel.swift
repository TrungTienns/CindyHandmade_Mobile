import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var isUpdatingProfile: Bool = false
    @Published var errorMessage: String?
    
    private let getProfileUseCase: GetProfileUseCase
    private let updateProfileUseCase: UpdateProfileUseCase
    
    init(getProfileUseCase: GetProfileUseCase = AppDIContainer.shared.makeGetProfileUseCase(),
         updateProfileUseCase: UpdateProfileUseCase = AppDIContainer.shared.makeUpdateProfileUseCase()) {
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
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
    
    func updateProfile(newName: String, completion: @escaping (Bool) -> Void) {
        isUpdatingProfile = true
        errorMessage = nil
        
        Task {
            do {
                let updatedUser = try await updateProfileUseCase.execute(name: newName)
                self.user = updatedUser
                completion(true)
            } catch {
                self.errorMessage = "Lỗi đổi tên: \(error.localizedDescription)"
                completion(false)
            }
            self.isUpdatingProfile = false
        }
    }
}
