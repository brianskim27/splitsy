import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var showNewSplit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Hi, Brian!")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("You've split with 4 people so far this month.")   // Placeholder fun fact
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 0) {
                Text("Recent Splits")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8)

                if splitHistoryManager.pastSplits.isEmpty {
                    Text("No recent splits yet.")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                } else {
                    let splits = Array(splitHistoryManager.pastSplits.prefix(3))
                    ForEach(Array(splits.enumerated()), id: \ .element.id) { (index, split) in
                        RecentSplitRow(split: split)
                        if index < splits.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showNewSplit) {
            NewSplitFlowView()
        }
    }
}

// Store Model with Distance Calculation
struct Store: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    var isFavorited: Bool
}
