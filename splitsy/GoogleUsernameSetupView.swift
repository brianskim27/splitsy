import SwiftUI

struct GoogleUsernameSetupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        UsernameSetupView(email: nil, password: nil)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        authManager.cancelIncompleteSignup()
                    }
                    .foregroundColor(.red)
                }
            }
    }
}
