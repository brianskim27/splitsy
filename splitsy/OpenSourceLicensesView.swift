import SwiftUI

struct OpenSourceLicensesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Introduction
                    introductionSection
                    
                    // Third-Party Libraries
                    thirdPartyLibrariesSection
                    
                    // Apple Frameworks
                    appleFrameworksSection
                    
                    // Google Services
                    googleServicesSection
                    
                    // License Information
                    licenseInformationSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Open Source Licenses")
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
            Text("Splitsy uses several open source libraries and frameworks. This page acknowledges the developers and licenses of these components.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Introduction Section
    private var introductionSection: some View {
        LegalSection(title: "Acknowledgments") {
            VStack(alignment: .leading, spacing: 12) {
                Text("We are grateful to the open source community for providing the tools and libraries that make Splitsy possible. The following components are used in accordance with their respective licenses.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                Text("All licenses are reproduced below for your reference.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Third-Party Libraries Section
    private var thirdPartyLibrariesSection: some View {
        LegalSection(title: "Third-Party Libraries") {
            VStack(spacing: 16) {
                OpenSourceLibrary(
                    name: "Firebase iOS SDK",
                    version: "10.x",
                    license: "Apache License 2.0",
                    description: "Backend services including authentication, database, and storage",
                    licenseText: getApacheLicense()
                )
                
                OpenSourceLibrary(
                    name: "Google Sign-In SDK",
                    version: "7.x",
                    license: "Apache License 2.0",
                    description: "Google authentication integration",
                    licenseText: getApacheLicense()
                )
            }
        }
    }
    
    // MARK: - Apple Frameworks Section
    private var appleFrameworksSection: some View {
        LegalSection(title: "Apple Frameworks") {
            VStack(spacing: 16) {
                AppleFramework(
                    name: "SwiftUI",
                    description: "User interface framework for building declarative UIs",
                    license: "Apple Software License"
                )
                
                AppleFramework(
                    name: "Vision Framework",
                    description: "Computer vision framework for text recognition and image analysis",
                    license: "Apple Software License"
                )
                
                AppleFramework(
                    name: "Combine",
                    description: "Reactive programming framework for handling asynchronous events",
                    license: "Apple Software License"
                )
                
                AppleFramework(
                    name: "AuthenticationServices",
                    description: "Framework for Apple Sign-In integration",
                    license: "Apple Software License"
                )
            }
        }
    }
    
    // MARK: - Google Services Section
    private var googleServicesSection: some View {
        LegalSection(title: "Google Services") {
            VStack(spacing: 16) {
                GoogleService(
                    name: "Firebase Authentication",
                    description: "User authentication and account management",
                    terms: "https://firebase.google.com/terms"
                )
                
                GoogleService(
                    name: "Cloud Firestore",
                    description: "NoSQL document database for storing user data",
                    terms: "https://firebase.google.com/terms"
                )
                
                GoogleService(
                    name: "Firebase Storage",
                    description: "Cloud storage for receipt images and user files",
                    terms: "https://firebase.google.com/terms"
                )
                
                GoogleService(
                    name: "Google Sign-In",
                    description: "OAuth 2.0 authentication service",
                    terms: "https://policies.google.com/terms"
                )
            }
        }
    }
    
    // MARK: - License Information Section
    private var licenseInformationSection: some View {
        LegalSection(title: "License Information") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Splitsy itself is proprietary software. All rights reserved. The source code is protected by copyright and may not be copied, modified, or distributed without explicit written permission.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 8) {
                    LicenseInfo(
                        title: "Proprietary License",
                        description: "All rights reserved. No copying, modification, or distribution permitted without permission"
                    )
                    
                    LicenseInfo(
                        title: "Apache License 2.0",
                        description: "Permissive license used by Firebase and Google services"
                    )
                    
                    LicenseInfo(
                        title: "Apple Software License",
                        description: "Proprietary license for Apple frameworks and services"
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getApacheLicense() -> String {
        return """
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
        
            http://www.apache.org/licenses/LICENSE-2.0
        
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
        """
    }
}

// MARK: - Supporting Views

struct OpenSourceLibrary: View {
    let name: String
    let version: String
    let license: String
    let description: String
    let licenseText: String
    @State private var showLicense = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Version \(version)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showLicense.toggle()
                }) {
                    Text(showLicense ? "Hide License" : "View License")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            HStack {
                Text("License:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(license)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                
                Spacer()
            }
            
            if showLicense {
                ScrollView {
                    Text(licenseText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

struct AppleFramework: View {
    let name: String
    let description: String
    let license: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "applelogo")
                    .foregroundColor(.primary)
                    .font(.system(size: 16))
                
                Text(name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            HStack {
                Text("License:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(license)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

struct GoogleService: View {
    let name: String
    let description: String
    let terms: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                
                Text(name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            Button("View Terms of Service") {
                if let url = URL(string: terms) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

struct LicenseInfo: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "doc.text")
                .foregroundColor(.accentColor)
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

// MARK: - Preview
#Preview {
    OpenSourceLicensesView()
}
