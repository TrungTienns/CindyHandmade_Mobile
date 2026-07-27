import SwiftUI

struct ReviewsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MyReviewsViewModel()
    
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
                    
                    Text(LocalizedStringKey("reviews"))
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.myReviews.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Summary Card
                            HStack(spacing: 16) {
                                reviewSummaryStat(
                                    icon: "star.fill",
                                    value: "\(viewModel.myReviews.count)",
                                    label: "Đã đánh giá",
                                    color: .yellow
                                )
                            }
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                            // Submitted Reviews List
                            ForEach(viewModel.myReviews) { review in
                                MyReviewCard(review: review)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchMyReviews()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "star.bubble")
                .font(.system(size: 64))
                .foregroundColor(.appTextSecondary.opacity(0.4))
            Text("Chưa có đánh giá nào")
                .font(.headline)
                .foregroundColor(.appText)
            Text("Hãy hoàn thành đơn hàng và để lại đánh giá nhé!")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
    
    private func reviewSummaryStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.appText)
            Text(label)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MyReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Product Row
            HStack(spacing: 12) {
                // Product Thumbnail
                Group {
                    if let urlStr = review.productImageUrl, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.15)
                        }
                    } else {
                        Color.gray.opacity(0.15)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray.opacity(0.5)))
                    }
                }
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(review.productName ?? "Sản phẩm")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appText)
                        .lineLimit(1)
                    
                    Text(review.displayDate)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                Label("Đã gửi", systemImage: "checkmark.circle.fill")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appPrimary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding()
            
            Divider().padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                // Star Rating (Read-only)
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 13))
                            .foregroundColor(star <= review.rating ? .yellow : .gray.opacity(0.3))
                    }
                    Text("(\(review.rating)/5)")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
                
                if let comment = review.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.subheadline)
                        .foregroundColor(.appText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
    }
}
