import Foundation

enum OrderTabStatus: String, CaseIterable {
    case all = "all_status"
    case toPay = "to_pay"
    case toShip = "to_ship"
    case toReceive = "to_receive"
    case completed = "completed"
    case cancelled = "cancelled"
    
    // Map UI tab to backend statuses
    var apiStatuses: [String] {
        switch self {
        case .all: return [] // empty means no filter
        case .toPay: return ["pending"]
        case .toShip: return ["confirm", "processing"]
        case .toReceive: return ["shipped"]
        case .completed: return ["delivered"]
        case .cancelled: return ["cancelled"]
        }
    }
}
