import Foundation

struct LocationEntity: Identifiable, Equatable, Hashable {
    let id = UUID()
    let code: Int
    let name: String
    
    // For SwiftUI Picker
    static func == (lhs: LocationEntity, rhs: LocationEntity) -> Bool {
        return lhs.code == rhs.code
    }
}
