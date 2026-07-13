import SwiftUI

struct HeroBannerView: View {
    var onShopNowTapped: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            Image("bannerShop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Dark Overlay for text readability
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Badge
                Text("new_arrivals")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appPrimary.opacity(0.8))
                    .clipShape(Capsule())
                
                // Title
                Text("banner_title")
                    .font(.custom("Georgia", size: 28)) // Serif font
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                
                // Description
                Text("banner_description")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                
                // Button
                Button(action: {
                    onShopNowTapped?()
                }) {
                    Text("shop_now")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .frame(height: 220)
    }
}

#Preview {
    HeroBannerView()
        .padding()
        .background(Color.appBackground)
}
