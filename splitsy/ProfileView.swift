import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var searchText = ""

    var filteredSplits: [Split] {
        if searchText.isEmpty {
            return splitHistoryManager.pastSplits
        } else {
            return splitHistoryManager.pastSplits.filter { split in
                (split.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                split.userShares.keys.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
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
                List(filteredSplits) { split in
                    RecentSplitRow(split: split)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("History")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by person or name")
    }
}


struct ProfileView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var showNewSplit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("Brian")
                        .font(.title)
                        .bold()
                    Text("View Account & Settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)

            // Link to full history
            NavigationLink {
                HistoryView()
            } label: {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Split History")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showNewSplit) {
            NewSplitFlowView()
        }
    }
}
