"""
Backend server for HeartAI Flutter app
This server handles Claude API calls securely, keeping the API key on the server side.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Claude API Configuration
CLAUDE_API_KEY = os.getenv('CLAUDE_API_KEY', '')

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'message': 'Backend server is running'})

@app.route('/analyze', methods=['POST'])
def analyze_health():
    """Analyze health data and return risk assessment"""
    try:
        data = request.json
        health_data = data.get('health_data', {})
        
        prompt = f'''
You are Dr. HeartAI, a cardiovascular health expert. Analyze the following health profile and provide a comprehensive risk assessment:

Age: {health_data.get('age')}
Gender: {health_data.get('sex')}
BMI: {health_data.get('bmi')}
Smoking: {health_data.get('smoking')}
Physical Activity: {health_data.get('physical_activity')}
Alcohol Consumption: {health_data.get('alcohol')}
General Health: {health_data.get('general_health')}
Sleep Hours: {health_data.get('sleep_hours')}
Diabetes: {health_data.get('diabetes')}

Please provide a JSON response with the following structure:
{{
  "risk_percentage": <number between 0-100>,
  "risk_level": "<Low/Medium/High Risk>",
  "top_risk_factors": [
    {{"factor": "<factor name>", "impact": "<High/Medium/Low>"}}
  ],
  "recommendations": [
    "<recommendation 1>",
    "<recommendation 2>",
    "<recommendation 3>"
  ]
}}

Be professional, encouraging, and provide actionable advice. Return ONLY valid JSON, no additional text.
'''

        response = requests.post(
            CLAUDE_API_URL,
            headers={
                'Content-Type': 'application/json',
                'x-api-key': CLAUDE_API_KEY,
                'anthropic-version': '2023-06-01',
            },
            json={
                'model': 'claude-3-5-sonnet-20241022',
                'max_tokens': 2000,
                'messages': [
                    {
                        'role': 'user',
                        'content': prompt,
                    }
                ],
            },
            timeout=60
        )

        if response.status_code == 200:
            result = response.json()
            content = result['content'][0]['text']
            
            # Try to extract JSON from response
            import re
            json_match = re.search(r'\{[\s\S]*\}', content)
            if json_match:
                import json
                return jsonify(json.loads(json_match.group()))
            else:
                # Fallback response
                return jsonify({
                    'risk_percentage': 25.0,
                    'risk_level': 'Low Risk',
                    'top_risk_factors': [{'factor': 'BMI', 'impact': 'Medium'}],
                    'recommendations': content.split('\n')[:5]
                })
        else:
            return jsonify({
                'error': f'API returned status {response.status_code}',
                'details': response.text
            }), response.status_code

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/chat', methods=['POST'])
def chat():
    """Handle chat messages with Claude"""
    try:
        data = request.json
        message = data.get('message', '')
        user_data = data.get('user_data')
        
        context_info = ''
        if user_data:
            context_info = f'''
User Health Profile:
- Age: {user_data.get('age')}
- Gender: {user_data.get('sex')}
- BMI: {user_data.get('bmi')}
- Smoking: {user_data.get('smoking')}
- Physical Activity: {user_data.get('physical_activity')}
- Alcohol: {user_data.get('alcohol')}
- General Health: {user_data.get('general_health')}
- Sleep Hours: {user_data.get('sleep_hours')}
- Diabetes: {user_data.get('diabetes')}
'''
        
        prompt = f'''
You are Dr. HeartAI, a friendly and professional cardiovascular health assistant. {context_info if context_info else ''}

User Question: {message}

Provide a helpful, encouraging, and professional response about heart health, diet, exercise, or general cardiovascular wellness. Be conversational but informative.
'''

        response = requests.post(
            CLAUDE_API_URL,
            headers={
                'Content-Type': 'application/json',
                'x-api-key': CLAUDE_API_KEY,
                'anthropic-version': '2023-06-01',
            },
            json={
                'model': 'claude-3-5-sonnet-20241022',
                'max_tokens': 2000,
                'messages': [
                    {
                        'role': 'user',
                        'content': prompt,
                    }
                ],
            },
            timeout=60
        )

        if response.status_code == 200:
            result = response.json()
            return jsonify({'response': result['content'][0]['text']})
        else:
            return jsonify({
                'error': f'API returned status {response.status_code}',
                'details': response.text
            }), response.status_code

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/plan', methods=['POST'])
def get_plan():
    """Get diet or exercise plan"""
    try:
        data = request.json
        plan_type = data.get('plan_type')  # 'diet' or 'exercise'
        health_data = data.get('health_data', {})
        
        if plan_type == 'diet':
            prompt = f'''
Create a personalized heart-healthy diet plan for:
Age: {health_data.get('age')}, Gender: {health_data.get('sex')}, BMI: {health_data.get('bmi')}, 
Health Status: {health_data.get('general_health')}, Diabetes: {health_data.get('diabetes')}

Provide a comprehensive, actionable diet plan with meal suggestions, portion sizes, and nutritional guidance. Be encouraging and specific.
'''
        else:
            prompt = f'''
Create a personalized cardiovascular exercise plan for:
Age: {health_data.get('age')}, Gender: {health_data.get('sex')}, BMI: {health_data.get('bmi')}, 
Physical Activity: {health_data.get('physical_activity')}, General Health: {health_data.get('general_health')}

Provide a safe, progressive exercise routine with specific exercises, duration, frequency, and intensity. Be encouraging and specific.
'''

        response = requests.post(
            CLAUDE_API_URL,
            headers={
                'Content-Type': 'application/json',
                'x-api-key': CLAUDE_API_KEY,
                'anthropic-version': '2023-06-01',
            },
            json={
                'model': 'claude-3-5-sonnet-20241022',
                'max_tokens': 2000,
                'messages': [
                    {
                        'role': 'user',
                        'content': prompt,
                    }
                ],
            },
            timeout=60
        )

        if response.status_code == 200:
            result = response.json()
            plan_text = result['content'][0]['text']
            return jsonify({
                'plan': plan_text,
                'plan_type': plan_type
            })
        else:
            return jsonify({
                'error': f'API returned status {response.status_code}',
                'details': response.text
            }), response.status_code

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print('Starting HeartAI Backend Server...')
    print(f'Claude API Key configured: {CLAUDE_API_KEY[:20]}...')
    print('Server running on http://localhost:8000')
    print('Press CTRL+C to stop')
    app.run(host='127.0.0.1', port=5000, debug=True)

