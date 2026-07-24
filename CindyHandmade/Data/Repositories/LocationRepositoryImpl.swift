import Foundation

class LocationRepositoryImpl: LocationRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = URLSessionAPIClient()) {
        self.apiClient = apiClient
    }
    
    func getProvinces() async throws -> [LocationEntity] {
        let endpoint = LocationEndpoint.getProvinces
        let dtos = try await apiClient.request(endpoint: endpoint, responseType: [ProvinceDTO].self)
        return dtos.map { $0.toDomain() }
    }
    
    func getDistricts(provinceCode: Int) async throws -> [LocationEntity] {
        let endpoint = LocationEndpoint.getDistricts(provinceCode: provinceCode)
        let dto = try await apiClient.request(endpoint: endpoint, responseType: ProvinceDTO.self)
        return dto.districts?.map { $0.toDomain() } ?? []
    }
    
    func getWards(districtCode: Int) async throws -> [LocationEntity] {
        let endpoint = LocationEndpoint.getWards(districtCode: districtCode)
        let dto = try await apiClient.request(endpoint: endpoint, responseType: DistrictDTO.self)
        return dto.wards?.map { $0.toDomain() } ?? []
    }
}
