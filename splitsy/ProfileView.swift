import SwiftUI
struct ProfileView: View {
    @EnvironmentObject var splitHistoryManager: SplitHistoryManager
    @State private var showNewSplit = false
    @State private var showHistory = false

    var body: some View {
        Group {
            if showHistory {
                HistoryView()
                    .environmentObject(splitHistoryManager)
                    .navigationTitle("History")
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarBackButtonHidden(false)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                showHistory = false
                            }
                        }
                    }
            } else {
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
                    Button(action: {
                        showHistory = true
                    }) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("History")
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
            }
        }
        .fullScreenCover(isPresented: $showNewSplit) {
            NewSplitFlowView()
        }
    }
}
