import SwiftUI

struct CustomAlertView: View {
    var message: LocalizedStringKey
    var primaryButtonText: LocalizedStringKey = "accept"
    var secondaryButtonText: LocalizedStringKey = "cancel"
    
    var primaryAction: () -> Void
    var secondaryAction: () -> Void
    
    var body: some View {
        ZStack {
            // Background Overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    secondaryAction()
                }
            
            // Alert Box
            VStack(spacing: 24) {
                Text(message)
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                
                HStack(spacing: 16) {
                    Button(action: secondaryAction) {
                        Text(secondaryButtonText)
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: primaryAction) {
                        Text(primaryButtonText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.appPrimary)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(24)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 40)
        }
        .zIndex(2)
    }
}

#Preview {
    CustomAlertView(
        message: "logout_confirm",
        primaryAction: {},
        secondaryAction: {}
    )
}
