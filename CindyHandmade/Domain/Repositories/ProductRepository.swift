import Foundation

protocol ProductRepository {
    func getProducts() async throws -> [Product]
    func getCategories() async throws -> [Category]
}
