import SwiftUI

struct ExploreCollectionCard: View {
    let title: String
    let subtitle: String?
    let imageUrl: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            
            // Dark Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Georgia", size: 22)) // Serif font
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack {
        ExploreCollectionCard(
            title: "Amigurumi",
            subtitle: "Plushies & Toys",
            imageUrl: "https://images.unsplash.com/photo-1596766440742-996fffd0e261?q=80&w=400&auto=format&fit=crop"
        )
        .frame(height: 160)
        
        ExploreCollectionCard(
            title: "Clothing",
            subtitle: nil,
            imageUrl: "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?q=80&w=400&auto=format&fit=crop"
        )
        .frame(height: 160)
    }
    .padding()
}
