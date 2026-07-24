import Foundation

struct ProvinceDTO: Decodable {
    let name: String
    let code: Int
    let division_type: String
    let codename: String
    let phone_code: Int
    let districts: [DistrictDTO]?
    
    func toDomain() -> LocationEntity {
        return LocationEntity(code: self.code, name: self.name)
    }
}

struct DistrictDTO: Decodable {
    let name: String
    let code: Int
    let division_type: String
    let codename: String
    let province_code: Int
    let wards: [WardDTO]?
    
    func toDomain() -> LocationEntity {
        return LocationEntity(code: self.code, name: self.name)
    }
}

struct WardDTO: Decodable {
    let name: String
    let code: Int
    let division_type: String
    let codename: String
    let district_code: Int
    
    func toDomain() -> LocationEntity {
        return LocationEntity(code: self.code, name: self.name)
    }
}
