import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // 1. Header
                    headerSection
                    
                    // 2. Greeting & Hero Banner
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back, Sarah.")
                                .font(.custom("Georgia", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                            
                            Text("Find your next cozy companion.")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        HeroBannerView()
                    }
                    
                    // Divider
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // 3. Top Sellers (from Backend)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Top Sellers")
                                .font(.custom("Georgia", size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                            
                            Spacer()
                            
                            Button("View all") {
                                viewModel.fetchTopSellers() // Refresh
                            }
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.appTextSecondary)
                            .underline()
                        }
                        
                        if viewModel.isLoading && viewModel.topSellers.isEmpty {
                            ProgressView("Đang tải dữ liệu...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
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
                                            category: product.categoryName,
                                            name: product.name,
                                            price: product.formattedPrice,
                                            imageUrl: product.imageUrl
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
                        Text("Explore Collections")
                            .font(.custom("Georgia", size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        VStack(spacing: 12) {
                            // Top large card
                            ExploreCollectionCard(
                                title: "Amigurumi",
                                subtitle: "Plushies & Toys",
                                imageUrl: "https://images.unsplash.com/photo-1596766440742-996fffd0e261?q=80&w=800&auto=format&fit=crop"
                            )
                            .frame(height: 140)
                            
                            // Bottom two cards
                            HStack(spacing: 12) {
                                ExploreCollectionCard(
                                    title: "Clothing",
                                    subtitle: nil,
                                    imageUrl: "https://images.unsplash.com/photo-1574291814206-363acdf2aa79?q=80&w=400&auto=format&fit=crop"
                                )
                                .frame(height: 140)
                                
                                ExploreCollectionCard(
                                    title: "Accessories",
                                    subtitle: nil,
                                    imageUrl: "https://images.unsplash.com/photo-1584916201218-f4242ceb4809?q=80&w=400&auto=format&fit=crop"
                                )
                                .frame(height: 140)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(Color.appBackground)
            .refreshable {
                viewModel.fetchTopSellers()
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, cartBadgeCount: 1)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            viewModel.fetchTopSellers()
        }
    }
    
    // Header View Component
    private var headerSection: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.appText)
            }
            
            Spacer()
            
            Text("Handmade with\nHeart")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bag")
                    .font(.title2)
                    .foregroundColor(.appText)
            }
        }
    }
}

#Preview {
    HomeView()
}
