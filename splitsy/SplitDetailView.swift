import SwiftUI

struct SplitDetailView: View {
    @Environment(\.dismiss) var dismiss
    let split: Split
    @State private var showFullScreen = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Receipt Image
                    if let imageData = split.receiptImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                            .padding(.horizontal, 24)
                            .onTapGesture { showFullScreen = true }
                            .sheet(isPresented: $showFullScreen) {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    VStack {
                                        Spacer()
                                        ZoomableImageView(image: uiImage)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        Spacer()
                                        Button("Close") { showFullScreen = false }
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                            }
                    }
                    
                    // Header Info
                    VStack(spacing: 8) {
                        Text(split.description ?? "Split Details")
                            .font(.largeTitle)
                            .bold()
                        Text(split.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Total: $\(split.totalAmount, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)

                    // User Breakdowns
                    ForEach(split.userShares.keys.sorted(), id: \.self) { user in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(user)
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                Text("$\(split.userShares[user] ?? 0, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }

                            if let items = split.detailedBreakdown[user] {
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
                                    .padding(.leading)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Split Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
