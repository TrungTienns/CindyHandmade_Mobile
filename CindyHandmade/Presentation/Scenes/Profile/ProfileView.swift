import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    @State private var showLogin = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
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
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchProfile()
        }
            .sheet(isPresented: $showLogin, onDismiss: {
                viewModel.fetchProfile()
            }) {
                LoginView()
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
            }
        }
    }
    
    private var profileContent: some View {
        VStack(spacing: 20) {
            // Header Card
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    let nameInitial = viewModel.user?.name.first.map { String($0) } ?? "U"
                    Circle()
                        .fill(Color.appPrimary.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(nameInitial.uppercased())
                                .font(.custom("Georgia", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(.appPrimary)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.user?.name ?? "Unknown User")
                            .font(.custom("Georgia", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        Text(viewModel.user?.role.capitalized ?? "User")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        Text("Vietnam") // Placeholder for location
                            .font(.footnote)
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Personal Information Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Personal Information")
                    .font(.custom("Georgia", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text(viewModel.user?.name ?? "N/A")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Role")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text(viewModel.user?.role.capitalized ?? "N/A")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                    }
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text(viewModel.user?.email ?? "N/A")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Phone")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text("Not provided")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Address Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Address")
                    .font(.custom("Georgia", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Country")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text("Vietnam") // Placeholder
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("City / Province")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text("Not provided") // Placeholder
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

            // Order History (Basic placeholder)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Order History")
                        .font(.custom("Georgia", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

            Spacer(minLength: 20)
            
            // Logout Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                    showingLogoutAlert = true
                }
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
