import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showUsernameSetup = false
    @State private var isCheckingEmail = false
    @State private var emailAvailable = false
    @State private var showEmailTaken = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword, name
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Create Account")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Join Splitsy to start splitting bills with friends")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Sign up form
                    VStack(spacing: 20) {
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your full name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .name)
                                .onSubmit {
                                    focusedField = .email
                                }
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .email)
                                    .onChange(of: email) { oldValue, newValue in
                                        // Check email availability
                                        if !newValue.isEmpty && isValidEmail(newValue) {
                                            checkEmailAvailability(newValue)
                                        } else {
                                            emailAvailable = false
                                            showEmailTaken = false
                                        }
                                    }
                                .onSubmit {
                                    focusedField = .password
                                    }
                                
                                if isCheckingEmail {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .padding(.trailing, 12)
                                } else if !email.isEmpty && isValidEmail(email) {
                                    Image(systemName: emailAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(emailAvailable ? .green : .red)
                                        .padding(.trailing, 12)
                                }
                            }
                            
                            if showEmailTaken {
                                Text("This email is already registered")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if emailAvailable && !email.isEmpty {
                                Text("Email is available")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else if !email.isEmpty && !isValidEmail(email) {
                                Text("Please enter a valid email address")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Create a password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                            
                            Text("Must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Confirm password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .confirmPassword)
                                .onSubmit {
                                    signUp()
                                }
                        }
                        
                        // Error message
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Sign up button
                        Button(action: signUp) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        
                        // Terms and privacy
                        VStack(spacing: 8) {
                            Text("By creating an account, you agree to our")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Button("Terms of Service") {
                                    // Handle terms of service
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                
                                Text("and")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Privacy Policy") {
                                    // Handle privacy policy
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(.light)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss keyboard when tapping anywhere
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .fullScreenCover(isPresented: $showUsernameSetup) {
                UsernameSetupView(email: email, password: password)
                    .environmentObject(authManager)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        !name.isEmpty && 
        password == confirmPassword &&
        password.count >= 6 &&
        isValidEmail(email) &&
        emailAvailable &&
        !isCheckingEmail
    }
    
    private func signUp() {
        guard isFormValid else { return }
        showUsernameSetup = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        // More strict email regex pattern
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        // Basic regex check
        guard emailPredicate.evaluate(with: email) else { return false }
        
        // Additional checks
        let components = email.components(separatedBy: "@")
        guard components.count == 2 else { return false }
        
        let localPart = components[0]
        let domainPart = components[1]
        
        // Check local part (before @)
        guard !localPart.isEmpty && localPart.count <= 64 else { return false }
        guard !localPart.hasPrefix(".") && !localPart.hasSuffix(".") else { return false }
        guard !localPart.contains("..") else { return false }
        
        // Check domain part (after @)
        guard !domainPart.isEmpty && domainPart.count <= 253 else { return false }
        guard !domainPart.hasPrefix(".") && !domainPart.hasSuffix(".") else { return false }
        guard !domainPart.contains("..") else { return false }
        
        // Check for valid TLD (at least 2 characters, no numbers)
        let domainComponents = domainPart.components(separatedBy: ".")
        guard domainComponents.count >= 2 else { return false }
        
        let tld = domainComponents.last!
        guard tld.count >= 2 && tld.count <= 63 else { return false }
        guard tld.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil else { return false }
        
        // Check against common valid domains
        return isValidDomain(domainPart)
    }
    
    private func isValidDomain(_ domain: String) -> Bool {
        let domainLower = domain.lowercased()
        
        // List of known valid email domains (whitelist approach)
        let validDomains = [
            // Popular email providers
            "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com",
            "aol.com", "protonmail.com", "yandex.com", "mail.com", "zoho.com",
            "fastmail.com", "tutanota.com", "gmx.com", "live.com", "msn.com",
            "me.com", "mac.com", "icloud.com", "att.net", "verizon.net",
            "sbcglobal.net", "bellsouth.net", "comcast.net", "cox.net",
            "charter.net", "earthlink.net", "juno.com", "netzero.net",
            
            // International email providers
            "yandex.ru", "mail.ru", "rambler.ru", "list.ru", "inbox.ru",
            "qq.com", "163.com", "126.com", "sina.com", "sohu.com",
            "naver.com", "daum.net", "hanmail.net", "nate.com",
            
            // Business/enterprise domains (common patterns)
            "company.com", "business.com", "corp.com", "inc.com", "llc.com",
            "enterprise.com", "office.com", "work.com", "team.com"
        ]
        
        // Check if it's a known valid domain
        if validDomains.contains(domainLower) {
            return true
        }
        
        // For other domains, check if they end with a valid TLD
        let validTLDs = [
            // Generic TLDs
            "com", "org", "net", "edu", "gov", "mil", "int",
            "info", "biz", "name", "pro", "museum", "coop", "aero", "asia",
            "jobs", "mobi", "tel", "travel", "xxx", "cat", "post", "geo",
            
            // Country code TLDs (major countries)
            "us", "uk", "ca", "au", "de", "fr", "it", "es", "nl", "se", "no", 
            "dk", "fi", "jp", "kr", "cn", "in", "br", "mx", "ar", "cl", "pe", 
            "za", "ru", "pl", "tr", "gr", "pt", "be", "ch", "at", "ie", "nz",
            "sg", "hk", "tw", "th", "my", "id", "ph", "vn", "il", "ae", "sa",
            "eg", "ma", "ng", "ke", "gh", "tz", "ug", "zm", "zw", "bw", "sz",
            "ls", "mw", "mz", "mg", "mu", "sc", "re", "yt", "km", "dj", "so",
            "et", "er", "sd", "ss", "td", "cf", "cm", "gq", "ga", "cg", "cd",
            "ao", "st", "gw", "gn", "sl", "lr", "ci", "gh", "tg", "bj", "ne",
            "bf", "ml", "sn", "gm", "gn", "gw", "cv", "mr", "dz", "tn", "ly",
            
            // New gTLDs (popular ones)
            "io", "me", "tv", "cc", "co", "ly", "be", "am", "fm", "im", "la",
            "ms", "nu", "sc", "tk", "to", "ws", "ac", "ad", "ae", "af", "ag",
            "ai", "al", "am", "ao", "aq", "ar", "as", "at", "au", "aw", "ax",
            "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bl",
            "bm", "bn", "bo", "bq", "br", "bs", "bt", "bv", "bw", "by", "bz",
            "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn",
            "co", "cr", "cu", "cv", "cw", "cx", "cy", "cz", "de", "dj", "dk",
            "dm", "do", "dz", "ec", "ee", "eg", "eh", "er", "es", "et", "eu",
            "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gb", "gd", "ge", "gf",
            "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt",
            "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie",
            "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo",
            "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky",
            "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv",
            "ly", "ma", "mc", "md", "me", "mf", "mg", "mh", "mk", "ml", "mm",
            "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx",
            "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np",
            "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl",
            "pm", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs",
            "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sj",
            "sk", "sl", "sm", "sn", "so", "sr", "ss", "st", "su", "sv", "sx",
            "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm",
            "tn", "to", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "uk", "um",
            "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf",
            "ws", "ye", "yt", "za", "zm", "zw"
        ]
        
        let domainComponents = domainLower.components(separatedBy: ".")
        guard domainComponents.count >= 2 else { return false }
        
        // Check if TLD is valid
        if let tld = domainComponents.last {
            guard validTLDs.contains(tld) else { return false }
        }
        
        // For domains not in our whitelist, be more restrictive
        // Only allow domains that look like legitimate business/educational domains
        let domainName = domainComponents[0]
        
        // Reject obviously fake domains
        if domainName.count < 3 || domainName.count > 30 {
            return false
        }
        
        // Reject domains with numbers only or weird patterns
        if domainName.rangeOfCharacter(from: CharacterSet.letters) == nil {
            return false
        }
        
        // Reject domains that are obviously fake (like "dkfjdjf")
        let suspiciousPatterns = [
            "test", "fake", "dummy", "example", "sample", "temp", "temporary",
            "invalid", "none", "null", "empty", "blank", "random", "junk"
        ]
        
        if suspiciousPatterns.contains(domainName) {
            return false
        }
        
        // Allow domains that look legitimate (contain common business/educational keywords)
        let legitimateKeywords = [
            "university", "college", "school", "academy", "institute", "hospital",
            "clinic", "medical", "law", "legal", "consulting", "services", "solutions",
            "systems", "technology", "tech", "software", "digital", "media", "marketing",
            "advertising", "design", "creative", "studio", "agency", "group", "corp",
            "corporation", "company", "business", "enterprise", "organization", "foundation",
            "association", "society", "club", "network", "community", "center", "centre",
            "institute", "research", "development", "innovation", "global", "international",
            "national", "regional", "local", "city", "town", "village", "district",
            "government", "public", "official", "admin", "administrative", "management",
            "finance", "financial", "bank", "insurance", "investment", "trading",
            "retail", "store", "shop", "market", "commerce", "trade", "industry",
            "manufacturing", "production", "factory", "plant", "facility", "office",
            "headquarters", "main", "central", "primary", "principal", "chief",
            "executive", "director", "manager", "leader", "president", "ceo", "cfo",
            "cto", "coo", "vp", "vice", "senior", "junior", "assistant", "associate"
        ]
        
        // Check if domain contains legitimate keywords
        for keyword in legitimateKeywords {
            if domainName.contains(keyword) {
                return true
            }
        }
        
        // For now, be conservative and only allow domains that are in our whitelist
        // or contain legitimate business keywords
        return false
    }
    
    private func checkEmailAvailability(_ email: String) {
        guard isValidEmail(email) else {
            emailAvailable = false
            showEmailTaken = false
            return
        }
        
        isCheckingEmail = true
        showEmailTaken = false
        
        Task {
            let isAvailable = await authManager.checkEmailAvailability(email)
            await MainActor.run {
                self.emailAvailable = isAvailable
                self.isCheckingEmail = false
                if !isAvailable {
                    self.showEmailTaken = true
                }
            }
        }
    }
}
