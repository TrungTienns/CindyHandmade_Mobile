import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.appText)
                            .padding(12)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 3)
                    }
                    
                    Spacer()
                    
                    Text(LocalizedStringKey("notifications"))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    // Mark all as read
                    if !notificationManager.notifications.isEmpty {
                        Button(action: {
                            withAnimation {
                                notificationManager.markAllAsRead()
                            }
                        }) {
                            Text(LocalizedStringKey("mark_all_read"))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.appPrimary)
                        }
                        .frame(width: 70)
                    } else {
                        Color.clear.frame(width: 70, height: 44)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                if notificationManager.notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Notification List
    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notificationManager.notifications) { notification in
                    NotificationRow(notification: notification)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                notificationManager.markAsRead(notification)
                            }
                        }
                    
                    Divider()
                        .padding(.leading, 70)
                }
            }
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .padding()
            
            // Clear all button
            Button(action: {
                withAnimation {
                    notificationManager.clearAll()
                }
            }) {
                Text(LocalizedStringKey("clear_all_notifications"))
                    .font(.footnote)
                    .foregroundColor(.red.opacity(0.7))
            }
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.appCardBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bell.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.appTextSecondary.opacity(0.5))
            }
            
            Text(LocalizedStringKey("no_notifications"))
                .font(.headline)
                .foregroundColor(.appText)
            
            Text(LocalizedStringKey("no_notifications_desc"))
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: AppNotification
    
    private var accentColor: Color {
        Color(UIColor(hex: notification.type.accentColorHex) ?? .systemGreen)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 46, height: 46)
                
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(notification.isRead ? .regular : .semibold)
                    .foregroundColor(.appText)
                    .lineLimit(1)
                
                Text(notification.body)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
                
                Text(notification.relativeDate)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary.opacity(0.7))
            }
            
            Spacer()
            
            // Unread dot
            if !notification.isRead {
                Circle()
                    .fill(Color.appPrimary)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(notification.isRead ? Color.clear : Color.appPrimary.opacity(0.04))
        .animation(.easeInOut, value: notification.isRead)
    }
}
