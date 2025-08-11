import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var searchText = ""
    
    private var filteredSplits: [Split] {
        if searchText.isEmpty {
            return splitHistoryManager.pastSplits
        } else {
            let searchLower = searchText.lowercased()
            return splitHistoryManager.pastSplits.filter { split in
                (split.description?.lowercased().contains(searchLower) ?? false) ||
                split.userShares.keys.contains { $0.lowercased().contains(searchLower) }
            }
        }
    }

    var body: some View {
        VStack {
            if filteredSplits.isEmpty {
                VStack {
                    Spacer()
                    Text("No splits recorded yet.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredSplits.enumerated()), id: \.element.id) { (index, split) in
                            RecentSplitRow(split: split)
                            if index < filteredSplits.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by person or name")
    }
}
