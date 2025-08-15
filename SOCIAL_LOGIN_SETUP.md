# Social Login Setup Guide

## 🍎 Apple Sign In Setup

### Step 1: Enable Apple Sign In in Xcode

1. **Open your Xcode project**
2. **Select your target**
3. **Go to "Signing & Capabilities" tab**
4. **Click "+ Capability"**
5. **Add "Sign in with Apple"**

### Step 2: Configure Firebase for Apple Sign In

1. **In Firebase Console**, go to **Authentication → Sign-in method**
2. **Enable "Apple"** provider
3. **Enter your Apple Developer Team ID** (found in Apple Developer Console)
4. **Enter your Apple Services ID** (create one if needed)
5. **Click "Save"**

### Step 3: Create Apple Services ID (if needed)

1. **Go to [Apple Developer Console](https://developer.apple.com/account/)**
2. **Navigate to Certificates, Identifiers & Profiles**
3. **Select "Identifiers"**
4. **Click "+" to create new identifier**
5. **Select "Services IDs"**
6. **Enter description**: "Splitsy Apple Sign In"
7. **Enter identifier**: `com.yourcompany.splitsy.signin`
8. **Check "Sign In with Apple"**
9. **Configure domain and redirect URLs**
10. **Click "Continue" and "Register"**

## 🔍 Google Sign In Setup

### Step 1: Add Google Sign In Package

1. **In Xcode**, go to **File → Add Package Dependencies**
2. **Enter URL**: `https://github.com/google/GoogleSignIn-iOS.git`
3. **Click "Add Package"**
4. **Select the package** and click "Add Package"

### Step 2: Configure Firebase for Google Sign In

1. **In Firebase Console**, go to **Authentication → Sign-in method**
2. **Enable "Google"** provider
3. **Enter your support email**
4. **Click "Save"**

### Step 3: Configure URL Schemes

1. **In Xcode**, select your target
2. **Go to "Info" tab**
3. **Expand "URL Types"**
4. **Click "+" to add new URL type**
5. **Enter URL Schemes**: `com.googleusercontent.apps.YOUR_CLIENT_ID`
   - Replace `YOUR_CLIENT_ID` with the client ID from your `GoogleService-Info.plist`

### Step 4: Update Info.plist

Add these entries to your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>GoogleSignIn</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 🔧 Additional Configuration

### Update App Delegate (if using UIKit)

If you're using UIKit, add this to your `AppDelegate.swift`:

```swift
import GoogleSignIn

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
```

### Update Scene Delegate (if using UIKit)

Add this to your `SceneDelegate.swift`:

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    GIDSignIn.sharedInstance.handle(url)
}
```

## 🚀 Testing Social Login

### Test Apple Sign In

1. **Build and run** your app
2. **Tap "Sign in with Apple"**
3. **Complete the Apple Sign In flow**
4. **Verify user is created in Firebase Console**

### Test Google Sign In

1. **Build and run** your app
2. **Tap "Sign in with Google"**
3. **Complete the Google Sign In flow**
4. **Verify user is created in Firebase Console**

## 🔧 Troubleshooting

### Apple Sign In Issues

1. **"Sign in with Apple not configured"**
   - Make sure capability is added in Xcode
   - Verify Apple Services ID is configured in Firebase

2. **"Invalid client" error**
   - Check that your bundle ID matches in Xcode and Firebase
   - Verify Apple Developer Team ID is correct

### Google Sign In Issues

1. **"Invalid client ID" error**
   - Check that URL scheme matches your client ID
   - Verify `GoogleService-Info.plist` is properly configured

2. **"Sign in failed" error**
   - Make sure Google Sign In is enabled in Firebase Console
   - Check that GoogleSignIn package is properly added

## 📱 User Experience

### Apple Sign In Benefits

- **Privacy-focused**: Users can choose to hide their email
- **One-tap sign in**: Fast and convenient
- **App Store requirement**: Required if you offer other social logins

### Google Sign In Benefits

- **Wide adoption**: Most users have Google accounts
- **Rich profile data**: Access to name, email, profile picture
- **Cross-platform**: Works on iOS, Android, and web

## 🔗 Useful Links

- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Google Sign In iOS Documentation](https://developers.google.com/identity/sign-in/ios)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth/ios/start)
