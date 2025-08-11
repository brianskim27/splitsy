import SwiftUI

struct RecentSplitRow: View {
    let split: Split
    @State private var showDetail = false
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(split.description ?? "Split")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(split.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(String(format: "$%.2f", split.totalAmount))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }

            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                Text("Split with \(split.userShares.count) people")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = false
                }
                showDetail = true
            }
        }
        .sheet(isPresented: $showDetail) {
            SplitDetailView(split: split)
        }
    }
}
