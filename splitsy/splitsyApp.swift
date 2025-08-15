import SwiftUI
import Firebase

@main
struct splitsyApp: App {
    init() {
        FirebaseApp.configure()
    }
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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
