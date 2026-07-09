import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    @State private var showLogin = false
    
    // Image Picker State
    enum ImagePickerType: Identifiable {
        case camera
        case photoLibrary
        var id: Int { hashValue }
    }
    @State private var activePicker: ImagePickerType?
    @State private var selectedImage: UIImage?
    @State private var showingFullImage = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Custom Navigation Bar
                    HStack {
                        Button(action: {
                            // Menu action
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(.appText)
                        }
                        
                        Spacer()
                        
                        Text("Handmade with Heart")
                            .font(.custom("Georgia", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            // Cart action
                        }) {
                            Image(systemName: "bag")
                                .font(.title2)
                                .foregroundColor(.appText)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    if viewModel.isLoading && viewModel.user == nil {
                        ProgressView("Loading Profile...")
                            .padding(.top, 40)
                    } else if let error = viewModel.errorMessage, viewModel.user == nil {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.top, 40)
                    } else {
                        profileContent
                    }
                }
            }
            
            if showingLogoutAlert {
                CustomAlertView(
                    message: "logout_confirm",
                    primaryAction: {
                        withAnimation {
                            showingLogoutAlert = false
                        }
                        viewModel.logout()
                        showLogin = true
                    },
                    secondaryAction: {
                        withAnimation {
                            showingLogoutAlert = false
                        }
                    }
                )
                .transition(.scale(scale: 1.1).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchProfile()
        }
        .sheet(isPresented: $showLogin, onDismiss: {
            viewModel.fetchProfile()
        }) {
            LoginView()
        }
        .fullScreenCover(item: $activePicker) { pickerType in
            ImagePicker(
                selectedImage: $selectedImage,
                sourceType: pickerType == .camera ? .camera : .photoLibrary
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingFullImage) {
            FullScreenImageView(
                selectedImage: selectedImage,
                avatarUrl: viewModel.user?.avatarUrl
            )
        }
    }
    
    private var profileContent: some View {
        VStack(spacing: 24) {
            // Avatar & Name Section
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.appPrimary.opacity(0.5), lineWidth: 4)
                        .frame(width: 108, height: 108)
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else if let avatarUrl = viewModel.user?.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                }
                .contextMenu {
                    Button(action: {
                        showingFullImage = true
                    }) {
                        Label("View Image", systemImage: "photo")
                    }
                    Button(role: .destructive, action: {
                        selectedImage = nil
                    }) {
                        Label("Delete Avatar", systemImage: "trash")
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    // Edit Pencil Button
                    Menu {
                        Button(action: {
                            activePicker = .camera
                        }) {
                            Label("Camera", systemImage: "camera")
                        }
                        Button(action: {
                            activePicker = .photoLibrary
                        }) {
                            Label("Photo Library", systemImage: "photo.on.rectangle")
                        }
                    } label: {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .offset(x: 4, y: 4)
                }
                
                VStack(spacing: 4) {
                    Text(viewModel.user?.name ?? "Unknown User")
                        .font(.custom("Georgia", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Text(viewModel.user?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.top, 16)
            
            // Statistics Section
            HStack(spacing: 16) {
                StatCard(value: "\(viewModel.user?.totalOrders ?? 12)", title: "Orders")
                StatCard(value: "\(viewModel.user?.totalReviews ?? 8)", title: "Reviews")
                StatCard(value: "\(viewModel.user?.totalPoints ?? 450)", title: "Points")
            }
            .padding(.horizontal)
            
            // My Orders Section
            VStack(spacing: 20) {
                HStack {
                    Text("My Orders")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    Button(action: {
                        // View all action
                    }) {
                        HStack(spacing: 4) {
                            Text("View All")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.appTextSecondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                
                HStack {
                    OrderActionIcon(icon: "wallet.pass", title: "To Pay")
                    Spacer()
                    OrderActionIcon(icon: "shippingbox", title: "To Ship")
                    Spacer()
                    OrderActionIcon(icon: "cube.box", title: "To Receive")
                    Spacer()
                    OrderActionIcon(icon: "text.bubble", title: "To Review")
                }
            }
            .padding(20)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Settings List
            VStack(spacing: 0) {
                MenuRow(icon: "person.crop.circle", title: "Edit Profile")
                Divider()
                MenuRow(icon: "mappin.and.ellipse", title: "Shipping Address")
                Divider()
                MenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Logout", isDestructive: true) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                        showingLogoutAlert = true
                    }
                }
            }
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Subcomponents

struct StatCard: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.custom("Georgia", size: 22))
                .fontWeight(.bold)
                .foregroundColor(.appText)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct FullScreenImageView: View {
    @Environment(\.dismiss) var dismiss
    let selectedImage: UIImage?
    let avatarUrl: String?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if let urlString = avatarUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}


struct OrderActionIcon: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            // Action
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(.appText)
                    )
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDestructive ? .red : .appText)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDestructive ? .red : .appText)
                
                Spacer()
                
                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
