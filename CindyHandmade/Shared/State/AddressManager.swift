import Foundation
import Combine

@MainActor
class AddressManager: ObservableObject {
    static let shared = AddressManager()
    
    @Published var addresses: [Address] = []
    
    private let userDefaultsKey = "CindyHandmade_SavedAddresses"
    
    private init() {
        loadAddresses()
    }
    
    func loadAddresses() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decoded = try? JSONDecoder().decode([Address].self, from: data) {
                self.addresses = decoded
            }
        }
    }
    
    private func saveAddresses() {
        if let encoded = try? JSONEncoder().encode(addresses) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func addAddress(_ address: Address) {
        var newAddress = address
        // If it's the first address, make it default automatically
        if addresses.isEmpty {
            newAddress.isDefault = true
        }
        
        if newAddress.isDefault {
            // Remove default from others
            for i in 0..<addresses.count {
                addresses[i].isDefault = false
            }
        }
        
        addresses.append(newAddress)
        saveAddresses()
    }
    
    func updateAddress(_ address: Address) {
        if let index = addresses.firstIndex(where: { $0.id == address.id }) {
            if address.isDefault {
                // Remove default from others
                for i in 0..<addresses.count {
                    addresses[i].isDefault = false
                }
            }
            addresses[index] = address
            saveAddresses()
        }
    }
    
    func removeAddress(id: UUID) {
        let wasDefault = addresses.first(where: { $0.id == id })?.isDefault == true
        addresses.removeAll { $0.id == id }
        
        // If we removed the default, make the first remaining address the default
        if wasDefault, !addresses.isEmpty {
            addresses[0].isDefault = true
        }
        
        saveAddresses()
    }
    
    func setDefaultAddress(id: UUID) {
        for i in 0..<addresses.count {
            addresses[i].isDefault = (addresses[i].id == id)
        }
        saveAddresses()
    }
    
    var defaultAddress: Address? {
        addresses.first(where: { $0.isDefault }) ?? addresses.first
    }
}
