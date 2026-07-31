import Foundation

class SearchHistoryManager {
    static let shared = SearchHistoryManager()
    
    private let maxHistoryCount = 10
    private let userDefaultsKey = "search_history_keywords"
    
    private init() {}
    
    func getHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
    }
    
    func addSearchTerm(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var history = getHistory()
        
        // Remove if exists to bring it to the top
        if let index = history.firstIndex(of: trimmed) {
            history.remove(at: index)
        }
        
        // Insert at beginning
        history.insert(trimmed, at: 0)
        
        // Keep only top maxHistoryCount
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        UserDefaults.standard.set(history, forKey: userDefaultsKey)
    }
    
    func removeSearchTerm(_ term: String) {
        var history = getHistory()
        if let index = history.firstIndex(of: term) {
            history.remove(at: index)
            UserDefaults.standard.set(history, forKey: userDefaultsKey)
        }
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
