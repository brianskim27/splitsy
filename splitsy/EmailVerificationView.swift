import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCheckingVerification = false
    @State private var verificationMessage = ""
    @State private var showResendConfirmation = false
    @State private var resendCooldown = 0
    @State private var timer: Timer?
    
    let userEmail: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Email icon
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    Text("Verify Your Email")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("We've sent a verification link to")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(userEmail)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text("Please check your email and click the")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("verification link to activate your account.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    Text("Don't see the email? Check your spam folder.")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 16) {
                    // Check verification button
                    Button(action: checkVerificationStatus) {
                        HStack {
                            if isCheckingVerification {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle")
                            }
                            Text(isCheckingVerification ? "Checking..." : "I've Verified My Email")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isCheckingVerification)
                    
                    // Resend verification button
                    Button(action: resendVerification) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(resendCooldown > 0 ? "Resend in \(resendCooldown)s" : "Resend Verification Email")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(resendCooldown > 0 ? Color.gray : Color.secondary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(resendCooldown > 0)
                }
                .padding(.horizontal)
                
                if !verificationMessage.isEmpty {
                    Text(verificationMessage)
                        .font(.caption)
                        .foregroundColor(verificationMessage.contains("✅") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Help text
                VStack(spacing: 8) {
                    Text("Need help?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Contact Support") {
                        if let url = URL(string: "mailto:splitsy.contact@gmail.com?subject=Email Verification Help") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Email Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        goBackToSignup()
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                startResendCooldown()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .alert("Verification Email Sent", isPresented: $showResendConfirmation) {
                Button("OK") { }
            } message: {
                Text("A new verification email has been sent to \(userEmail)")
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func checkVerificationStatus() {
        isCheckingVerification = true
        verificationMessage = ""
        
        Task {
            let isVerified = await authManager.checkEmailVerificationStatus()
            
            await MainActor.run {
                isCheckingVerification = false
                
                if isVerified {
                    verificationMessage = "✅ Email verified successfully!"
                    // Move to username setup or complete authentication
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if authManager.currentUser?.username.isEmpty == true {
                            authManager.authState = .needsUsernameSetup
                        } else {
                            authManager.authState = .signedIn
                        }
                    }
                } else {
                    verificationMessage = "❌ Email not yet verified. Please check your email and click the verification link."
                }
            }
        }
    }
    
    private func resendVerification() {
        Task {
            await authManager.resendEmailVerification()
            
            await MainActor.run {
                showResendConfirmation = true
                startResendCooldown()
            }
        }
    }
    
    private func startResendCooldown() {
        resendCooldown = 60 // 60 seconds cooldown
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if resendCooldown > 0 {
                resendCooldown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func goBackToSignup() {
        authManager.signOut()
    }
}

#Preview {
    EmailVerificationView(userEmail: "user@example.com")
        .environmentObject(AuthenticationManager())
}
