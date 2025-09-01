import SwiftUI
import Firebase

@main
struct SplitsyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var splitHistoryManager = SplitHistoryManager()
    @StateObject private var funFactsManager = FunFactsManager()
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.authState {
                case .signedOut:
                    LoginView()
                        .environmentObject(authManager)
                case .signedIn:
                    NavigationStack {
                        MainTabView()
                            .environmentObject(splitHistoryManager)
                            .environmentObject(funFactsManager)
                            .environmentObject(authManager)
                            .onAppear {
                                splitHistoryManager.setAuthManager(authManager)
                            }
                    }
                    .preferredColorScheme(.light)
                case .loading:
                    LoadingView()
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        AnimatedLoadingViewFallback()
    }
}
