import SwiftUI

struct PointsView: View {
    @Environment(\.presentationMode) var presentationMode
    let totalPoints: Int
    
    // Simulated points history derived from user interactions.
    // In a full implementation, this would come from a dedicated API endpoint.
    private let pointsHistory: [PointEntry] = [
        PointEntry(id: 1, icon: "cart.fill",      title: "Hoàn thành đơn hàng #1042", points: +100, date: "15/07/2025", isEarned: true),
        PointEntry(id: 2, icon: "cart.fill",      title: "Hoàn thành đơn hàng #1038", points: +80,  date: "10/07/2025", isEarned: true),
        PointEntry(id: 3, icon: "star.fill",      title: "Đánh giá sản phẩm",         points: +20,  date: "11/07/2025", isEarned: true),
        PointEntry(id: 4, icon: "gift.fill",      title: "Thưởng chào mừng",          points: +50,  date: "01/07/2025", isEarned: true),
        PointEntry(id: 5, icon: "cart.fill",      title: "Hoàn thành đơn hàng #1025", points: +120, date: "20/06/2025", isEarned: true),
        PointEntry(id: 6, icon: "arrow.down.circle.fill", title: "Dùng điểm giảm giá", points: -200, date: "25/06/2025", isEarned: false),
        PointEntry(id: 7, icon: "star.fill",      title: "Đánh giá sản phẩm",         points: +20,  date: "21/06/2025", isEarned: true),
        PointEntry(id: 8, icon: "person.badge.plus.fill", title: "Giới thiệu bạn bè", points: +100, date: "15/06/2025", isEarned: true),
    ]
    
    // Tier thresholds
    private var tier: (name: String, icon: String, color: Color, nextThreshold: Int) {
        switch totalPoints {
        case 0..<200:   return ("Thành viên",   "person.fill",         .gray,       200)
        case 200..<500: return ("Bạc",          "medal.fill",          .gray,       500)
        case 500..<1000: return ("Vàng",        "trophy.fill",         .yellow,     1000)
        default:         return ("Kim cương",   "diamond.fill",        .blue,       Int.max)
        }
    }
    
    private var progressToNext: Double {
        let t = tier
        if t.nextThreshold == Int.max { return 1.0 }
        let prevThreshold: Int
        switch t.name {
        case "Bạc":    prevThreshold = 200
        case "Vàng":   prevThreshold = 500
        default:       prevThreshold = 0
        }
        let range = Double(t.nextThreshold - prevThreshold)
        let current = Double(totalPoints - prevThreshold)
        return min(max(current / range, 0), 1.0)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.appText)
                            .padding(12)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 3)
                    }
                    Spacer()
                    Text(LocalizedStringKey("points"))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Hero Points Card
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.appPrimary, Color.appPrimary.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            VStack(spacing: 12) {
                                Image(systemName: tier.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("\(totalPoints)")
                                    .font(.system(size: 52, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("điểm tích lũy")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                // Tier Badge
                                Text("Hạng \(tier.name)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                
                                // Progress Bar to next tier
                                if tier.nextThreshold != Int.max {
                                    VStack(spacing: 4) {
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.white.opacity(0.3))
                                                    .frame(height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.white)
                                                    .frame(width: geo.size.width * progressToNext, height: 8)
                                                    .animation(.easeInOut(duration: 0.8), value: progressToNext)
                                            }
                                        }
                                        .frame(height: 8)
                                        
                                        Text("Cần thêm \(tier.nextThreshold - totalPoints) điểm để lên hạng tiếp theo")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.top, 4)
                                } else {
                                    Text("🎉 Bạn đã đạt hạng cao nhất!")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(28)
                        }
                        .padding(.horizontal)
                        
                        // How to earn points
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cách kiếm điểm")
                                .font(.headline)
                                .foregroundColor(.appText)
                                .padding(.horizontal)
                            
                            HStack(spacing: 0) {
                                earnMethodCard(icon: "cart.fill",          title: "Mua hàng",      desc: "1 điểm/1.000₫", color: .appPrimary)
                                Divider()
                                earnMethodCard(icon: "star.fill",          title: "Đánh giá",      desc: "+20 điểm",       color: .yellow)
                                Divider()
                                earnMethodCard(icon: "person.badge.plus",  title: "Giới thiệu",    desc: "+100 điểm",      color: .blue)
                            }
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // History
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lịch sử điểm")
                                .font(.headline)
                                .foregroundColor(.appText)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(pointsHistory) { entry in
                                    PointHistoryRow(entry: entry)
                                    if entry.id != pointsHistory.last?.id {
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 24)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func earnMethodCard(icon: String, title: String, desc: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.appText)
            Text(desc)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Point Entry Model
struct PointEntry: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let points: Int
    let date: String
    let isEarned: Bool
}

struct PointHistoryRow: View {
    let entry: PointEntry
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon Circle
            Image(systemName: entry.icon)
                .font(.system(size: 18))
                .foregroundColor(entry.isEarned ? .appPrimary : .red)
                .frame(width: 44, height: 44)
                .background((entry.isEarned ? Color.appPrimary : Color.red).opacity(0.1))
                .clipShape(Circle())
            
            // Title + Date
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appText)
                Text(entry.date)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Points Delta
            Text(entry.isEarned ? "+\(entry.points)" : "\(entry.points)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(entry.isEarned ? .appPrimary : .red)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
