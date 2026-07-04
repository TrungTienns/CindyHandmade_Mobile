import SwiftUI

// Một struct tạm để test API
struct TestEndpoint: APIEndpoint {
    // Port 8080 là port mặc định theo file .env của KnitWorkShop_BE
    var baseURL: String = "http://localhost:8080/api" 
    var path: String = "/products" // Lấy thử danh sách sản phẩm
    var method: HTTPMethod = .get
    var headers: [String : String]? = nil
    var parameters: [String : Any]? = nil
}

// Struct để map dữ liệu trả về tạm thời
// Mình dùng struct rỗng với AnyCodable hoặc String nếu muốn in ra thô
// Ở đây gọi API test trả về String cho dễ thấy
struct TestNetworkView: View {
    @State private var resultText: String = "Chưa có dữ liệu"
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test Kết Nối Backend")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                Text(resultText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            Button(action: {
                testConnection()
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Gọi API: /api/products")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
        }
        .padding()
    }
    
    private func testConnection() {
        isLoading = true
        resultText = "Đang gọi API..."
        
        Task {
            do {
                // Tạm thời gọi trực tiếp qua URLSession để lấy chuỗi String (do chưa có DTO cụ thể)
                guard let request = TestEndpoint().urlRequest else {
                    resultText = "Lỗi tạo Request"
                    isLoading = false
                    return
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    if let stringData = String(data: data, encoding: .utf8) {
                        resultText = "Status: \(statusCode)\n\nResponse:\n\(stringData)"
                    } else {
                        resultText = "Status: \(statusCode) (Không thể đọc Data as String)"
                    }
                }
            } catch {
                resultText = "Lỗi kết nối: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

#Preview {
    TestNetworkView()
}
