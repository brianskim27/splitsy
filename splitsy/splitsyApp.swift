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
                                // Set up callback to clear data when user signs out
                                authManager.onSignOut = {
                                    splitHistoryManager.clearData()
                                }
                            }
                    }
                    .preferredColorScheme(.light)
                case .needsUsernameSetup:
                    GoogleUsernameSetupView()
                        .environmentObject(authManager)
                case .loading:
                    LoadingView()
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Image("app_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
        }
    }
}
