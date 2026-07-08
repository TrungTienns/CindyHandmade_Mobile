import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case catalog
    case cart
    case wishlist
    case profile
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .catalog: return "square.grid.2x2"
        case .cart: return "bag"
        case .wishlist: return "heart"
        case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "home"
        case .catalog: return "catalog"
        case .cart: return "cart"
        case .wishlist: return "wishlist"
        case .profile: return "profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var cartBadgeCount: Int = 0
    var onTabTapped: ((TabItem) -> Void)? = nil
    
    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Spacer()
                
                Button(action: {
                    if let onTabTapped = onTabTapped {
                        onTabTapped(tab)
                    } else {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .appText : .appTextSecondary)
                            
                            // Badge for Cart
                            if tab == .cart && cartBadgeCount > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -2)
                            }
                        }
                        
                        Text(LocalizedStringKey(tab.title))
                            .font(.system(size: 10, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(selectedTab == tab ? .appText : .appTextSecondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
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
