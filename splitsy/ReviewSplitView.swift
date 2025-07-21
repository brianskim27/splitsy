import SwiftUI

struct ReviewSplitView: View {
    let userShares: [String: Double]
    let detailedBreakdown: [String: [ItemDetail]]
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Review")
                .font(.title2)
                .bold()
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(userShares.keys.sorted(), id: \.self) { user in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.7))
                                    .frame(width: 32, height: 32)
                                    .overlay(Text(userInitials(user)).foregroundColor(.white).font(.headline))
                                Text(user)
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                Text("$\(userShares[user] ?? 0.0, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            if let items = detailedBreakdown[user] {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(items, id: \.self) { itemDetail in
                                        HStack {
                                            Text(itemDetail.item)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(itemDetail.cost, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .padding(.leading, 44)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
            Button(action: onConfirm) {
                HStack {
                    Spacer()
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.white)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(14)
                .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 12)
    }

    // Helper for initials
    private func userInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count == 1, let first = parts.first?.first {
            return String(first).uppercased()
        } else if let first = parts.first?.first, let last = parts.last?.first {
            return String(first).uppercased() + String(last).uppercased()
        } else {
            return "?"
        }
    }
}
