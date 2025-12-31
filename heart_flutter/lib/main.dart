import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(HeartDiseaseApp());
}

class HeartDiseaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Disease Predictor',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    InputScreen(),
    AboutScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Check Risk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI Assistant',
          ),
        ],
      ),
    );
  }
}

// INPUT SCREEN
class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int age = 50;
  String sex = 'Male';
  double bmi = 25.0;
  String smoking = 'No';
  String physicalActivity = 'Yes';
  String alcohol = 'No';
  String generalHealth = 'Good';
  int sleepHours = 7;
  String diabetes = 'No';
  
  bool isLoading = false;

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'age': age,
          'sex': sex,
          'bmi': bmi,
          'smoking': smoking,
          'physical_activity': physicalActivity,
          'alcohol': alcohol,
          'general_health': generalHealth,
          'sleep_hours': sleepHours,
          'diabetes': diabetes,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          ),
        );
      } else {
        _showError('Failed to get prediction');
      }
    } catch (e) {
      _showError('Connection error. Make sure backend is running on http://localhost:8000');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Disease Risk Assessment'),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age: $age years', style: TextStyle(fontSize: 16)),
                    Slider(
                      value: age.toDouble(),
                      min: 18,
                      max: 100,
                      divisions: 82,
                      onChanged: (val) => setState(() => age = val.toInt()),
                    ),
                    SizedBox(height: 16),

                    Text('Sex', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Male'),
                            value: 'Male',
                            groupValue: sex,
                            onChanged: (val) => setState(() => sex = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Female'),
                            value: 'Female',
                            groupValue: sex,
                            onChanged: (val) => setState(() => sex = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Text('BMI: ${bmi.toStringAsFixed(1)}', style: TextStyle(fontSize: 16)),
                    Slider(
                      value: bmi,
                      min: 15,
                      max: 50,
                      divisions: 350,
                      onChanged: (val) => setState(() => bmi = val),
                    ),
                    SizedBox(height: 16),

                    _buildDropdown('Do you smoke?', smoking, ['Yes', 'No'],
                        (val) => setState(() => smoking = val!)),

                    _buildDropdown('Physical activity in past 30 days?',
                        physicalActivity, ['Yes', 'No'],
                        (val) => setState(() => physicalActivity = val!)),

                    _buildDropdown('Heavy alcohol consumption?', alcohol,
                        ['Yes', 'No'], (val) => setState(() => alcohol = val!)),

                    _buildDropdown(
                        'General Health',
                        generalHealth,
                        ['Excellent', 'Very good', 'Good', 'Fair', 'Poor'],
                        (val) => setState(() => generalHealth = val!)),

                    Text('Sleep Hours: $sleepHours hours',
                        style: TextStyle(fontSize: 16)),
                    Slider(
                      value: sleepHours.toDouble(),
                      min: 3,
                      max: 12,
                      divisions: 9,
                      onChanged: (val) =>
                          setState(() => sleepHours = val.toInt()),
                    ),
                    SizedBox(height: 16),

                    _buildDropdown('Do you have diabetes?', diabetes,
                        ['Yes', 'No', 'Borderline'],
                        (val) => setState(() => diabetes = val!)),

                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Check My Risk',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// RESULT SCREEN
class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  ResultScreen({required this.result});

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('Low')) return Colors.green;
    if (riskLevel.contains('Medium')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final riskPercentage = result['risk_percentage'];
    final riskLevel = result['risk_level'];
    final topFactors = result['top_risk_factors'] as List;
    final recommendations = result['recommendations'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Results'),
        backgroundColor: _getRiskColor(riskLevel),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Your CVD Risk',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: CircularProgressIndicator(
                            value: riskPercentage / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                                _getRiskColor(riskLevel)),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${riskPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              riskLevel,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: _getRiskColor(riskLevel),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            if (topFactors.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Main Risk Factors',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      ...topFactors.map((factor) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.warning,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${factor['factor']} (${factor['impact']} Impact)',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendations',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    ...recommendations.map((rec) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(rec.toString(),
                                    style: TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text('Check Again', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ABOUT SCREEN
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.favorite, size: 80, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'Heart Disease Prediction App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildInfoCard(
              'About This App',
              'This app uses machine learning (Random Forest) to assess cardiovascular disease risk based on your health profile.',
            ),
            _buildInfoCard(
              'Model Performance',
              '• Accuracy: 90.73%\n• ROC-AUC: 87.87%\n• Trained on 387,000+ patient records',
            ),
            _buildInfoCard(
              'Disclaimer',
              'This app is for educational purposes only. Always consult healthcare professionals for medical decisions.',
            ),
            _buildInfoCard(
              'Features',
              '• AI-powered risk prediction\n• Personalized recommendations\n• AI health assistant chat\n• Explainable results',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(content, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// CHAT SCREEN
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _messages.add({'role': 'assistant', 'content': result['response']});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I\'m having trouble connecting. Make sure backend is running!'
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Health Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Ask me about heart health!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7),
                          child: Text(
                            message['content']!,
                            style: TextStyle(
                                color: isUser ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about heart health...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}