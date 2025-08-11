import SwiftUI

@main
struct splitsyApp: App {
    @StateObject private var splitHistoryManager = SplitHistoryManager()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainTabView()
                    .environmentObject(splitHistoryManager)
            }
            .preferredColorScheme(.light)
        }
    }
}
