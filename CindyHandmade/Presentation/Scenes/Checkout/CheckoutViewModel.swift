import Foundation
import Combine

@MainActor
class CheckoutViewModel: ObservableObject {
    // Form data
    @Published var fullName: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var addressDetail: String = ""
    @Published var notes: String = ""
    @Published var paymentMethod: String = "COD"
    
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
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var checkoutSuccess: Bool = false
    
    private let fetchLocationsUseCase: FetchLocationsUseCase
    private let checkoutUseCase: CheckoutUseCase
    
    init(
        fetchLocationsUseCase: FetchLocationsUseCase = AppDIContainer.shared.makeFetchLocationsUseCase(),
        checkoutUseCase: CheckoutUseCase = AppDIContainer.shared.makeCheckoutUseCase()
    ) {
        self.fetchLocationsUseCase = fetchLocationsUseCase
        self.checkoutUseCase = checkoutUseCase
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
    
    func submitOrder(cartItems: [CartItemDTO]) async {
        guard !fullName.isEmpty, !phone.isEmpty, !addressDetail.isEmpty,
              let province = selectedProvince,
              let district = selectedDistrict,
              let ward = selectedWard else {
            errorMessage = "Vui lòng điền đầy đủ thông tin giao hàng."
            return
        }
        
        let fullAddress = "\(addressDetail), \(ward.name), \(district.name), \(province.name)"
        if !notes.isEmpty {
            // we could append note to address, or the backend should support note
            // since backend doesn't have a note field in the required body, we can just append it
        }
        
        let request = CheckoutRequestDTO(
            fullName: fullName,
            phone: phone,
            province: province.name,
            district: district.name,
            ward: ward.name,
            address: addressDetail,
            paymentMethod: paymentMethod
        )
        
        isSubmitting = true
        errorMessage = nil
        do {
            let _ = try await checkoutUseCase.execute(request: request)
            checkoutSuccess = true
        } catch {
            errorMessage = "Đặt hàng thất bại: \(error.localizedDescription)"
        }
        isSubmitting = false
    }
}
