import SwiftUI

struct ProductCardView: View {
    let category: String
    let name: String
    let price: String
    let imageUrl: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 140, height: 140)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.appTextSecondary)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)
                    .lineLimit(1)
                
                Text(price)
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .frame(width: 140)
    }
}

#Preview {
    ProductCardView(
        category: "Amigurumi",
        name: "Little Brown Bear",
        price: "$24.00",
        imageUrl: "https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=400&auto=format&fit=crop"
    )
}
