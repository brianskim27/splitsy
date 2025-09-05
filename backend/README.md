# Splitsy Feedback API

Backend API for automatically sending feedback emails from the Splitsy iOS app.

## Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Email
1. Create a Gmail app-specific password for `splitsy.contact@gmail.com`
2. Copy `env.example` to `.env`
3. Update the `.env` file with your email credentials:
```
EMAIL_USER=splitsy.contact@gmail.com
EMAIL_PASS=your_app_specific_password_here
```

### 3. Run the Server
```bash
# Development
npm run dev

# Production
npm start
```

## Deployment Options

### Option 1: Heroku (Recommended)
1. Create a Heroku app
2. Set environment variables in Heroku dashboard
3. Deploy with Git:
```bash
git init
git add .
git commit -m "Initial commit"
heroku git:remote -a your-app-name
git push heroku main
```

### Option 2: Railway
1. Connect your GitHub repository
2. Set environment variables
3. Deploy automatically

### Option 3: Vercel
1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in the project directory
3. Set environment variables in Vercel dashboard

## API Endpoints

### POST /api/feedback
Receives feedback data from iOS app and sends email automatically.

**Request Body:**
```json
{
  "feedbackType": "Bug Report",
  "priority": "High",
  "description": "App crashes when...",
  "deviceInfo": "iPhone 15 Pro, iOS 17.2",
  "userJourney": "Receipt Analysis",
  "frequency": "Every time",
  "impact": "Prevents me from using the app",
  "contactEmail": "user@example.com",
  "additionalComments": "Additional info...",
  "attachedImages": ["base64_image_data"]
}
```

### GET /api/health
Health check endpoint.

## iOS App Configuration

Update the API URL in `FeedbackView.swift`:
```swift
guard let url = URL(string: "https://your-deployed-api.com/api/feedback") else {
    throw NetworkError.invalidURL
}
```

## Security Notes

- Use app-specific passwords for Gmail
- Consider adding API authentication for production
- Implement rate limiting to prevent spam
- Use HTTPS in production
