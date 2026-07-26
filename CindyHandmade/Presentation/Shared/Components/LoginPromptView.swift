import SwiftUI

struct LoginPromptView: View {
    let iconName: String
    let titleKey: String
    let descriptionKey: String
    let onLoginTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundColor(.appPrimary)
            }
            
            // Text Content
            VStack(spacing: 12) {
                Text(LocalizedStringKey(titleKey))
                    .font(.custom("Georgia", size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey(descriptionKey))
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
                .frame(height: 16)
            
            // Login Button
            Button(action: onLoginTapped) {
                HStack(spacing: 8) {
                    Text(LocalizedStringKey("login_now_btn"))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                }
            }
            .buttonStyle(PremiumLoginButtonStyle())
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PremiumLoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.appPrimary.opacity(0.85), Color.appPrimary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.appPrimary.opacity(0.3), radius: configuration.isPressed ? 4 : 10, x: 0, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    LoginPromptView(
        iconName: "person.crop.circle.badge.questionmark",
        titleKey: "login_required_title",
        descriptionKey: "login_required_desc_profile",
        onLoginTapped: {}
    )
}
