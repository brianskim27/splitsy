import SwiftUI

enum FeedbackType: String, CaseIterable {
    case bug = "Bug Report"
    case feature = "Feature Request"
    case general = "General Feedback"
    case performance = "Performance Issue"
    case uiux = "UI/UX Suggestion"
    case question = "Question/Help"
    
    var icon: String {
        switch self {
        case .bug: return "ant.fill"
        case .feature: return "lightbulb.fill"
        case .general: return "message.fill"
        case .performance: return "speedometer"
        case .uiux: return "paintbrush.fill"
        case .question: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bug: return .red
        case .feature: return .blue
        case .general: return .green
        case .performance: return .orange
        case .uiux: return .purple
        case .question: return .gray
        }
    }
}
    
enum PriorityLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var description: String {
        switch self {
        case .low: return "Minor issue or nice-to-have feature"
        case .medium: return "Moderate impact on experience"
        case .high: return "Significant issue affecting usability"
        case .critical: return "App crashes or major functionality broken"
        }
    }
}
    
enum UserJourney: String, CaseIterable {
    case receiptScanning = "Receipt Scanning"
    case itemAssignment = "Assigning Items"
    case splitCalculation = "Calculating Splits"
    case profileSettings = "Profile/Settings"
    case signupLogin = "Sign-up/Login"
    case other = "Other"
}

enum Frequency: String, CaseIterable {
    case everyTime = "Every time"
    case mostTime = "Most of the time"
    case sometimes = "Sometimes"
    case rarely = "Rarely"
    case firstTime = "First time"
}

enum Impact: String, CaseIterable {
    case prevents = "Prevents me from using the app"
    case difficult = "Makes the app difficult to use"
    case minor = "Minor inconvenience"
    case noEffect = "Doesn't affect my experience"
    case improves = "Actually improves my experience"
}

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .general
    @State private var priority: PriorityLevel = .medium
    @State private var description: String = ""
    @State private var deviceInfo: String = ""
    @State private var userJourney: UserJourney? = nil
    @State private var frequency: Frequency? = nil
    @State private var impact: Impact? = nil
    @State private var contactEmail: String = ""
    @State private var additionalComments: String = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var attachedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Feedback Type
                    feedbackTypeSection
                    
                    // Priority Level
                    prioritySection
                    
                    // Description
                    descriptionSection
                    
                    // Device Information
                    deviceInfoSection
                    
                    // Conditional Questions
                    if feedbackType == .bug {
                        conditionalBugQuestions
                    }
                    
                    if feedbackType == .feature {
                        conditionalFeatureQuestions
                    }
                    
                    // Contact Information
                    contactSection
                    
                    // Screenshots
                    screenshotsSection
                    
                    // Additional Comments
                    additionalCommentsSection
                    
                    // Submit Button
                    submitSection
                }
                .padding(.horizontal)
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping anywhere
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .onAppear {
            setupDeviceInfo()
        }
        .alert("Feedback Sent!", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for your feedback! We'll review your submission and get back to you if you provided contact information.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Help us improve Splitsy!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Your feedback helps us create a better experience for everyone.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 20)
    }
    
    private var feedbackTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What type of feedback are you providing?")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(FeedbackType.allCases, id: \.self) { type in
                    Button(action: {
                        feedbackType = type
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.system(size: 24))
                                .foregroundColor(feedbackType == type ? .white : type.color)
                            
                            Text(type.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(feedbackType == type ? .white : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(feedbackType == type ? type.color : Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(feedbackType == type ? type.color : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Level")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(PriorityLevel.allCases, id: \.self) { level in
                    Button(action: {
                        priority = level
                    }) {
                        HStack {
                            Image(systemName: priority == level ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(priority == level ? .blue : .gray)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.rawValue)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $description)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            if description.isEmpty {
                Text(getDescriptionPlaceholder())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    private var deviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Device Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Device details", text: $deviceInfo)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
    }
    
    private var conditionalBugQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bug Report Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            // User Journey
            VStack(alignment: .leading, spacing: 8) {
                Text("When did this issue occur?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("User Journey", selection: $userJourney) {
                    Text("Select...").tag(nil as UserJourney?)
                    ForEach(UserJourney.allCases, id: \.self) { journey in
                        Text(journey.rawValue).tag(journey as UserJourney?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Frequency
            VStack(alignment: .leading, spacing: 8) {
                Text("How often does this issue occur?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Frequency", selection: $frequency) {
                    Text("Select...").tag(nil as Frequency?)
                    ForEach(Frequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq as Frequency?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Impact
            VStack(alignment: .leading, spacing: 8) {
                Text("How does this affect your use of Splitsy?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Impact", selection: $impact) {
                    Text("Select...").tag(nil as Impact?)
                    ForEach(Impact.allCases, id: \.self) { imp in
                        Text(imp.rawValue).tag(imp as Impact?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var conditionalFeatureQuestions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feature Request Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How would this feature improve your experience?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextEditor(text: $additionalComments)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information (Optional)")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Email for follow-up", text: $contactEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Text("We'll only use this to follow up on your feedback if needed.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var screenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Screenshots (Optional)")
                .font(.headline)
                .fontWeight(.semibold)
            
            if attachedImages.isEmpty {
                Button(action: {
                    showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Add Screenshot")
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                VStack(spacing: 12) {
                    // Display attached images
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(attachedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: attachedImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Button(action: {
                                        attachedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                            
                            // Add more button
                            if attachedImages.count < 5 {
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                        Text("Add More")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    Text("Screenshots help us understand your feedback better. You can add up to 5 images.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: Binding(
                get: { nil },
                set: { newImage in
                    if let image = newImage {
                        attachedImages.append(image)
                    }
                }
            ), sourceType: .photoLibrary)
        }
    }
    
    private var additionalCommentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Comments")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $additionalComments)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    private var submitSection: some View {
        VStack(spacing: 16) {
            Button(action: submitFeedback) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text(isSubmitting ? "Submitting..." : "Submit Feedback")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!isFormValid || isSubmitting)
            
            Button(action: {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(getAppStoreID())?action=write-review") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Rate Splitsy on App Store")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !deviceInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Methods
    
    private func setupDeviceInfo() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        
        deviceInfo = "\(deviceModel), iOS \(systemVersion), App v\(appVersion) (\(buildNumber))"
    }
    
    private func getDescriptionPlaceholder() -> String {
        switch feedbackType {
        case .bug:
            return "• What were you trying to do?\n• What happened instead?\n• What did you expect to happen?\n• Can you reproduce this issue?"
        case .feature:
            return "• What feature would you like to see?\n• How would this improve your experience?\n• Any specific use cases or examples?"
        case .general:
            return "• What do you like about Splitsy?\n• What could be improved?\n• Any other thoughts or suggestions?"
        case .performance:
            return "• What performance issues are you experiencing?\n• When do they occur?\n• How does it affect your usage?"
        case .uiux:
            return "• What UI/UX improvements would you suggest?\n• Which screens or features need work?\n• Any specific design ideas?"
        case .question:
            return "• What question do you have about Splitsy?\n• What would you like help with?\n• Any confusion about features?"
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Create email content
        let emailContent = createEmailContent()
        
        // Send email automatically
        sendEmailAutomatically(content: emailContent)
    }
    
    private func createEmailContent() -> (subject: String, body: String) {
        let subject = "Splitsy Feedback: \(feedbackType.rawValue)"
        
        var emailBody = """
        Feedback Type: \(feedbackType.rawValue)
        Priority: \(priority.rawValue)
        
        Description:
        \(description)
        
        Device Information:
        \(deviceInfo)
        """
        
        if let journey = userJourney {
            emailBody += "\nUser Journey: \(journey.rawValue)"
        }
        
        if let freq = frequency {
            emailBody += "\nFrequency: \(freq.rawValue)"
        }
        
        if let imp = impact {
            emailBody += "\nImpact: \(imp.rawValue)"
        }
        
        if !contactEmail.isEmpty {
            emailBody += "\nContact Email: \(contactEmail)"
        }
        
        if !additionalComments.isEmpty {
            emailBody += "\n\nAdditional Comments:\n\(additionalComments)"
        }
        
        emailBody += "\n\n---\nSent from Splitsy iOS App"
        
        return (subject: subject, body: emailBody)
    }
    
    private func sendEmailAutomatically(content: (subject: String, body: String)) {
        Task {
            do {
                let success = try await sendFeedbackToAPI(content: content)
                await MainActor.run {
                    self.isSubmitting = false
                    if success {
                        self.showSuccessAlert = true
                    } else {
                        self.errorMessage = "Failed to send feedback. Please try again."
                        self.showErrorAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    self.errorMessage = "Network error. Please check your connection and try again."
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func sendFeedbackToAPI(content: (subject: String, body: String)) async throws -> Bool {
        // Create the feedback data structure
        let feedbackData = FeedbackSubmission(
            feedbackType: feedbackType.rawValue,
            priority: priority.rawValue,
            description: description,
            deviceInfo: deviceInfo,
            userJourney: userJourney?.rawValue,
            frequency: frequency?.rawValue,
            impact: impact?.rawValue,
            contactEmail: contactEmail.isEmpty ? nil : contactEmail,
            additionalComments: additionalComments.isEmpty ? nil : additionalComments,
            attachedImages: attachedImages
        )
        
        // Convert to JSON
        let jsonData = try JSONEncoder().encode(feedbackData)
        
        // Create URL request
        // TODO: Replace with your actual deployed API URL
        guard let url = URL(string: "https://splitsy-feedback-api.herokuapp.com/api/feedback") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send request
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        
        return false
    }
    
    private func getAppStoreID() -> String {
        // Replace with actual App Store ID when published
        return "1234567890"
    }
}


// MARK: - Data Structures
struct FeedbackSubmission: Codable {
    let feedbackType: String
    let priority: String
    let description: String
    let deviceInfo: String
    let userJourney: String?
    let frequency: String?
    let impact: String?
    let contactEmail: String?
    let additionalComments: String?
    let attachedImages: [String] // Base64 encoded image strings
    
    init(feedbackType: String, priority: String, description: String, deviceInfo: String, 
         userJourney: String?, frequency: String?, impact: String?, 
         contactEmail: String?, additionalComments: String?, attachedImages: [UIImage]) {
        self.feedbackType = feedbackType
        self.priority = priority
        self.description = description
        self.deviceInfo = deviceInfo
        self.userJourney = userJourney
        self.frequency = frequency
        self.impact = impact
        self.contactEmail = contactEmail
        self.additionalComments = additionalComments
        
        // Convert UIImage array to base64 string array
        self.attachedImages = attachedImages.compactMap { image in
            image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
}

// MARK: - Preview
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
