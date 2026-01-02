# HeartAI - Quick Start Guide

## 🚀 Setup Instructions

### Step 1: Start the Backend Server

1. Open a terminal in the project root directory
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Start the backend server:
   ```bash
   python backend_server.py
   ```
4. You should see: `Server running on http://localhost:8000`

### Step 2: Run the Flutter App

1. Open a new terminal
2. Navigate to the Flutter app:
   ```bash
   cd heart_flutter
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## ✅ Security Benefits

- ✅ **API Key is Secure**: The Claude API key is stored on the backend server, not in your Flutter app
- ✅ **No Key Exposure**: Users cannot extract the API key from your app
- ✅ **Better Control**: You can add rate limiting, authentication, and logging on the backend

## 🔧 Troubleshooting

### Backend won't start
- Make sure Python 3.7+ is installed
- Check that all dependencies are installed: `pip install -r requirements.txt`
- Verify port 8000 is not already in use

### Flutter app can't connect
- Make sure the backend server is running
- Check that the backend URL in `main.dart` matches: `http://localhost:8000`
- For Android emulator, use `http://10.0.2.2:8000` instead of `localhost`
- For iOS simulator, `localhost` should work fine

### API errors
- Check the backend console for error messages
- Verify the API key in `.env` file is correct
- Make sure you have internet connection

## 📝 Notes

- The backend server must be running for the app to work
- Keep the backend server terminal open while using the app
- For production, deploy the backend to a cloud service (Heroku, AWS, etc.)

