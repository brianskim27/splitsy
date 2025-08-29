import SwiftUI
import Firebase

@main
struct splitsyApp: App {
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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Splitsy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 20)
                
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
