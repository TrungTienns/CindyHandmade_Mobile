import Foundation

class FetchLocationsUseCase {
    private let repository: LocationRepository
    
    init(repository: LocationRepository) {
        self.repository = repository
    }
    
    func getProvinces() async throws -> [LocationEntity] {
        return try await repository.getProvinces()
    }
    
    func getDistricts(provinceCode: Int) async throws -> [LocationEntity] {
        return try await repository.getDistricts(provinceCode: provinceCode)
    }
    
    func getWards(districtCode: Int) async throws -> [LocationEntity] {
        return try await repository.getWards(districtCode: districtCode)
    }
}
