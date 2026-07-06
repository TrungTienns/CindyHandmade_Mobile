import SwiftUI

struct WavyHeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 80))
        
        path.addCurve(
            to: CGPoint(x: 0, y: rect.maxY - 20),
            control1: CGPoint(x: rect.maxX * 0.75, y: rect.maxY + 30),
            control2: CGPoint(x: rect.maxX * 0.25, y: rect.maxY - 120)
        )
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    WavyHeaderShape()
        .fill(Color.appPrimary)
        .frame(height: 300)
}
