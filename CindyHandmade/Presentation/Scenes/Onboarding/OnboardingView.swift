import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let image: String
    let titleKey: String
    let descriptionKey: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    let items: [OnboardingItem] = [
        OnboardingItem(image: "Onboarding1",
                       titleKey: "onboarding_title_1",
                       descriptionKey: "onboarding_desc_1"),
        OnboardingItem(image: "Onboarding2",
                       titleKey: "onboarding_title_2",
                       descriptionKey: "onboarding_desc_2"),
        OnboardingItem(image: "Onboarding3",
                       titleKey: "onboarding_title_3",
                       descriptionKey: "onboarding_desc_3")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ZStack {
                ForEach(0..<items.count, id: \.self) { index in
                    if index == currentPage {
                        OnboardingPageView(item: items[index])
                            .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.6), value: currentPage)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width < -threshold {
                            // Swipe left (next page)
                            if currentPage < items.count - 1 {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    currentPage += 1
                                }
                            }
                        } else if value.translation.width > threshold {
                            // Swipe right (previous page)
                            if currentPage > 0 {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    currentPage -= 1
                                }
                            }
                        }
                    }
            )
            
            // Overlays (Paging Indicator + Buttons)
            VStack {
                Spacer()
                
                // Custom Paging Indicator
                HStack(spacing: 8) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Action Buttons
                if currentPage == items.count - 1 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            hasSeenOnboarding = true
                        }
                    }) {
                        Text(LocalizedStringKey("onboarding_get_started"))
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                } else {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                hasSeenOnboarding = true
                            }
                        }) {
                            Text(LocalizedStringKey("onboarding_skip"))
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                currentPage += 1
                            }
                        }) {
                            Text(LocalizedStringKey("onboarding_next"))
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let item: OnboardingItem
    
    var body: some View {
        ZStack {
            // Full Screen Image
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
            
            // Dark Gradient Overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.1), .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Text Content
            VStack(spacing: 16) {
                Spacer()
                
                Text(LocalizedStringKey(item.titleKey))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(LocalizedStringKey(item.descriptionKey))
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 150)
            .padding(.horizontal, 32)
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
