from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os
from typing import List, Dict, Optional
import anthropic
import uvicorn

# Initialize FastAPI
app = FastAPI(title="Heart Disease Prediction API")

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Add OPTIONS method handler for preflight requests
@app.options("/{rest_of_path:path}")
async def preflight_handler(request: Request, rest_of_path: str) -> Response:
    response = Response()
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, GET, DELETE, PUT, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "*"
    return response

# Add CORS headers to all responses
@app.middleware("http")
async def add_cors_header(request: Request, call_next):
    response = await call_next(request)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, GET, DELETE, PUT, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "*"
    return response

# Initialize model and scaler
model = None
scaler = None

# Load model and scaler
try:
    # Use os.path for cross-platform path handling
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(base_dir, 'models', 'final_best_model.pkl')
    scaler_path = os.path.join(base_dir, 'models', 'feature_scaler.pkl')
    
    if not os.path.exists(model_path) or not os.path.exists(scaler_path):
        raise FileNotFoundError("Model or scaler file not found. Please check the file paths.")
        
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    print("✅ Model and scaler loaded successfully")
except Exception as e:
    print(f"❌ Error loading model: {e}")
    model = None
    scaler = None

# Load feature importance
try:
    feature_importance = pd.read_csv('E:\Desktop\Jobs\projects\Heart Disease\backend\models\final_heart_dataset.csv')
    print("✅ Feature data loaded")
except:
    feature_importance = None

# Claude API client
CLAUDE_API_KEY = "REPLACED_WITH_ENV_VAR"
claude_client = anthropic.Anthropic(api_key=CLAUDE_API_KEY)

# Request/Response Models
class HealthData(BaseModel):
    age: int
    sex: str
    bmi: float
    smoking: str
    physical_activity: str
    alcohol: str
    general_health: str
    sleep_hours: int
    diabetes: str
    
class PredictionResponse(BaseModel):
    risk_percentage: float
    risk_level: str
    top_risk_factors: List[Dict[str, str]]
    recommendations: List[str]

class ChatRequest(BaseModel):
    message: str
    user_data: Dict = None

class ChatResponse(BaseModel):
    response: str

# Root endpoint
@app.get("/")
def root():
    return {
        "message": "Heart Disease Prediction API",
        "status": "running",
        "model_loaded": model is not None,
        "endpoints": {
            "predict": "/predict",
            "chat": "/chat",
            "health": "/health"
        }
    }

# Health check
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "scaler_loaded": scaler is not None
    }

# Prediction endpoint
@app.post("/predict", response_model=PredictionResponse)
async def predict(data: HealthData):
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail="Model or scaler not loaded. Please check the server logs.")
        
    try:
        # Prepare input data (simplified - you'll need to match your model's exact features)
        input_dict = {
            'Age': data.age,
            'Sex': 1 if data.sex.lower() == 'male' else 0,
            'BMI': data.bmi,
            'Smoking': 1 if data.smoking.lower() == 'yes' else 0,
            'PhysicalActivity': 1 if data.physical_activity.lower() == 'yes' else 0,
            'AlcoholDrinking': 1 if data.alcohol.lower() == 'yes' else 0,
            'SleepHours': data.sleep_hours,
            'Diabetic': 1 if data.diabetes.lower() == 'yes' else 0,
        }
        
        # Create a feature vector with 277 zeros
        feature_vector = np.zeros(277)
        
        # Map the input features to their correct positions in the feature vector
        # These indices should match your model's training data
        feature_mapping = {
            'Age': 0,
            'Sex': 1,
            'BMI': 2,
            'Smoking': 3,
            'PhysicalActivity': 4,
            'AlcoholDrinking': 5,
            'SleepHours': 6,
            'Diabetic': 7
        }
        
        # Set the values for the features we have
        for feature, value in input_dict.items():
            if feature in feature_mapping:
                feature_vector[feature_mapping[feature]] = value
        
        # Scale and predict
        # scaled_features = scaler.transform([feature_vector])
        probability = model.predict_proba([feature_vector])[0][1]
        risk_percentage = float(probability * 100)
        
        # Determine risk level
        if risk_percentage < 30:
            risk_level = "Low Risk"
        elif risk_percentage < 60:
            risk_level = "Medium Risk"
        else:
            risk_level = "High Risk"
        
        # Identify top risk factors
        top_factors = []
        if data.smoking.lower() == 'yes':
            top_factors.append({"factor": "Smoking", "impact": "High"})
        if data.bmi > 30:
            top_factors.append({"factor": "High BMI", "impact": "High"})
        if data.physical_activity.lower() == 'no':
            top_factors.append({"factor": "Low Physical Activity", "impact": "Medium"})
        if data.sleep_hours < 6 or data.sleep_hours > 9:
            top_factors.append({"factor": "Poor Sleep", "impact": "Medium"})
        if data.diabetes.lower() == 'yes':
            top_factors.append({"factor": "Diabetes", "impact": "High"})
        
        # Generate recommendations
        recommendations = []
        if data.smoking.lower() == 'yes':
            recommendations.append("🚭 Quit smoking - reduces CVD risk by 50%")
        if data.bmi > 30:
            recommendations.append("🏃 Maintain healthy weight (BMI 18.5-25)")
        if data.physical_activity.lower() == 'no':
            recommendations.append("💪 Exercise 30 mins daily, 5 days/week")
        if data.sleep_hours < 7:
            recommendations.append("😴 Get 7-8 hours of quality sleep")
        if data.general_health in ['Fair', 'Poor']:
            recommendations.append("🏥 Regular health checkups recommended")
        
        if not recommendations:
            recommendations.append("✅ Keep maintaining healthy lifestyle!")
        
        return PredictionResponse(
            risk_percentage=round(risk_percentage, 2),
            risk_level=risk_level,
            top_risk_factors=top_factors[:3],
            recommendations=recommendations
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

# Chat endpoint with Claude
@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        # Build context from user data if available
        context = "You are a helpful health assistant for a heart disease prediction app. "
        context += "Provide supportive, accurate medical information. "
        context += "Always recommend consulting healthcare professionals for medical decisions.\n\n"
        
        if request.user_data:
            context += f"User's health data:\n"
            for key, value in request.user_data.items():
                context += f"- {key}: {value}\n"
        
        # Call Claude API
        message = claude_client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=500,
            messages=[
                {
                    "role": "user",
                    "content": f"{context}\n\nUser question: {request.message}"
                }
            ]
        )
        
        response_text = message.content[0].text
        
        return ChatResponse(response=response_text)
        
    except Exception as e:
        # Fallback response if Claude API fails
        return ChatResponse(
            response=f"I'm here to help! However, I'm having trouble connecting right now. "
                    f"Please try again or consult with a healthcare professional for medical advice."
        )

# Run server
if __name__ == "__main__":
    print("="*60)
    print("🏥 Heart Disease Prediction API")
    print("="*60)
    print("Starting server on http://localhost:8000")
    print("API Docs: http://localhost:8000/docs")
    print("="*60)
    
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)