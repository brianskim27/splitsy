# Google Sign In Setup Guide

## 🔍 Step 1: Add Google Sign In Package

1. **In Xcode**, go to **File → Add Package Dependencies**
2. **Enter URL**: `https://github.com/google/GoogleSignIn-iOS.git`
3. **Click "Add Package"**
4. **Select the package** and click "Add Package"

## 🔥 Step 2: Configure Firebase for Google Sign In

1. **In Firebase Console**, go to **Authentication → Sign-in method**
2. **Enable "Google"** provider
3. **Enter your support email** (your email address)
4. **Click "Save"**

## 📱 Step 3: Configure URL Schemes

1. **In Xcode**, select your target
2. **Go to "Info" tab**
3. **Expand "URL Types"**
4. **Click "+" to add new URL type**
5. **Enter URL Schemes**: `com.googleusercontent.apps.YOUR_CLIENT_ID`
   - Replace `YOUR_CLIENT_ID` with the client ID from your `GoogleService-Info.plist`
   - The client ID looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

### How to find your Client ID:

1. **Open your `GoogleService-Info.plist`** file
2. **Look for the `CLIENT_ID` key**
3. **Copy the value** (it ends with `.apps.googleusercontent.com`)
4. **Add `com.googleusercontent.apps.`** before your client ID

**Example:**
- Client ID in plist: `123456789-abcdefghijklmnop.apps.googleusercontent.com`
- URL Scheme: `com.googleusercontent.apps.123456789-abcdefghijklmnop`

## 🔧 Step 4: Update Info.plist (Alternative Method)

If the URL Types method doesn't work, add this to your `Info.plist`:

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

## 🚀 Step 5: Test Google Sign In

1. **Clean Build Folder**: Product → Clean Build Folder
2. **Build and run** your app
3. **Tap "Sign in with Google"**
4. **Complete the Google Sign In flow**
5. **Verify user is created in Firebase Console**

## 🔧 Troubleshooting

### Common Issues:

1. **"Invalid client ID" error**
   - Check that URL scheme matches your client ID exactly
   - Make sure you added `com.googleusercontent.apps.` prefix
   - Verify `GoogleService-Info.plist` is properly configured

2. **"Sign in failed" error**
   - Make sure Google Sign In is enabled in Firebase Console
   - Check that GoogleSignIn package is properly added
   - Verify your bundle ID matches in Xcode and Firebase

3. **"No root view controller available" error**
   - This usually means the app is still loading
   - Try tapping the button again after the app is fully loaded

4. **"Firebase not configured" error**
   - Make sure `GoogleService-Info.plist` is in your project
   - Verify `FirebaseApp.configure()` is called in `splitsyApp.swift`

### Debug Steps:

1. **Check Firebase Console**:
   - Go to Authentication → Users
   - See if users are being created

2. **Check Xcode Console**:
   - Look for any error messages
   - Check if Google Sign In is being triggered

3. **Verify Package Installation**:
   - In Xcode, go to Project Settings → Package Dependencies
   - Make sure GoogleSignIn-iOS is listed

## 📋 Verification Checklist

- [ ] GoogleSignIn-iOS package added to project
- [ ] Google provider enabled in Firebase Console
- [ ] URL scheme configured correctly
- [ ] `GoogleService-Info.plist` in project
- [ ] Firebase initialized in app
- [ ] App builds without errors
- [ ] Google Sign In button responds
- [ ] User created in Firebase Console

## 🔗 Useful Links

- [Google Sign In iOS Documentation](https://developers.google.com/identity/sign-in/ios)
- [Firebase Google Auth Documentation](https://firebase.google.com/docs/auth/ios/google-signin)
- [Google Sign In iOS GitHub](https://github.com/google/GoogleSignIn-iOS)

## 🎯 Next Steps

Once Google Sign In is working:
1. **Test with different Google accounts**
2. **Verify user data is saved to Firestore**
3. **Test sign out functionality**
4. **Add user profile customization**
