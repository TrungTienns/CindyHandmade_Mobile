import Foundation

enum LocationEndpoint: APIEndpoint {
    case getProvinces
    case getDistricts(provinceCode: Int)
    case getWards(districtCode: Int)
    
    var baseURL: String {
        return "https://provinces.open-api.vn/api"
    }
    
    var path: String {
        switch self {
        case .getProvinces:
            return "/p/"
        case .getDistricts(let code):
            return "/p/\(code)?depth=2"
        case .getWards(let code):
            return "/d/\(code)?depth=2"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getProvinces:
            return nil
        case .getDistricts, .getWards:
            // Thêm depth=2 theo query param. Trong APIClient hiện tại, parameters cho GET có thể không được encode thành query.
            // Sẽ cần sửa URL trực tiếp nếu APIClient không hỗ trợ URL parameters cho GET.
            // Tạm thời sẽ append vào path để an toàn.
            return nil
        }
    }
    
}
