# <img width="80" height="80" alt="splitsy icon official 80x80" src="https://github.com/user-attachments/assets/b3e1e30e-766e-40a2-b878-c42b5b0b9eb1" /> Splitsy

**Because math shouldn't ruin your dinner plans**

[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
> ⚠️ **Proprietary Software** - This code is protected by copyright and may not be copied, modified, or distributed without permission. See [LICENSE](LICENSE) for details.
> 
> **Copyright © 2025 Brian Kim. All rights reserved.**

Splitsy is a modern iOS app that eliminates the hassle of manual bill splitting. Simply take a photo of your receipt, and our AI-powered system will automatically parse items and prices, allowing you to assign each item to your party members in seconds.

## ✨ Features

### 🔍 **Smart Receipt Scanning**
- **Apple Vision API Integration**: Automatically extracts items and prices from receipt photos
- **Manual Input Option**: Upload receipts from your photo library or enter items manually
- **High Accuracy**: Advanced OCR technology for reliable text recognition

### 👥 **Intuitive Bill Splitting**
- **Tap to Assign**: Easily assign items to different people
- **Real-time Calculations**: Instant updates as you assign items
- **Tip Management**: Add tips with percentage or fixed amount options
- **Multi-Currency Support**: Change and convert currencies in real-time with live rates
- **Multiple Payment Methods**: Support for various splitting scenarios (coming soon)

### 🎨 **Modern UI/UX**
- **Clean, Intuitive Design**: Beautiful SwiftUI interface with smooth animations
- **Horizontal Item Wheels**: Easy-to-use scrollable item selection
- **User-Friendly**: Streamlined UI structure and navigations for user's comfort
- **Typing Made Easy**: Smart keyboard handling with tap-to-dismiss

### 🔐 **Secure Authentication**
- **Firebase Integration**: Robust user authentication and data storage
- **Google Sign-In**: One-tap login with Google accounts
- **Apple Sign-In**: Secure authentication with Apple ID (coming soon)
- **Email Verification**: Complete account setup with username creation

### 📊 **Comprehensive History**
- **Split History**: View all your previous bill splits
- **Statistics Dashboard**: Track spending patterns and split frequency
- **Receipt Storage**: Access original receipt images anytime
- **Export Options**: Share split details with friends

### 🛠 **Advanced Features**
- **Profile Management**: Custom profile pictures and account settings
- **In-App Feedback**: Built-in bug reporting and feature requests
- **Offline Support**: Core functionality works without internet
- **Data Sync**: Seamless synchronization across devices

## 🏗 **Architecture**

### **Frontend (iOS)**
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Firebase SDK**: Authentication, Firestore, and Storage
- **Vision Framework**: Apple's machine learning for text recognition

### **Backend Services**
- **Firebase Backend**: Authentication, database, and file storage
- **Node.js API**: Feedback system with automatic email delivery
- **SendGrid Integration**: Reliable email delivery service
- **Railway Deployment**: Cloud hosting for backend services

## 📱 **Screenshots**

<div align="center">
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Home Screen</h4>
        <img src="screenshots/01-home-screen.png" width="150" alt="Home Screen">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Receipt Scanning</h4>
        <img src="screenshots/02-receipt-scanning.png" width="150" alt="Receipt Scanning">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Item Assignment</h4>
        <img src="screenshots/03-item-assignment.png" width="150" alt="Item Assignment">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Final Result</h4>
        <img src="screenshots/04-result.png" width="150" alt="Final Split Result">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Split Details</h4>
        <img src="screenshots/05-split-details.png" width="150" alt="Split Details">
    </div>
</div>

<div align="center">
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">History</h4>
        <img src="screenshots/06-history.png" width="150" alt="History">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Profile</h4>
        <img src="screenshots/07-profile-view.png" width="150" alt="Profile Screen">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Statistics</h4>
        <img src="screenshots/08-statistics-dashboard.png" width="150" alt="Statistics Dashboard">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Currency</h4>
        <img src="screenshots/09-currency.png" width="150" alt="Currency">
    </div>
    <div style="display: inline-block; margin: 5px; text-align: center; vertical-align: top; width: 160px;">
        <h4 style="margin: 5px 0; font-size: 14px;">Quick Split</h4>
        <img src="screenshots/10-quick-split.png" width="150" alt="Quick Split">
    </div>
</div>

### **Key Features Showcased:**

| Screenshot | Description |
|------------|-------------|
| **Home Screen** | Intuitive navigation with recent splits and quick actions |
| **Receipt Scanning** | AI-powered OCR automatically detects items and prices with item-editing option |
| **Item Assignment** | Easy tap-and-assign interface to assign items to people with tip option|
| **Final Split Result** | Clear breakdown showing each person's total amount with export feature |
| **Split Details** | View details of a previous split with receipt image attached |
| **History** | View complete history of previous splits with search feature |
| **Profile Screen** | Personal dashboard with spending insights and settings |
| **Statistics Dashboard** | Comprehensive analytics with weekly/monthly trends |
| **Currency** | Flexible multi-currency support for compatibility with any bill |
| **Quick Split** | Manual input option for simple splitting |

## 🚀 **Getting Started**

### **Prerequisites**
- Xcode 15.0+
- iOS 17.0+
- Firebase project setup
- Apple Developer account (for App Store deployment)

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/splitsy.git
   cd splitsy
   ```

2. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add iOS app to your Firebase project
   - Download `GoogleService-Info.plist` and add to Xcode project
   - Enable Authentication, Firestore, and Storage services

3. **Configure Authentication**
   - Enable Google Sign-In in Firebase Console
   - Configure Apple Sign-In in Apple Developer Console
   - Update `Info.plist` with necessary URL schemes

4. **Backend Setup** (Optional - for feedback system)
   ```bash
   cd backend
   npm install
   cp env.example .env
   # Configure SendGrid API key in .env
   npm run dev
   ```

5. **Build and Run**
   - Open `splitsy.xcodeproj` in Xcode
   - Select your target device or simulator
   - Build and run the project (⌘+R)

## 📋 **Project Structure**

```
splitsy/
├── splitsy/                    # iOS App Source Code
│   ├── Views/                  # SwiftUI Views
│   │   ├── Authentication/     # Login, SignUp, Username Setup
│   │   ├── Main/              # Home, Profile, History
│   │   ├── SplitFlow/         # Receipt Input, Item Assignment
│   │   └── Components/        # Reusable UI Components
│   ├── Models/                # Data Models
│   ├── Services/              # Firebase, Authentication
│   └── Utils/                 # Helpers and Extensions
├── backend/                   # Node.js Feedback API
│   ├── server.js             # Express server
│   ├── package.json          # Dependencies
│   └── README.md             # Backend documentation
└── Documentation/            # Setup guides and documentation
```

## 🔧 **Configuration**

### **Firebase Services**
- **Authentication**: Google, Apple, Email/Password
- **Firestore**: User data, split history, receipts
- **Storage**: Profile pictures, receipt images
- **Analytics**: User behavior tracking

### **Environment Variables**
```bash
# Backend (.env)
SENDGRID_API_KEY=your_sendgrid_api_key
NODE_ENV=production
PORT=8080
```

## 🧪 **Testing**

```bash
# Run iOS tests
xcodebuild test -scheme splitsy -destination 'platform=iOS Simulator,name=iPhone 15'

# Run backend tests
cd backend
npm test
```

## 📦 **Dependencies**

### **iOS App**
- Firebase/Auth
- Firebase/Firestore
- Firebase/Storage
- GoogleSignIn
- AuthenticationServices (Apple Sign-In)

### **Backend**
- Express.js
- @sendgrid/mail
- CORS
- dotenv

## 🚀 **Deployment**

### **iOS App Store**
1. Configure App Store Connect
2. Set up certificates and provisioning profiles
3. Archive and upload to App Store Connect
4. Submit for review

### **Backend (Railway)**
1. Connect GitHub repository to Railway
2. Set environment variables
3. Deploy automatically on push

## 📄 **License**

This project is proprietary software. All rights reserved. See the [LICENSE](LICENSE) file for details.

## 👥 **Team**

- **Brian Kim** - Lead Developer & Designer

## 📞 **Support**

- **Email**: splitsy.contact@gmail.com

## 🎯 **Future Updates**

- [ ] Split templates and favorites
- [ ] Interactive social features
- [ ] Payment integration (Venmo, PayPal)
- [ ] Receipt categorization and expense tracking
- [ ] Multi-platform support (Android, Web)

## 🙏 **Acknowledgments**

- Apple Vision Framework for OCR capabilities
- Firebase for backend infrastructure
- SwiftUI community for inspiration and support
- Beta testers for valuable feedback

---

**Made with ❤️ for easier bill splitting**

*Splitsy - Because math shouldn't ruin your dinner plans*
