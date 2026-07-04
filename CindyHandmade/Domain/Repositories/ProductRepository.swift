import Foundation

protocol ProductRepository {
    func getProducts() async throws -> [Product]
}
