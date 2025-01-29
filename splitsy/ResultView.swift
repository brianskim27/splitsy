import SwiftUI

struct ResultView: View {
    let userShares: [String: Double]
    let detailedBreakdown: [String: [(item: String, cost: Double)]] // Detailed breakdown for each user

    @Environment(\.dismiss) var dismiss // Dismiss action for navigation
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(userShares.keys.sorted(), id: \.self) { user in
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(user)
                                .font(.headline)
                                .padding(.bottom, 5)

                            if let items = detailedBreakdown[user] {
                                ForEach(items, id: \.item) { itemDetail in
                                    HStack {
                                        Text(itemDetail.item)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("$\(itemDetail.cost, specifier: "%.2f")")
                                            .foregroundColor(.green)
                                    }
                                }
                            }

                            Divider()
                                .padding(.vertical, 5)

                            HStack {
                                Text("Total")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("$\(userShares[user] ?? 0.0, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // Go back
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Breakdown")
                    .font(.headline)
                    .bold()
            }
        }
    }
}
