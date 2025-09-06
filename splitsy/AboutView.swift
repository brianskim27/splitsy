import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showOpenSourceLicenses = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Header
                    appHeader
                    
                    // App Description
                    appDescription
                    
                    // Features Section
                    featuresSection
                    
                    // Version & Build Info
                    versionSection
                    
                    // Team Section
                    teamSection
                    
                    // Contact & Support
                    contactSection
                    
                    // Legal Section
                    legalSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("About Splitsy")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showOpenSourceLicenses) {
            OpenSourceLicensesView()
        }
    }
    
    // MARK: - App Header
    private var appHeader: some View {
        VStack(spacing: 16) {
            // App Icon
            Image("app_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 4) {
                Text("Splitsy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Because math shouldn't ruin your dinner plans")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - App Description
    private var appDescription: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About Splitsy")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Splitsy is a modern iOS app that eliminates the hassle of manual bill splitting. Simply take a photo of your receipt, and our AI-powered system will automatically parse items and prices, allowing you to assign each item to your party members in seconds.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Features")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "camera.viewfinder",
                    title: "Smart Receipt Scanning",
                    description: "AI-powered OCR extracts items and prices automatically"
                )
                
                FeatureRow(
                    icon: "person.2.fill",
                    title: "Intuitive Bill Splitting",
                    description: "Tap to assign items with real-time calculations"
                )
                
                FeatureRow(
                    icon: "dollarsign.circle.fill",
                    title: "Multi-Currency Support",
                    description: "Convert currencies in real-time with live rates"
                )
                
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Split History & Analytics",
                    description: "Track spending patterns and view detailed statistics"
                )
                
                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Secure & Private",
                    description: "Firebase-powered authentication with data encryption"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Version Section
    private var versionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Version Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Version")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(getAppVersion())
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Build")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(getBuildNumber())
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Platform")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("iOS 17.0+")
                        .fontWeight(.medium)
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Team Section
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Development Team")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                // Developer Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("B")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Brian Kim")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Lead Developer & Designer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact & Support")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ContactRow(
                    icon: "envelope.fill",
                    title: "Email Support",
                    value: "splitsy.contact@gmail.com",
                    action: {
                        if let url = URL(string: "mailto:splitsy.contact@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                
                ContactRow(
                    icon: "star.fill",
                    title: "Rate on App Store",
                    value: "Help us improve",
                    action: {
                        // TODO: Add App Store rating URL when available
                    }
                )
                
                ContactRow(
                    icon: "heart.fill",
                    title: "Made with ❤️",
                    value: "For easier bill splitting",
                    action: nil
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Legal")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Privacy Policy")
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showPrivacyPolicy = true
                }
                
                HStack {
                    Text("Terms of Service")
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showTermsOfService = true
                }
                
                HStack {
                    Text("Open Source Licenses")
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showOpenSourceLicenses = true
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0"
    }
    
    private func getBuildNumber() -> String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "1"
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Contact Row Component
struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    let action: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

// MARK: - Preview
#Preview {
    AboutView()
}
