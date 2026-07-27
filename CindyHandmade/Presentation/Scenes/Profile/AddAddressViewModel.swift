import Foundation
import Combine

@MainActor
class AddAddressViewModel: ObservableObject {
    // Form data
    @Published var fullName: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var addressDetail: String = ""
    @Published var setAsDefault: Bool = false
    
    // Locations
    @Published var provinces: [LocationEntity] = []
    @Published var districts: [LocationEntity] = []
    @Published var wards: [LocationEntity] = []
    
    @Published var selectedProvince: LocationEntity? {
        didSet {
            if let province = selectedProvince {
                Task {
                    await fetchDistricts(for: province.code)
                }
            } else {
                districts = []
                wards = []
                selectedDistrict = nil
                selectedWard = nil
            }
        }
    }
    
    @Published var selectedDistrict: LocationEntity? {
        didSet {
            if let district = selectedDistrict {
                Task {
                    await fetchWards(for: district.code)
                }
            } else {
                wards = []
                selectedWard = nil
            }
        }
    }
    
    @Published var selectedWard: LocationEntity?
    
    // State
    @Published var isLoadingLocations: Bool = false
    @Published var errorMessage: String? = nil
    
    private let fetchLocationsUseCase: FetchLocationsUseCase
    
    init(fetchLocationsUseCase: FetchLocationsUseCase = AppDIContainer.shared.makeFetchLocationsUseCase()) {
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }
    
    func fetchProvinces() async {
        isLoadingLocations = true
        do {
            provinces = try await fetchLocationsUseCase.getProvinces()
        } catch {
            errorMessage = "Lỗi khi tải danh sách Tỉnh/Thành phố."
        }
        isLoadingLocations = false
    }
    
    func fetchDistricts(for provinceCode: Int) async {
        isLoadingLocations = true
        do {
            districts = try await fetchLocationsUseCase.getDistricts(provinceCode: provinceCode)
            selectedDistrict = nil
            selectedWard = nil
            wards = []
        } catch {
            errorMessage = "Lỗi khi tải danh sách Quận/Huyện."
        }
        isLoadingLocations = false
    }
    
    func fetchWards(for districtCode: Int) async {
        isLoadingLocations = true
        do {
            wards = try await fetchLocationsUseCase.getWards(districtCode: districtCode)
            selectedWard = nil
        } catch {
            errorMessage = "Lỗi khi tải danh sách Phường/Xã."
        }
        isLoadingLocations = false
    }
    
    var isFormValid: Bool {
        !fullName.isEmpty && !phone.isEmpty && !addressDetail.isEmpty && selectedProvince != nil && selectedDistrict != nil && selectedWard != nil
    }
    
    func createAddress() -> Address? {
        guard let province = selectedProvince,
              let district = selectedDistrict,
              let ward = selectedWard else { return nil }
        
        return Address(
            name: fullName,
            phone: phone,
            street: addressDetail,
            ward: ward.name,
            district: district.name,
            city: province.name,
            email: email.isEmpty ? nil : email,
            isDefault: setAsDefault
        )
    }
}
