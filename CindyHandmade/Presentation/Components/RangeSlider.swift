import SwiftUI

struct RangeSlider: View {
    @Binding var lowerBound: Double
    @Binding var upperBound: Double
    
    let range: ClosedRange<Double>
    let step: Double
    let tintColor: Color
    
    @State private var leftThumbLocation: CGFloat = 0
    @State private var rightThumbLocation: CGFloat = 1
    
    @State private var leftThumbLastLocation: CGFloat = 0
    @State private var rightThumbLastLocation: CGFloat = 1
    
    @State private var isDragging: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let sliderWidth = max(1, width - 28) // 28 is thumb size
            
            let leftCenter = leftThumbLocation * sliderWidth + 14
            let rightCenter = rightThumbLocation * sliderWidth + 14
            
            ZStack(alignment: .leading) {
                // Background Track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Active Track
                Rectangle()
                    .fill(tintColor)
                    .frame(height: 4)
                    .padding(.leading, leftCenter)
                    .padding(.trailing, width - rightCenter)
                    .cornerRadius(2)
                
                // Left Thumb
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 3)
                    .frame(width: 28, height: 28)
                    .offset(x: leftThumbLocation * sliderWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let dragAmount = value.translation.width / sliderWidth
                                leftThumbLocation = min(max(0, leftThumbLastLocation + dragAmount), rightThumbLocation)
                                updateBounds()
                            }
                            .onEnded { _ in
                                leftThumbLastLocation = leftThumbLocation
                                isDragging = false
                            }
                    )
                
                // Right Thumb
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 3)
                    .frame(width: 28, height: 28)
                    .offset(x: rightThumbLocation * sliderWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let dragAmount = value.translation.width / sliderWidth
                                rightThumbLocation = max(min(1, rightThumbLastLocation + dragAmount), leftThumbLocation)
                                updateBounds()
                            }
                            .onEnded { _ in
                                rightThumbLastLocation = rightThumbLocation
                                isDragging = false
                            }
                    )
            }
            .onAppear {
                let rangeLength = range.upperBound - range.lowerBound
                if rangeLength > 0 {
                    leftThumbLocation = CGFloat((lowerBound - range.lowerBound) / rangeLength)
                    rightThumbLocation = CGFloat((upperBound - range.lowerBound) / rangeLength)
                }
                leftThumbLastLocation = leftThumbLocation
                rightThumbLastLocation = rightThumbLocation
            }
            .onChange(of: lowerBound) { newValue in
                guard !isDragging else { return }
                let rangeLength = range.upperBound - range.lowerBound
                if rangeLength > 0 {
                    leftThumbLocation = CGFloat((newValue - range.lowerBound) / rangeLength)
                    leftThumbLastLocation = leftThumbLocation
                }
            }
            .onChange(of: upperBound) { newValue in
                guard !isDragging else { return }
                let rangeLength = range.upperBound - range.lowerBound
                if rangeLength > 0 {
                    rightThumbLocation = CGFloat((newValue - range.lowerBound) / rangeLength)
                    rightThumbLastLocation = rightThumbLocation
                }
            }
        }
        .frame(height: 30)
    }
    
    private func updateBounds() {
        let rangeLength = range.upperBound - range.lowerBound
        
        let newLower = range.lowerBound + Double(leftThumbLocation) * rangeLength
        let newUpper = range.lowerBound + Double(rightThumbLocation) * rangeLength
        
        lowerBound = round(newLower / step) * step
        upperBound = round(newUpper / step) * step
    }
}
