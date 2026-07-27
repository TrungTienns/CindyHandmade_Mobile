import SwiftUI

struct ProductCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Skeleton
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 160, height: 200)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 8) {
                // Category Skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 12)
                    .shimmer()
                
                // Title Skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 16)
                    .shimmer()
                
                // Price and Heart Skeleton
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 16)
                        .shimmer()
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .shimmer()
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 160)
        .padding(.bottom, 8)
    }
}

struct CategorySkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 100, height: 40)
            .shimmer()
    }
}

#Preview {
    HStack {
        ProductCardSkeleton()
        ProductCardSkeleton()
    }
    .padding()
}
