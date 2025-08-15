import SwiftUI

@main
struct splitsyApp: App {
    @StateObject private var splitHistoryManager = SplitHistoryManager()
    @StateObject private var funFactsManager = FunFactsManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainTabView()
                    .environmentObject(splitHistoryManager)
                    .environmentObject(funFactsManager)
            }
            .preferredColorScheme(.light)
        }
    }
}
