import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var isInitialState = true

    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.3),
                        .black.opacity(0.6),
                        .black.opacity(0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: UIScreen.main.bounds.width * 3) // Make the gradient wide
                .offset(x: isInitialState ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width)
            )
            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear {
                isInitialState = false
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}
