from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import json
import pandas as pd
import numpy as np
import os
from typing import List, Dict, Optional
import anthropic
import uvicorn
import re

# Initialize FastAPI
app = FastAPI(title="Heart Disease Prediction API")

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(base_dir, 'models', 'final_best_model.pkl')
    scaler_path = os.path.join(base_dir, 'models', 'feature_scaler.pkl')
    
    if not os.path.exists(model_path) or not os.path.exists(scaler_path):
        raise FileNotFoundError("Model or scaler file not found.")
        
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    
    print(f"\n[DEBUG] ========== MODEL INFO ==========")
    print(f"[DEBUG] Model loaded: {type(model)}")
    if hasattr(model, 'classes_'):
        print(f"[DEBUG] Model classes: {model.classes_}")
    if hasattr(model, 'n_features_in_'):
        print(f"[DEBUG] Model expects {model.n_features_in_} features")
    
    print(f"[DEBUG] Scaler type: {type(scaler)}")
    print(f"[DEBUG] ================================\n")
    
    print("[OK] Model and scaler loaded successfully")
except Exception as e:
    print(f"[WARNING] Error loading model: {e}")
    print("[INFO] Will use Claude AI for predictions")
    model = None
    scaler = None

# Load feature importance
try:
    feature_csv_path = os.path.join(base_dir, 'models', 'final_heart_dataset.csv')
    feature_importance = pd.read_csv(feature_csv_path)
    print("[OK] Feature data loaded")
except Exception as e:
    print(f"[WARNING] Could not load feature data: {e}")
    feature_importance = None

# Claude API client
CLAUDE_API_KEY = os.getenv("CLAUDE_API_KEY", "")

claude_client = None
claude_available = False

if CLAUDE_API_KEY:
    try:
        claude_client = anthropic.Anthropic(api_key=CLAUDE_API_KEY)
        # Test with a simple, cheap call
        try:
            # Try a minimal test to avoid billing issues
            test_message = claude_client.messages.create(
                model="claude-3-haiku-20240307",
                max_tokens=5,
                messages=[{"role": "user", "content": "Hello"}]
            )
            claude_available = True
            print("[OK] Claude API client initialized and working")
        except Exception as test_error:
            print(f"[WARNING] Claude API test failed (likely billing issue): {test_error}")
            print("[INFO] Claude features will use fallback responses")
            claude_available = False
    except Exception as e:
        print(f"[ERROR] Could not initialize Claude client: {e}")
        claude_available = False
else:
    print("[INFO] Claude API key not configured")
    claude_available = False

print(f"[INFO] Claude available: {claude_available}")

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
        "claude_available": claude_available,
        "endpoints": {
            "health": "/health",
            "analyze": "/analyze",
            "predict": "/predict",
            "chat": "/chat",
            "plan": "/plan"
        }
    }

# Health check
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "scaler_loaded": scaler is not None,
        "claude_available": claude_available
    }

# Claude AI prediction fallback
async def predict_with_claude(data: HealthData) -> PredictionResponse:
    """Use Claude AI for prediction when ML model unavailable"""
    if not claude_available:
        # Return default prediction if Claude not available
        return PredictionResponse(
            risk_percentage=25.0,
            risk_level="Low Risk",
            top_risk_factors=[{"factor": "No major risks identified", "impact": "Low"}],
            recommendations=["Maintain healthy lifestyle", "Regular exercise", "Balanced diet"]
        )
    
    try:
        prompt = f"""Analyze this health profile and return ONLY valid JSON:

Age: {data.age} years
Gender: {data.sex}
BMI: {data.bmi}
Smoking: {data.smoking}
Physical Activity: {data.physical_activity}
Alcohol: {data.alcohol}
General Health: {data.general_health}
Sleep: {data.sleep_hours} hours
Diabetes: {data.diabetes}

Return JSON with risk_percentage, risk_level, top_risk_factors, recommendations"""

        message = claude_client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=500,
            messages=[{"role": "user", "content": prompt}]
        )
        
        response_text = message.content[0].text
        json_match = re.search(r'\{[\s\S]*\}', response_text)
        
        if json_match:
            result = json.loads(json_match.group())
            return PredictionResponse(**result)
        else:
            return PredictionResponse(
                risk_percentage=25.0,
                risk_level="Low Risk",
                top_risk_factors=[{"factor": "No major risks identified", "impact": "Low"}],
                recommendations=["Maintain healthy lifestyle", "Regular exercise", "Balanced diet"]
            )
            
    except Exception as e:
        print(f"[PREDICT] Claude error: {e}")
        return PredictionResponse(
            risk_percentage=25.0,
            risk_level="Low Risk",
            top_risk_factors=[{"factor": "No major risks identified", "impact": "Low"}],
            recommendations=["Maintain healthy lifestyle", "Regular exercise", "Balanced diet"]
        )

# Prediction function (used by /analyze)
async def predict(data: HealthData) -> PredictionResponse:
    """Core prediction logic"""
    
    # If model exists, use ML model
    if model is not None and scaler is not None:
        try:
            # Prepare input data
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
            
            # Create feature vector
            feature_vector = np.zeros(277)
            feature_mapping = {
                'Age': 0, 'Sex': 1, 'BMI': 2, 'Smoking': 3,
                'PhysicalActivity': 4, 'AlcoholDrinking': 5,
                'SleepHours': 6, 'Diabetic': 7
            }
            
            for feature, value in input_dict.items():
                if feature in feature_mapping:
                    idx = feature_mapping[feature]
                    feature_vector[idx] = value
            
            # Apply scaling
            if scaler is not None:
                try:
                    feature_vector_scaled = scaler.transform([feature_vector])
                    feature_vector = feature_vector_scaled[0]
                except Exception:
                    pass
            
            # Predict using ML model
            probability = model.predict_proba([feature_vector])[0]
            
            if len(probability) > 1:
                risk_percentage = float(probability[1] * 100)
            else:
                risk_percentage = float(probability[0] * 100)
            
        except Exception as e:
            print(f"[PREDICT] ML Model error: {e}, falling back")
            return await predict_with_claude(data)
    
    else:
        return await predict_with_claude(data)
    
    # Determine risk level
    if risk_percentage < 20:
        risk_level = "Low Risk"
    elif risk_percentage < 40:
        risk_level = "Moderate Risk"
    elif risk_percentage < 60:
        risk_level = "Medium-High Risk"
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
        recommendations.append("Quit smoking - reduces CVD risk by 50% within 1 year")
    elif data.smoking.lower() == 'no':
        recommendations.append("Great job not smoking! Continue avoiding tobacco products")
    
    if data.bmi >= 25:
        if data.bmi > 30:
            recommendations.append(f"High BMI ({data.bmi}): Aim to lose weight through diet and exercise")
        else:
            recommendations.append(f"BMI {data.bmi}: Maintain healthy weight with balanced diet")
    
    if data.physical_activity.lower() == 'no':
        recommendations.append("Start with 30 minutes of moderate exercise 5 days/week")
    elif data.physical_activity.lower() == 'yes':
        recommendations.append("Keep up the good work with regular physical activity")
    
    if data.sleep_hours < 7:
        recommendations.append(f"Only {data.sleep_hours} hours sleep: Aim for 7-8 hours for heart health")
    elif data.sleep_hours > 9:
        recommendations.append(f"Excessive sleep ({data.sleep_hours} hours): 7-8 hours is optimal")
    else:
        recommendations.append(f"Good sleep duration: {data.sleep_hours} hours")
    
    if data.diabetes.lower() == 'yes':
        recommendations.append("Manage diabetes carefully with regular checkups")
    elif data.diabetes.lower() == 'no':
        recommendations.append("No diabetes - excellent for heart health")
    
    if data.general_health in ['Fair', 'Poor']:
        recommendations.append("Consider regular health screenings and checkups")
    elif data.general_health in ['Good', 'Very Good', 'Excellent']:
        recommendations.append(f"Good self-reported health ({data.general_health}) - keep it up!")
    
    if data.alcohol.lower() == 'yes':
        recommendations.append("Limit alcohol to 1-2 drinks per day for heart health")
    elif data.alcohol.lower() == 'no':
        recommendations.append("No alcohol consumption - good for overall health")
    
    if data.age > 45:
        recommendations.append(f"At age {data.age}, regular heart health screenings are recommended")
    else:
        recommendations.append(f"At age {data.age}, focus on prevention through healthy lifestyle")
    
    if not recommendations:
        recommendations.append("Keep maintaining healthy lifestyle!")
    
    return PredictionResponse(
        risk_percentage=round(risk_percentage, 2),
        risk_level=risk_level,
        top_risk_factors=top_factors[:3],
        recommendations=recommendations[:5]
    )

# /analyze endpoint
@app.post("/analyze")
async def analyze_health(request: Request):
    """Analyze endpoint - receives health_data wrapper"""
    try:
        body_bytes = await request.body()
        if not body_bytes:
            raise HTTPException(status_code=400, detail="Request body is empty")
        
        body = await request.json()
        
        if 'health_data' not in body:
            raise HTTPException(status_code=400, detail="Missing 'health_data' field")
        
        health_data = body.get('health_data', {})
        
        data = HealthData(
            age=health_data.get('age', 50),
            sex=health_data.get('sex', 'Male'),
            bmi=health_data.get('bmi', 25.0),
            smoking=health_data.get('smoking', 'No'),
            physical_activity=health_data.get('physical_activity', 'Yes'),
            alcohol=health_data.get('alcohol', 'No'),
            general_health=health_data.get('general_health', 'Good'),
            sleep_hours=health_data.get('sleep_hours', 7),
            diabetes=health_data.get('diabetes', 'No')
        )
        
        result = await predict(data)
        
        return {
            "risk_percentage": result.risk_percentage,
            "risk_level": result.risk_level,
            "top_risk_factors": result.top_risk_factors,
            "recommendations": result.recommendations
        }
        
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON")
    except Exception as e:
        print(f"[ANALYZE] Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Direct predict endpoint
@app.post("/predict")
async def predict_direct(data: HealthData):
    result = await predict(data)
    return {
        "risk_percentage": result.risk_percentage,
        "risk_level": result.risk_level,
        "top_risk_factors": result.top_risk_factors,
        "recommendations": result.recommendations
    }

# Chat endpoint
@app.post("/chat")
async def chat(request: Request):
    """Chat endpoint - receives message and optional user_data"""
    try:
        body = await request.json()
        
        message = body.get('message', '').strip().lower()
        user_data = body.get('user_data')
        
        if not claude_available:
            # More contextual fallback responses
            if "analysis" in message or "report" in message or "wrong" in message:
                return {"response": "I'd love to analyze your health data! For personalized insights, please upload your health profile or share key metrics like blood pressure, cholesterol levels, and activity habits."}
            
            fallback_responses = [
                "I'm Dr. HeartAI! For personalized advice, please share your health data or ask specific questions.",
                "A heart-healthy lifestyle includes balanced nutrition, regular exercise, stress management, and quality sleep.",
                "For specific medical advice, please consult with a healthcare professional.",
                "Your heart health is important! Would you like to discuss diet, exercise, or general heart health tips?",
                "I can help with diet plans, exercise routines, or analyzing health metrics. What would you like to focus on today?"
            ]
            
            # Choose a response that hasn't been used recently
            import random
            response = random.choice(fallback_responses)
            return {"response": response}
        
        # Use Claude if available
        system_prompt = """You are Dr. HeartAI, a professional AI health assistant specializing in cardiovascular health.

IMPORTANT RULES:
1. NEVER show internal system notes or technical details to the user
2. Always provide personalized, actionable advice when health data is available
3. If no health data is provided, ask relevant questions to gather information
4. Structure clear, organized responses with specific recommendations
5. Focus on heart health but maintain general wellness perspective
6. Use a supportive, encouraging tone
7. Never repeat the exact same response consecutively
8. If analysis is requested but data is limited, explain what insights CAN be provided

RESPONSE FORMAT GUIDELINES:
- Start with a brief acknowledgment
- Provide findings in bullet points when appropriate
- Include specific recommendations
- End with options for next steps or questions"""
        
        user_context = ""
        if user_data and isinstance(user_data, dict):
            user_context = "\nUSER HEALTH DATA:\n"
            for key, value in user_data.items():
                user_context += f"- {key}: {value}\n"
            
            # Add analysis-specific instructions if data exists
            if "analysis" in message or "report" in message or "wrong" in message:
                user_context += "\nANALYSIS REQUESTED: Provide detailed findings and actionable recommendations based on the above data. Identify potential areas for improvement."
        
        # Track conversation context (in a real app, use session or database)
        # For now, we'll pass recent messages as context
        conversation_context = ""
        
        # Check for repetitive queries
        message_lower = message.lower()
        if message_lower in ["hello", "hi", "hey"]:
            conversation_context = "User is greeting. Provide warm welcome and ask how you can help."
        elif "analysis" in message_lower or "report" in message_lower:
            conversation_context = "User wants health analysis. Be specific and data-driven."
        elif "diet" in message_lower or "food" in message_lower:
            conversation_context = "User asking about nutrition. Focus on heart-healthy eating."
        elif "exercise" in message_lower or "workout" in message_lower:
            conversation_context = "User asking about physical activity. Focus on cardiovascular benefits."
        elif "same" in message_lower or "again" in message_lower or "repeat" in message_lower:
            conversation_context = "User seems to be asking for repeated information. Provide variation or ask for clarification."
        
        prompt = f"""{system_prompt}

{user_context}

{conversation_context}

USER MESSAGE: {message}

YOUR RESPONSE:"""
        
        claude_message = claude_client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=600,
            temperature=0.7,  # Add some variation
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )
        
        response_text = claude_message.content[0].text
        
        # Clean up response (remove any accidental internal notes)
        if "##" in response_text and "Internal" in response_text:
            # Remove markdown internal notes if they appear
            lines = response_text.split('\n')
            cleaned_lines = []
            in_internal_section = False
            
            for line in lines:
                if "##" in line and "Internal" in line:
                    in_internal_section = True
                    continue
                elif "##" in line and in_internal_section:
                    in_internal_section = False
                    continue
                elif not in_internal_section:
                    cleaned_lines.append(line)
            
            response_text = '\n'.join(cleaned_lines).strip()
        
        # Ensure response isn't empty
        if not response_text or response_text.isspace():
            response_text = "I'd be happy to help! Could you tell me more about what you'd like to know about your heart health?"
        
        return {"response": response_text}
        
    except Exception as e:
        print(f"[CHAT] Error: {e}")
        # More helpful error response
        return {"response": "I'm here to help with your heart health! If you're asking for a health analysis, please share your health metrics. Otherwise, feel free to ask any heart health questions."}

# ========== PLAN FUNCTIONS ==========

async def get_diet_plan(data: HealthData):
    """Generate personalized diet plan"""
    print(f"[DIET-PLAN] Generating for age={data.age}, sex={data.sex}")
    
    if not claude_available:
        # Simple fallback diet plan
        simple_plan = f"""Personalized Heart-Healthy Diet Plan for {data.age}-year-old {data.sex}:

DAILY MEAL PLAN:
• Breakfast: Oatmeal with berries OR Greek yogurt with banana
• Lunch: Grilled chicken salad OR lentil soup with whole grain bread
• Dinner: Baked salmon with vegetables OR stir-fried tofu with brown rice
• Snacks: Apple with almond butter, carrot sticks with hummus

HEART-HEALTHY TIPS:
1. Eat more fruits and vegetables (5+ servings daily)
2. Choose whole grains over refined grains
3. Include healthy fats (avocado, nuts, olive oil)
4. Limit processed foods and added sugars
5. Control portion sizes
6. Stay hydrated with water

FOODS TO FOCUS ON:
• Fruits, vegetables, whole grains
• Lean proteins (fish, poultry, beans)
• Healthy fats (nuts, seeds, olive oil)
• Low-fat dairy

FOODS TO LIMIT:
• Processed meats
• Sugary drinks and snacks
• High-sodium foods
• Trans fats (fried foods, baked goods)"""
        
        return {"diet_plan": simple_plan}
    
    try:
        prompt = f"""Create a simple heart-healthy diet plan for:
Age: {data.age}, Sex: {data.sex}, BMI: {data.bmi}
Focus on practical meal ideas."""
        
        message = claude_client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=600,
            messages=[{"role": "user", "content": prompt}]
        )
        
        return {"diet_plan": message.content[0].text}
    except Exception as e:
        print(f"[DIET-PLAN] Error: {e}")
        return {"diet_plan": "Basic heart-healthy diet: Focus on fruits, vegetables, whole grains, and lean proteins. Limit processed foods and added sugars."}

async def get_exercise_plan(data: HealthData):
    """Generate personalized exercise plan"""
    print(f"[EXERCISE-PLAN] Generating for age={data.age}, activity={data.physical_activity}")
    
    if not claude_available:
        # Simple fallback exercise plan
        simple_plan = f"""Personalized Exercise Plan for {data.age}-year-old {data.sex}:

WEEKLY SCHEDULE:
• Monday: 30 min brisk walking or cycling
• Tuesday: Strength training (bodyweight exercises)
• Wednesday: Rest or gentle stretching
• Thursday: 30 min swimming or elliptical
• Friday: Strength training
• Saturday: 45 min moderate activity (hiking, dancing)
• Sunday: Active rest (yoga or walking)

EXERCISE GUIDELINES:
1. Warm up: 5-10 min light cardio
2. Cool down: 5-10 min stretching
3. Target heart rate: {(220 - data.age) * 0.6:.0f}-{(220 - data.age) * 0.8:.0f} BPM
4. Stay hydrated before, during, after
5. Listen to your body - rest if needed

BEGINNER TIPS:
• Start with 10-15 min sessions
• Gradually increase duration and intensity
• Focus on consistency, not perfection
• Include rest days for recovery

SAFETY NOTES:
• Consult doctor before starting new exercise
• Stop if you feel pain or dizziness
• Use proper form to prevent injury
• Wear appropriate footwear"""
        
        return {"exercise_plan": simple_plan}
    
    try:
        prompt = f"""Create a simple exercise plan for:
Age: {data.age}, Current Activity: {data.physical_activity}
Focus on safe, practical exercises."""
        
        message = claude_client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=600,
            messages=[{"role": "user", "content": prompt}]
        )
        
        return {"exercise_plan": message.content[0].text}
    except Exception as e:
        print(f"[EXERCISE-PLAN] Error: {e}")
        return {"exercise_plan": "Basic exercise: Aim for 150 min moderate exercise per week. Include cardio, strength, and flexibility training."}

# Plan endpoint
@app.post("/plan")
async def get_plan_wrapper(request: Request):
    """Plan endpoint - receives plan_type and health_data"""
    try:
        body = await request.json()
        
        plan_type = body.get('plan_type', '').lower()
        health_data = body.get('health_data', {})
        
        if not plan_type:
            raise HTTPException(status_code=400, detail="Missing 'plan_type'. Use 'diet' or 'exercise'")
        
        # Convert to HealthData
        data = HealthData(
            age=health_data.get('age', 50),
            sex=health_data.get('sex', 'Male'),
            bmi=health_data.get('bmi', 25.0),
            smoking=health_data.get('smoking', 'No'),
            physical_activity=health_data.get('physical_activity', 'Yes'),
            alcohol=health_data.get('alcohol', 'No'),
            general_health=health_data.get('general_health', 'Good'),
            sleep_hours=health_data.get('sleep_hours', 7),
            diabetes=health_data.get('diabetes', 'No')
        )
        
        if plan_type == 'diet':
            result = await get_diet_plan(data)
            return {"plan": result.get('diet_plan', 'Diet plan available')}
        elif plan_type == 'exercise':
            result = await get_exercise_plan(data)
            return {"plan": result.get('exercise_plan', 'Exercise plan available')}
        else:
            raise HTTPException(status_code=400, detail="Use 'diet' or 'exercise' for plan_type")
            
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON")
    except Exception as e:
        print(f"[PLAN] Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Run server
if __name__ == "__main__":
    print("="*60)
    print("Heart Disease Prediction API")
    print("="*60)
    print("Starting server on http://localhost:8000")
    print("API Docs: http://localhost:8000/docs")
    print("="*60)
    
    uvicorn.run("backend_api:app", host="0.0.0.0", port=8000, reload=True)