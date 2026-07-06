import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        ZStack(alignment: .leading) {
            if isShowing {
                // Background Dimming
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isShowing = false
                        }
                    }
                
                // Sidebar Content
                VStack(alignment: .leading, spacing: 30) {
                    // Header
                    HStack {
                        Text("settings")
                            .font(.custom("Georgia", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isShowing = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Dark Mode Toggle
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(isDarkMode ? .yellow : .orange)
                            Text("dark_mode")
                                .font(.headline)
                        }
                    }
                    .tint(.appPrimary)
                    
                    Divider()
                    
                    // Language Selection
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("language")
                                .font(.headline)
                        }
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                language = "en"
                            }) {
                                Text("English")
                                    .fontWeight(language == "en" ? .bold : .regular)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(language == "en" ? Color.appPrimary.opacity(0.2) : Color.clear)
                                    .foregroundColor(language == "en" ? .appPrimary : .appTextSecondary)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                language = "fr"
                            }) {
                                Text("Français")
                                    .fontWeight(language == "fr" ? .bold : .regular)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(language == "fr" ? Color.appPrimary.opacity(0.2) : Color.clear)
                                    .foregroundColor(language == "fr" ? .appPrimary : .appTextSecondary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // App Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cindy Handmade")
                            .font(.custom("Georgia", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.appTextSecondary)
                        Text("version")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
                .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                .background(Color.appBackground)
                .edgesIgnoringSafeArea(.all)
                .transition(.move(edge: .leading))
            }
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowing: .constant(true))
    }
}
