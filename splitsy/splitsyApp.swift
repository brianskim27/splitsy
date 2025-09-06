import SwiftUI
import Firebase

@main
struct SplitsyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var splitHistoryManager = SplitHistoryManager()
    @StateObject private var funFactsManager = FunFactsManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var currencyManager = CurrencyManager()
    
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
                            .environmentObject(currencyManager)
                            .onAppear {
                                splitHistoryManager.setAuthManager(authManager)
                                // Set up callback to clear data when user signs out
                                authManager.onSignOut = {
                                    splitHistoryManager.clearData()
                                }
                                // Load user's preferred currency
                                if let user = authManager.currentUser,
                                   let currency = Currency.supportedCurrencies.first(where: { $0.code == user.preferredCurrency }) {
                                    currencyManager.setCurrency(currency)
                                }
                                // Set current user in FunFactsManager
                                if let userName = authManager.currentUser?.name {
                                    funFactsManager.setCurrentUser(userName)
                                }
                            }
                    }
                    .preferredColorScheme(.light)
                case .needsEmailVerification:
                    if let userEmail = authManager.currentUser?.email {
                        EmailVerificationView(userEmail: userEmail)
                            .environmentObject(authManager)
                    } else {
                        LoginView()
                            .environmentObject(authManager)
                    }
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
