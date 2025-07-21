import SwiftUI

struct RecentSplitRow: View {
    let split: Split
    @State private var showDetail = false

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
                Text("$\(split.totalAmount, specifier: "%.2f")")
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
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            SplitDetailView(split: split)
        }
        .padding(.vertical, 4)
    }
}
