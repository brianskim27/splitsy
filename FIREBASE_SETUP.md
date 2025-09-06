# Firebase Setup Guide for Splitsy

## 🔥 Step 1: Firebase Project Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project"
   - Enter project name: "Splitsy"
   - Enable Google Analytics (optional)
   - Click "Create project"

2. **Add iOS App**
   - Click "Add app" → iOS
   - Enter Bundle ID: `com.yourcompany.splitsy` (match your Xcode project)
   - Enter App nickname: "Splitsy"
   - Click "Register app"

3. **Download Configuration**
   - Download `GoogleService-Info.plist`
   - Replace the template file in your Xcode project
   - Make sure it's added to your target

## 📱 Step 2: Xcode Project Setup

1. **Add Firebase SDK**
   - In Xcode, go to **File → Add Package Dependencies**
   - Enter URL: `https://github.com/firebase/firebase-ios-sdk.git`
   - Click "Add Package"
   - Select these packages:
     - **FirebaseAuth**
     - **FirebaseFirestore**
   - Click "Add Package"

2. **Add GoogleService-Info.plist**
   - Download your `GoogleService-Info.plist` from Firebase Console
   - Drag it into your Xcode project
   - Make sure "Add to target" is checked for your app target

3. **Initialize Firebase**
   - The `splitsyApp.swift` file already has the Firebase initialization
   - Make sure `GoogleService-Info.plist` is in your project bundle

## 🔐 Step 3: Firebase Authentication Setup

1. **Enable Email/Password Auth**
   - In Firebase Console, go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Click "Save"

2. **Configure Firestore Database**
   - Go to Firestore Database → Create database
   - Start in test mode (for development)
   - Choose a location close to your users

## 🚀 Step 4: Test the Integration

1. **Build and Run**
   - Clean build folder (Product → Clean Build Folder)
   - Build and run the app
   - Try creating an account and signing in

2. **Verify Data Sync**
   - Create a split in the app
   - Check Firebase Console → Firestore Database
   - You should see user data and splits being saved

## 🔧 Troubleshooting

### Common Issues:

1. **"Firebase not configured" error**
   - Make sure `GoogleService-Info.plist` is in your project
   - Verify `FirebaseApp.configure()` is called in `init()`

2. **Build errors with Firebase imports**
   - Clean build folder and rebuild
   - Check that Firebase packages are properly added

3. **Authentication not working**
   - Verify Email/Password auth is enabled in Firebase Console
   - Check that your bundle ID matches the Firebase project

### Security Rules (for production):

```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /splits/{splitId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 📋 Next Steps

After Firebase is working, you can proceed to implement:
1. **Social Login** (Google, Facebook)
2. **Email Verification**
3. **Advanced Data Sync** (real-time updates, offline support)

## 🔗 Useful Links

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth/ios/start)
- [Firestore Documentation](https://firebase.google.com/docs/firestore/quickstart)
