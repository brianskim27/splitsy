# 🧾 Splitsy

**Split bills effortlessly with AI-powered receipt scanning**

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
- **Flexible Currencies**: Change currency type on the go
- **Multiple Payment Methods**: Support for various splitting scenarios (coming soon)

### 🎨 **Modern UI/UX**
- **Clean, Intuitive Design**: Beautiful SwiftUI interface with smooth animations
- **Horizontal Item Wheels**: Easy-to-use scrollable item selection
- **Keyboard-Friendly**: Smart keyboard handling with tap-to-dismiss

### 🔐 **Secure Authentication**
- **Firebase Integration**: Robust user authentication and data storage
- **Google Sign-In**: One-tap login with Google accounts
- **Apple Sign-In**: Secure authentication with Apple ID (coming soon)
- **Email Verification**: Complete account setup with username creation

### 📊 **Comprehensive History**
- **Split History**: View all your previous bill splits
- **Detailed Statistics**: Track spending patterns and split frequency
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

*Coming soon - App Store screenshots will be added here*

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

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 **Team**

- **Brian** - Lead Developer & Designer
- **AI Assistant** - Development Support

## 📞 **Support**

- **Email**: splitsy.contact@gmail.com
- **Issues**: [GitHub Issues](https://github.com/yourusername/splitsy/issues)
- **Documentation**: [Wiki](https://github.com/yourusername/splitsy/wiki)

## 🎯 **Roadmap**

- [ ] **v1.1**: Split templates and favorites
- [ ] **v1.2**: Group management and recurring splits
- [ ] **v1.3**: Payment integration (Venmo, PayPal)
- [ ] **v1.4**: Receipt categorization and expense tracking
- [ ] **v2.0**: Multi-platform support (Android, Web)

## 🙏 **Acknowledgments**

- Apple Vision Framework for OCR capabilities
- Firebase for backend infrastructure
- SwiftUI community for inspiration and support
- Beta testers for valuable feedback

---

**Made with ❤️ for easier bill splitting**

*Splitsy - Because math shouldn't ruin your dinner plans*
