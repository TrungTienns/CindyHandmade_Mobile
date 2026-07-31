import SwiftUI

struct PointsView: View {
    @Environment(\.presentationMode) var presentationMode
    let totalPoints: Int
    
    let pointsHistory: [PointEntry]
    
    // Tier thresholds
    private var tier: (nameKey: String, icon: String, colors: [Color], nextThreshold: Int) {
        switch totalPoints {
        case 0..<1000:   
            // Bronze: 0 - 999
            return ("tier_bronze",   "medal.fill", [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.3, blue: 0.1)], 1000)
        case 1000..<5000: 
            // Silver: 1000 - 4999
            return ("tier_silver",   "medal.fill", [Color(red: 0.85, green: 0.85, blue: 0.85), Color(red: 0.6, green: 0.6, blue: 0.6)], 5000)
        default:         
            // Diamond: 5000+
            return ("tier_diamond",  "diamond.fill", [Color(red: 0.4, green: 0.8, blue: 0.9), Color(red: 0.2, green: 0.5, blue: 0.8)], Int.max)
        }
    }
    
    private var progressToNext: Double {
        let t = tier
        if t.nextThreshold == Int.max { return 1.0 }
        let prevThreshold: Int
        switch t.nameKey {
        case "tier_silver":   prevThreshold = 1000
        default:              prevThreshold = 0
        }
        let range = Double(t.nextThreshold - prevThreshold)
        let current = Double(totalPoints - prevThreshold)
        return min(max(current / range, 0), 1.0)
    }
    
    // Function to localize string with arguments
    private func localizedString(_ key: String, _ args: CVarArg...) -> String {
        return String(format: NSLocalizedString(key, comment: ""), arguments: args)
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
                                gradient: Gradient(colors: tier.colors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            VStack(spacing: 12) {
                                Image(systemName: tier.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                
                                Text("\(totalPoints)")
                                    .font(.system(size: 52, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                
                                Text(LocalizedStringKey("points_accumulated"))
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                // Tier Badge
                                Text(localizedString("points_tier_level", NSLocalizedString(tier.nameKey, comment: "")))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(tier.colors.last ?? .appPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                
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
                                        
                                        Text(localizedString("points_needed_next_tier", tier.nextThreshold - totalPoints))
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding(.top, 8)
                                } else {
                                    Text(LocalizedStringKey("points_highest_tier"))
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding(.top, 8)
                                }
                            }
                            .padding(28)
                        }
                        .padding(.horizontal)
                        
                        // How to earn points
                        VStack(alignment: .leading, spacing: 12) {
                            Text(LocalizedStringKey("points_how_to_earn"))
                                .font(.headline)
                                .foregroundColor(.appText)
                                .padding(.horizontal)
                            
                            HStack(spacing: 0) {
                                earnMethodCard(icon: "cart.fill",          title: NSLocalizedString("points_buy", comment: ""),      desc: NSLocalizedString("points_10_per_product", comment: ""), color: .appPrimary)
                                Divider()
                                earnMethodCard(icon: "star.fill",          title: NSLocalizedString("points_review", comment: ""),      desc: NSLocalizedString("points_plus_20", comment: ""),       color: .yellow)
                                Divider()
                                earnMethodCard(icon: "person.badge.plus",  title: NSLocalizedString("points_referral", comment: ""),    desc: NSLocalizedString("points_plus_100", comment: ""),      color: .blue)
                            }
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // History
                        VStack(alignment: .leading, spacing: 12) {
                            Text(LocalizedStringKey("points_history"))
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
