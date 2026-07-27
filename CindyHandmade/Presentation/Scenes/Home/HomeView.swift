import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: TabItem = .home
    @State private var showLogin = false
    @State private var categoryToExplore: String?
    @State private var showSideMenu = false
    
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
            // Main Content Area
            Group {
                switch selectedTab {
                case .home:
                    homeContent
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)), removal: .opacity))
                case .catalog:
                    AllProductsView(initialCategoryName: categoryToExplore)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)), removal: .opacity))
                case .cart:
                    NavigationView {
                        CartView()
                    }
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)), removal: .opacity))
                case .wishlist:
                    WishlistView()
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)), removal: .opacity))
                case .profile:
                    NavigationView {
                        ProfileView(onMenuTapped: {
                            withAnimation(.easeInOut) {
                                showSideMenu = true
                            }
                        })
                    }
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)), removal: .opacity))
                }
            }
            .id(selectedTab) // Forces SwiftUI to treat each case as a distinct view for transitions
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, cartBadgeCount: cartManager.cart?.items.count ?? 0, onTabTapped: { tab in
                if tab == .home && selectedTab == .home {
                    // Pop to root (Home)
                    categoryToExplore = nil
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = tab
                }
            })
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .background(Color.appBackground.ignoresSafeArea())
            .onAppear {
                viewModel.fetchTopSellers()
            }
            .sheet(isPresented: $showLogin, onDismiss: {
                viewModel.fetchTopSellers() // Refresh profile after login
            }) {
                LoginView()
            }
            
            SideMenuView(isShowing: $showSideMenu)
                .zIndex(1)
            
            // Success Alert Overlay
            if cartManager.showSuccessMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                        Text("added_to_cart_success")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(UIColor(hex: "4A7056")).opacity(0.95))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                    .padding(.bottom, 75)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: cartManager.showSuccessMessage)
                .allowsHitTesting(false)
                .zIndex(2)
            }
        }
        .alert(LocalizedStringKey("error"), isPresented: $cartManager.showErrorAlert) {
            Button(LocalizedStringKey("ok"), role: .cancel) { }
        } message: {
            Text(cartManager.errorMessage ?? NSLocalizedString("error_add_cart", comment: ""))
        }
        .onChange(of: cartManager.navigateToCatalog) { newValue in
            if newValue {
                selectedTab = .catalog
                cartManager.navigateToCatalog = false
            }
        }
    }
    
    // Main Home Content
    private var homeContent: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // 1. Header
                    headerSection
                    
                    // 2. Greeting & Hero Banner
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                if viewModel.userName == "Guest" {
                                    Text("welcome_guest")
                                        .font(.custom("Georgia", size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(.appText)
                                } else {
                                    (Text("welcome_back") + Text(" \(viewModel.userName)."))
                                        .font(.custom("Georgia", size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(.appText)
                                }
                                
                                Text("find_cozy")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.userName == "Guest" {
                                Button(action: {
                                    showLogin = true
                                }) {
                                    Text("login")
                                }
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appPrimary)
                                .cornerRadius(12)
                            }
                        }
                        
                        HeroBannerView(onShopNowTapped: {
                            categoryToExplore = nil
                            selectedTab = .catalog
                        })
                    }
                    
                    // Divider
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // 3. Top Sellers (from Backend)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("all_products")
                                .font(.custom("Georgia", size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedTab = .catalog
                            }) {
                                Text("view_all")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.appTextSecondary)
                                    .underline()
                            }
                        }
                        
                        if viewModel.isLoading && viewModel.topSellers.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        ProductCardSkeleton()
                                    }
                                }
                            }
                        } else if let error = viewModel.errorMessage, viewModel.topSellers.isEmpty {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.topSellers) { product in
                                        ProductCardView(
                                            productId: product.id,
                                            category: product.categoryName,
                                            name: product.name,
                                            price: product.formattedPrice,
                                            imageUrl: product.imageUrl,
                                            avgRating: product.avgRating
                                        )
                                        .background(
                                            NavigationLink(destination: ProductDetailView(product: product)) {
                                                Color.black.opacity(0.001)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Divider
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // 4. Explore Collections
                    VStack(alignment: .leading, spacing: 16) {
                        Text("explore_collections")
                            .font(.custom("Georgia", size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        VStack(spacing: 12) {
                            // Top large card
                            Button(action: {
                                categoryToExplore = "Thành phẩm" // Matches DB category
                                selectedTab = .catalog
                            }) {
                                ExploreCollectionCard(
                                    title: "Amigurumi",
                                    subtitle: "Plushies & Toys",
                                    imageUrl: "https://images.unsplash.com/photo-1595341595379-cf1cb694ea1f?q=80&w=2320&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                                )
                                .frame(height: 140)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Bottom two cards
                            HStack(spacing: 12) {
                                Button(action: {
                                    categoryToExplore = "Hoa len " // Matches DB category exactly (with trailing space)
                                    selectedTab = .catalog
                                }) {
                                    ExploreCollectionCard(
                                        title: "Clothing",
                                        subtitle: nil,
                                        imageUrl: "https://images.unsplash.com/photo-1574291814206-363acdf2aa79?q=80&w=400&auto=format&fit=crop"
                                    )
                                    .frame(height: 140)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    categoryToExplore = "Phụ kiện" // Matches DB category
                                    selectedTab = .catalog
                                }) {
                                    ExploreCollectionCard(
                                        title: "Accessories",
                                        subtitle: nil,
                                        imageUrl: "https://images.unsplash.com/photo-1584916201218-f4242ceb4809?q=80&w=400&auto=format&fit=crop"
                                    )
                                    .frame(height: 140)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(Color.appBackground)
            .refreshable {
                viewModel.fetchTopSellers(forceRefresh: true)
            }
            .navigationBarHidden(true)
        }
    }
    
    // Header View Component
    private var headerSection: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut) {
                    showSideMenu = true
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.appText)
            }
            
            Spacer()
            
            Text("handmade_heart")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if viewModel.userName == "Guest" {
                Button(action: {
                    showLogin = true
                }) {
                    Image(systemName: "person.circle")
                        .font(.title2)
                        .foregroundColor(.appText)
                }
            } else {
                Menu {
                    Button(action: {
                        selectedTab = .profile
                    }) {
                        Label("Hello, " + (viewModel.userName ?? "Guest"), systemImage: "person.crop.circle")
                    }
                    
                    if viewModel.userRole.lowercased() == "admin" {
                        Button(action: {
                            // TODO: Navigate to Admin
                        }) {
                            Label("Admin", systemImage: "lock.shield")
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.logout()
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.appPrimary)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
