import SwiftUI

enum TabItem: Int, CaseIterable {
    case home = 0
    case catalog
    case cart
    case profile
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .catalog: return "square.grid.2x2"
        case .cart: return "bag"
        case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .catalog: return "Catalog"
        case .cart: return "Cart"
        case .profile: return "Profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var cartBadgeCount: Int = 0
    
    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Spacer()
                
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == tab ? .appText : .appTextSecondary)
                            
                            // Badge for Cart
                            if tab == .cart && cartBadgeCount > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -2)
                            }
                        }
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .appText : .appTextSecondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    // Active Background (Pill shape)
                    .background(
                        selectedTab == tab ? Color.appPrimary.opacity(0.3) : Color.clear
                    )
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(Color.appBackground)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home), cartBadgeCount: 2)
}
