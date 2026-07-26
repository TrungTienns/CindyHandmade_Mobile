import SwiftUI

struct AddAddressView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var addressManager: AddressManager
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var street: String = ""
    @State private var ward: String = ""
    @State private var district: String = ""
    @State private var city: String = ""
    @State private var setAsDefault: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("contact_info"))) {
                    TextField(LocalizedStringKey("full_name"), text: $name)
                    TextField(LocalizedStringKey("phone_number"), text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text(LocalizedStringKey("shipping_info"))) {
                    TextField(LocalizedStringKey("street_address"), text: $street)
                    TextField(LocalizedStringKey("ward"), text: $ward)
                    TextField(LocalizedStringKey("district"), text: $district)
                    TextField(LocalizedStringKey("city"), text: $city)
                }
                
                Section {
                    Toggle(LocalizedStringKey("set_default_address"), isOn: $setAsDefault)
                }
                
                Section {
                    Button(action: saveAddress) {
                        Text(LocalizedStringKey("save_address"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .listRowBackground(Color.appText)
                    .disabled(name.isEmpty || phone.isEmpty || street.isEmpty || city.isEmpty)
                }
            }
            .navigationTitle(NSLocalizedString("new_address", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                        .foregroundColor(.appText)
                }
            }
        }
    }
    
    private func saveAddress() {
        let newAddress = Address(
            name: name,
            phone: phone,
            street: street,
            ward: ward,
            district: district,
            city: city,
            isDefault: setAsDefault
        )
        addressManager.addAddress(newAddress)
        dismiss()
    }
}
