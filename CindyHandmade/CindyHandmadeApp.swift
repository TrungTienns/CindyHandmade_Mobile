import SwiftUI
import UserNotifications

@main
struct CindyHandmadeApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "en"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                SplashView()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .environment(\.locale, .init(identifier: language))
            .environmentObject(WishlistManager.shared)
            .environmentObject(CartManager.shared)
            .environmentObject(AddressManager.shared)
            .environmentObject(NotificationManager.shared)
            .onAppear {
                NotificationManager.shared.requestPermission()
            }
        }
    }
}
