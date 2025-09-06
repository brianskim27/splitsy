import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Introduction
                    introductionSection
                    
                    // Information We Collect
                    informationCollectionSection
                    
                    // How We Use Information
                    informationUsageSection
                    
                    // Data Storage and Security
                    dataSecuritySection
                    
                    // Third-Party Services
                    thirdPartyServicesSection
                    
                    // Your Rights
                    userRightsSection
                    
                    // Data Retention
                    dataRetentionSection
                    
                    
                    // Changes to Policy
                    policyChangesSection
                    
                    // Contact Information
                    contactSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Privacy Policy")
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
            
            Text("This Privacy Policy describes how Splitsy collects, uses, and protects your information when you use our mobile application.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Introduction Section
    private var introductionSection: some View {
        LegalSection(title: "Introduction") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Splitsy is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our bill-splitting application.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("By using Splitsy, you agree to the collection and use of information in accordance with this policy.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Information Collection Section
    private var informationCollectionSection: some View {
        LegalSection(title: "Information We Collect") {
            VStack(alignment: .leading, spacing: 16) {
                InformationType(
                    title: "Personal Information (Linked to Identity)",
                    items: [
                        "Email address (required for account creation and authentication)",
                        "Display name and username (required for account setup)",
                        "Profile picture (optional, stored securely)"
                    ]
                )
                
                InformationType(
                    title: "Receipt Data (Linked to Identity)",
                    items: [
                        "Receipt images you capture or upload (processed locally and stored securely)",
                        "Item names and prices extracted from receipts (for split calculations)",
                        "Split calculations and assignments (stored for your reference)"
                    ]
                )
                
                InformationType(
                    title: "Usage Information (Not Linked to Identity)",
                    items: [
                        "App usage patterns and features used (for service improvement)",
                        "Device information (iOS version, device model for compatibility)",
                        "Crash reports and performance data (for app stability)"
                    ]
                )
                
                InformationType(
                    title: "Automatically Collected Data (Not Linked to Identity)",
                    items: [
                        "Device identifiers (for app functionality and analytics)",
                        "App version and build information (for updates and support)",
                        "Timestamp of app usage (for service optimization)"
                    ]
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Consent and Data Collection")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("We only collect data that is necessary for the app's core functionality. You provide explicit consent when you create an account and use our services. You can withdraw consent at any time by deleting your account or contacting us.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
            }
        }
    }
    
    // MARK: - Information Usage Section
    private var informationUsageSection: some View {
        LegalSection(title: "How We Use Your Information") {
            VStack(alignment: .leading, spacing: 12) {
                UsagePurpose(
                    title: "Service Provision",
                    description: "To provide and maintain our bill-splitting service, including receipt scanning, item parsing, and split calculations."
                )
                
                UsagePurpose(
                    title: "Account Management",
                    description: "To create and manage your user account, authenticate your identity, and provide customer support."
                )
                
                UsagePurpose(
                    title: "Service Improvement",
                    description: "To analyze usage patterns, improve our AI receipt scanning accuracy, and enhance user experience."
                )
                
                UsagePurpose(
                    title: "Communication",
                    description: "To send you important updates about the service, respond to your inquiries, and provide customer support."
                )
                
                UsagePurpose(
                    title: "Legal Compliance",
                    description: "To comply with applicable laws, regulations, and legal processes."
                )
            }
        }
    }
    
    // MARK: - Data Security Section
    private var dataSecuritySection: some View {
        LegalSection(title: "Data Storage and Security") {
            VStack(alignment: .leading, spacing: 12) {
                Text("We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    SecurityMeasure(
                        title: "Encryption",
                        description: "All data is encrypted in transit and at rest using industry-standard encryption protocols."
                    )
                    
                    SecurityMeasure(
                        title: "Secure Infrastructure",
                        description: "We use Firebase, a Google Cloud Platform service, for secure data storage and processing."
                    )
                    
                    SecurityMeasure(
                        title: "Access Controls",
                        description: "Access to your data is restricted to authorized personnel who need it to provide our services."
                    )
                    
                    SecurityMeasure(
                        title: "Regular Audits",
                        description: "We regularly review and update our security practices to maintain the highest standards."
                    )
                }
            }
        }
    }
    
    // MARK: - Third-Party Services Section
    private var thirdPartyServicesSection: some View {
        LegalSection(title: "Third-Party Services") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Splitsy uses the following third-party services to provide our functionality:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    ThirdPartyService(
                        name: "Firebase (Google)",
                        purpose: "Authentication, data storage, and cloud functions",
                        privacyPolicy: "https://firebase.google.com/support/privacy"
                    )
                    
                    ThirdPartyService(
                        name: "Apple Vision Framework",
                        purpose: "Receipt text recognition and OCR processing",
                        privacyPolicy: "https://www.apple.com/privacy/"
                    )
                    
                    ThirdPartyService(
                        name: "Google Sign-In",
                        purpose: "User authentication",
                        privacyPolicy: "https://policies.google.com/privacy"
                    )
                }
            }
        }
    }
    
    // MARK: - User Rights Section
    private var userRightsSection: some View {
        LegalSection(title: "Your Rights") {
            VStack(alignment: .leading, spacing: 12) {
                Text("You have the following rights regarding your personal information:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    UserRight(
                        title: "Access",
                        description: "Request access to the personal information we hold about you."
                    )
                    
                    UserRight(
                        title: "Correction",
                        description: "Request correction of inaccurate or incomplete personal information."
                    )
                    
                    UserRight(
                        title: "Deletion",
                        description: "Request deletion of your personal information and account."
                    )
                    
                    UserRight(
                        title: "Data Portability",
                        description: "Request a copy of your data in a structured, machine-readable format."
                    )
                    
                    UserRight(
                        title: "Objection",
                        description: "Object to the processing of your personal information for certain purposes."
                    )
                }
                
                Text("To exercise these rights, please contact us at splitsy.contact@gmail.com")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Data Retention Section
    private var dataRetentionSection: some View {
        LegalSection(title: "Data Retention") {
            VStack(alignment: .leading, spacing: 12) {
                Text("We retain your personal information only for as long as necessary to provide our services and fulfill the purposes outlined in this Privacy Policy. You can request deletion of your data at any time.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    RetentionPeriod(
                        item: "Account Information",
                        period: "Until account deletion (immediate upon request)"
                    )
                    
                    RetentionPeriod(
                        item: "Receipt Data & Images",
                        period: "Until account deletion (immediate upon request)"
                    )
                    
                    RetentionPeriod(
                        item: "Split History",
                        period: "Until account deletion (immediate upon request)"
                    )
                    
                    RetentionPeriod(
                        item: "Usage Analytics (Anonymous)",
                        period: "Up to 2 years (aggregated, non-identifiable data)"
                    )
                    
                    RetentionPeriod(
                        item: "Crash Reports",
                        period: "Up to 90 days (for app improvement)"
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Deletion")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("You can delete your account and all associated data at any time through the app settings or by contacting us. Deletion is permanent and cannot be undone.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
            }
        }
    }
    
    
    // MARK: - Policy Changes Section
    private var policyChangesSection: some View {
        LegalSection(title: "Changes to This Privacy Policy") {
            VStack(alignment: .leading, spacing: 12) {
                Text("We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the app and updating the \"Last updated\" date.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        LegalSection(title: "Contact Us") {
            VStack(alignment: .leading, spacing: 12) {
                Text("If you have any questions about this Privacy Policy or our privacy practices, please contact us:")
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

struct LegalSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InformationType: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
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
        }
    }
}

struct UsagePurpose: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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

struct SecurityMeasure: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
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

struct ThirdPartyService: View {
    let name: String
    let purpose: String
    let privacyPolicy: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(purpose)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            Button("View Privacy Policy") {
                if let url = URL(string: privacyPolicy) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
    }
}

struct UserRight: View {
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

struct RetentionPeriod: View {
    let item: String
    let period: String
    
    var body: some View {
        HStack {
            Text(item)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(period)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
        }
    }
}

struct ContactInfo: View {
    let type: String
    let value: String
    
    var body: some View {
        HStack {
            Text(type)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    PrivacyPolicyView()
}
