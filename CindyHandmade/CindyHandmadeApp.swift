//
//  CindyHandmadeApp.swift
//  CindyHandmade
//
//  Created by TrungTien on 1/7/26.
//

import SwiftUI

@main
struct CindyHandmadeApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "en"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .environment(\.locale, .init(identifier: language))
            .environmentObject(WishlistManager.shared)
            .environmentObject(CartManager.shared)
            .environmentObject(AddressManager.shared)
        }
    }
}
