import Foundation

enum AppEnvironment {
    // URL Backend (dùng localhost cho iOS Simulator)
    static let baseURL = "http://127.0.0.1:8080/api"
    
    // Nếu dùng thiết bị thật (iPhone), cần thay bằng IP mạng LAN của máy tính
    // Hiện tại IP máy bạn đang là 192.168.1.31
    // static let baseURL = "http://192.168.1.31:8080/api"
}
