import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Acceptance of Terms
                    acceptanceSection
                    
                    // Description of Service
                    serviceDescriptionSection
                    
                    // User Accounts
                    userAccountsSection
                    
                    // Acceptable Use
                    acceptableUseSection
                    
                    // Intellectual Property
                    intellectualPropertySection
                    
                    // Privacy and Data
                    privacyDataSection
                    
                    // Disclaimers
                    disclaimersSection
                    
                    // Limitation of Liability
                    liabilitySection
                    
                    // Termination
                    terminationSection
                    
                    // Changes to Terms
                    changesSection
                    
                    // Governing Law
                    governingLawSection
                    
                    // Contact Information
                    contactSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Terms of Service")
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
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last updated: \(getCurrentDate())")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("These Terms of Service govern your use of Splitsy, our bill-splitting mobile application. Please read these terms carefully before using our service.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Acceptance Section
    private var acceptanceSection: some View {
        LegalSection(title: "Acceptance of Terms") {
            VStack(alignment: .leading, spacing: 12) {
                Text("By downloading, installing, or using Splitsy, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree to these terms, please do not use our service.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("These terms constitute a legally binding agreement between you and Splitsy.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Service Description Section
    private var serviceDescriptionSection: some View {
        LegalSection(title: "Description of Service") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Splitsy is a mobile application that helps users split bills and expenses among multiple people. Our service includes:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    ServiceFeature(
                        title: "Receipt Scanning",
                        description: "AI-powered text recognition to extract items and prices from receipt images"
                    )
                    
                    ServiceFeature(
                        title: "Bill Splitting",
                        description: "Tools to assign items to different people and calculate individual shares"
                    )
                    
                    ServiceFeature(
                        title: "Multi-Currency Support",
                        description: "Real-time currency conversion for international users"
                    )
                    
                    ServiceFeature(
                        title: "Split History",
                        description: "Storage and management of past bill splits for reference"
                    )
                }
            }
        }
    }
    
    // MARK: - User Accounts Section
    private var userAccountsSection: some View {
        LegalSection(title: "User Accounts") {
            VStack(alignment: .leading, spacing: 12) {
                Text("To use certain features of Splitsy, you may need to create an account. When creating an account, you agree to:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    AccountRequirement(
                        title: "Accurate Information",
                        description: "Provide accurate, current, and complete information"
                    )
                    
                    AccountRequirement(
                        title: "Account Security",
                        description: "Maintain the security of your account credentials"
                    )
                    
                    AccountRequirement(
                        title: "Account Responsibility",
                        description: "Accept responsibility for all activities under your account"
                    )
                    
                    AccountRequirement(
                        title: "Notification of Breach",
                        description: "Notify us immediately of any unauthorized use of your account"
                    )
                }
            }
        }
    }
    
    // MARK: - Acceptable Use Section
    private var acceptableUseSection: some View {
        LegalSection(title: "Acceptable Use") {
            VStack(alignment: .leading, spacing: 12) {
                Text("You agree to use Splitsy only for lawful purposes and in accordance with these terms. You agree not to:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    ProhibitedActivity(
                        activity: "Upload malicious content or attempt to harm the service"
                    )
                    
                    ProhibitedActivity(
                        activity: "Use the service for any illegal or unauthorized purpose"
                    )
                    
                    ProhibitedActivity(
                        activity: "Attempt to gain unauthorized access to our systems"
                    )
                    
                    ProhibitedActivity(
                        activity: "Interfere with or disrupt the service or servers"
                    )
                    
                    ProhibitedActivity(
                        activity: "Upload content that infringes on intellectual property rights"
                    )
                    
                    ProhibitedActivity(
                        activity: "Use automated systems to access the service without permission"
                    )
                }
            }
        }
    }
    
    // MARK: - Intellectual Property Section
    private var intellectualPropertySection: some View {
        LegalSection(title: "Intellectual Property") {
            VStack(alignment: .leading, spacing: 12) {
                Text("The Splitsy application, including its design, functionality, and content, is protected by intellectual property laws. You may not:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    IPRestriction(
                        restriction: "Copy, modify, or distribute the application"
                    )
                    
                    IPRestriction(
                        restriction: "Reverse engineer or attempt to extract source code"
                    )
                    
                    IPRestriction(
                        restriction: "Use our trademarks or branding without permission"
                    )
                    
                    IPRestriction(
                        restriction: "Create derivative works based on our service"
                    )
                }
                
                Text("You retain ownership of any content you upload to Splitsy, but grant us a license to use it for providing our service.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Privacy and Data Section
    private var privacyDataSection: some View {
        LegalSection(title: "Privacy and Data") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your privacy is important to us. Our collection and use of your information is governed by our Privacy Policy, which is incorporated into these terms by reference.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("By using Splitsy, you consent to the collection and use of your information as described in our Privacy Policy.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Disclaimers Section
    private var disclaimersSection: some View {
        LegalSection(title: "Disclaimers") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Splitsy is provided \"as is\" and \"as available\" without warranties of any kind. We disclaim all warranties, express or implied, including but not limited to:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Disclaimer(
                        item: "Warranties of merchantability and fitness for a particular purpose"
                    )
                    
                    Disclaimer(
                        item: "Warranties regarding the accuracy or reliability of receipt scanning"
                    )
                    
                    Disclaimer(
                        item: "Warranties that the service will be uninterrupted or error-free"
                    )
                    
                    Disclaimer(
                        item: "Warranties regarding third-party services or integrations"
                    )
                }
            }
        }
    }
    
    // MARK: - Limitation of Liability Section
    private var liabilitySection: some View {
        LegalSection(title: "Limitation of Liability") {
            VStack(alignment: .leading, spacing: 12) {
                Text("To the maximum extent permitted by law, Splitsy shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    LiabilityExclusion(
                        item: "Loss of profits, data, or business opportunities"
                    )
                    
                    LiabilityExclusion(
                        item: "Damages resulting from receipt scanning errors"
                    )
                    
                    LiabilityExclusion(
                        item: "Damages from service interruptions or downtime"
                    )
                    
                    LiabilityExclusion(
                        item: "Damages from third-party actions or content"
                    )
                }
                
                Text("Our total liability to you for any claims arising from these terms or your use of the service shall not exceed the amount you paid us in the 12 months preceding the claim.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Termination Section
    private var terminationSection: some View {
        LegalSection(title: "Termination and Account Deletion") {
            VStack(alignment: .leading, spacing: 12) {
                Text("We may terminate or suspend your account and access to the service immediately, without prior notice, for any reason, including if you breach these terms.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Deletion Rights")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("You have the right to delete your account at any time. You can do this by:")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.accentColor)
                                .fontWeight(.bold)
                            
                            Text("Using the account deletion feature in the app settings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.accentColor)
                                .fontWeight(.bold)
                            
                            Text("Contacting us directly at splitsy.contact@gmail.com")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                    }
                }
                
                Text("Upon account deletion, all your personal data, receipt images, and split history will be permanently removed from our systems within 30 days. This action cannot be undone.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Changes Section
    private var changesSection: some View {
        LegalSection(title: "Changes to Terms") {
            VStack(alignment: .leading, spacing: 12) {
                Text("We reserve the right to modify these terms at any time. We will notify users of material changes through the app or by email.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("Your continued use of the service after changes become effective constitutes acceptance of the new terms.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("If you do not agree to the modified terms, you must stop using the service and may delete your account.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Governing Law Section
    private var governingLawSection: some View {
        LegalSection(title: "Governing Law") {
            VStack(alignment: .leading, spacing: 12) {
                Text("These terms shall be governed by and construed in accordance with the laws of the United States, without regard to conflict of law principles.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("Any disputes arising from these terms or your use of the service shall be resolved through binding arbitration in accordance with the rules of the American Arbitration Association.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        LegalSection(title: "Contact Information") {
            VStack(alignment: .leading, spacing: 12) {
                Text("If you have any questions about these Terms of Service, please contact us:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    ContactInfo(
                        type: "Email",
                        value: "splitsy.contact@gmail.com"
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

// MARK: - Supporting Views

struct ServiceFeature: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
    }
}

struct AccountRequirement: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "person.badge.shield.checkmark")
                .foregroundColor(.blue)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
    }
}

struct ProhibitedActivity: View {
    let activity: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
            
            Text(activity)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }
}

struct IPRestriction: View {
    let restriction: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 16))
            
            Text(restriction)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }
}

struct Disclaimer: View {
    let item: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
            
            Text(item)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }
}

struct LiabilityExclusion: View {
    let item: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
            
            Text(item)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }
}

// MARK: - Preview
#Preview {
    TermsOfServiceView()
}
