import Foundation

protocol LocationRepository {
    func getProvinces() async throws -> [LocationEntity]
    func getDistricts(provinceCode: Int) async throws -> [LocationEntity]
    func getWards(districtCode: Int) async throws -> [LocationEntity]
}
