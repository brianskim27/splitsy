import SwiftUI

struct ListView: View {
    @State private var favoritedStores: [String] = []
    @State private var recentStores: [String] = []

    var body: some View {
        NavigationStack {
            List {
                // ⭐ Favorited Stores Section
                if !favoritedStores.isEmpty {
                    Section(header: Text("Favorited Stores").font(.headline)) {
                        ForEach(favoritedStores, id: \.self) { store in
                            HStack {
                                Text(store)
                                    .font(.body)
                                    .padding(.vertical, 5)
                                Spacer()
                                Button(action: {
                                    removeFavorite(store)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                // 🕰️ Recent Stores Section
                if !recentStores.isEmpty {
                    Section(header: Text("Recent Stores").font(.headline)) {
                        ForEach(recentStores, id: \.self) { store in
                            Text(store)
                                .font(.body)
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    print("Tapped on \(store)")
                                }
                        }
                    }
                }
            }
            .navigationTitle("My Stores")
            .onAppear {
                loadStoredData()
            }
        }
    }

    // 📥 Load Favorited & Recent Stores
    private func loadStoredData() {
        favoritedStores = UserDefaults.standard.stringArray(forKey: "favoritedStores") ?? []
        recentStores = UserDefaults.standard.stringArray(forKey: "recentStores") ?? []
    }

    // ❌ Remove a Store from Favorites
    private func removeFavorite(_ store: String) {
        favoritedStores.removeAll { $0 == store }
        UserDefaults.standard.set(favoritedStores, forKey: "favoritedStores")
    }
}
