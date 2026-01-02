# HeartAI Backend Server

This backend server securely handles Claude API calls, keeping your API key safe on the server side.

## Setup Instructions

### 1. Install Python Dependencies

```bash
pip install -r requirements.txt
```

Or if you prefer using a virtual environment:

```bash
python -m venv venv
venv\Scripts\activate  # On Windows
pip install -r requirements.txt
```

### 2. Configure API Key

The API key is stored in `.env` file. Make sure the file exists and contains:

```
CLAUDE_API_KEY=your_api_key_here
```

### 3. Run the Server

```bash
python backend_server.py
```

The server will start on `http://localhost:8000`

### 4. Test the Server

Open your browser and visit: `http://localhost:8000/health`

You should see: `{"status":"ok","message":"Backend server is running"}`

## API Endpoints

- `GET /health` - Health check
- `POST /analyze` - Analyze health data
- `POST /chat` - Chat with AI assistant
- `POST /plan` - Get diet or exercise plan

## Security Notes

- ✅ API key is stored on the server, not in the Flutter app
- ✅ CORS is enabled for Flutter app
- ⚠️ For production, use environment variables or a secrets manager
- ⚠️ Add authentication/rate limiting for production use

