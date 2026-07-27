import Foundation

enum AppEnvironment {
    // Development Environment URL
    // Để chạy trên máy thật (iPhone), ta cần dùng IP cục bộ của máy Mac (ví dụ: 192.168.1.5) thay vì localhost
    static let baseURL = "http://192.168.1.5:8080/api"
    
    // Nếu bạn muốn test trên Simulator, bạn có thể quay lại dùng localhost:
    // static let baseURL = "http://localhost:8080/api"
}
