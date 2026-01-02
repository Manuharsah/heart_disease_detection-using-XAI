import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

// Backend Server Configuration
// The API key is now stored securely on the backend server
const String backendUrl = 'http://localhost:8000';

void main() {
  runApp(HeartDiseaseApp());
}

class HeartDiseaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartAI - Cardiovascular Health',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF2196F3),
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF2196F3),
          primary: Color(0xFF2196F3),
          secondary: Color(0xFF00BCD4),
          tertiary: Color(0xFF4CAF50),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
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
  
  List<Widget> get _pages => [
    InputScreen(key: ValueKey('input')),
    AboutScreen(key: ValueKey('about')),
    ChatScreen(key: ValueKey('chat')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: Color(0xFF2196F3),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Risk Check',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'AI Assistant',
            ),
          ],
        ),
      ),
    );
  }
}

// ENHANCED INPUT SCREEN
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
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
  Map<String, dynamic>? lastHealthData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final healthData = {
        'age': age,
        'sex': sex,
        'bmi': bmi,
        'smoking': smoking,
        'physical_activity': physicalActivity,
        'alcohol': alcohol,
        'general_health': generalHealth,
        'sleep_hours': sleepHours,
        'diabetes': diabetes,
      };
      
      lastHealthData = healthData;

      // Use Claude API to analyze health data
      final result = await _analyzeWithClaude(healthData);

      if (!mounted) return;
      
      if (result != null) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
              result: result,
              healthData: healthData,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      } else {
        _showError('Failed to analyze health data. Please check your internet connection and try again.');
      }
    } on SocketException catch (e) {
      _showError('Cannot connect to backend server. Make sure the server is running on $backendUrl');
      debugPrint('Network error: $e');
    } on TimeoutException catch (e) {
      _showError('Request timed out. Please try again.');
      debugPrint('Timeout error: $e');
    } on http.ClientException catch (e) {
      _showError('Failed to connect to backend server. Make sure it\'s running on $backendUrl');
      debugPrint('Client error: $e');
    } catch (e) {
      _showError('Error: ${e.toString()}');
      debugPrint('Unexpected error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _analyzeWithClaude(Map<String, dynamic> healthData) async {
    try {
      debugPrint('Calling backend /analyze endpoint');
      
      final response = await http.post(
        Uri.parse('$backendUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'health_data': healthData,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );

      debugPrint('Backend Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else {
        debugPrint('Backend Error: Status ${response.statusCode}, Body: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Backend returned status ${response.statusCode}');
      }
    } on SocketException catch (e) {
      debugPrint('Backend SocketException: $e');
      debugPrint('Make sure the backend server is running on $backendUrl');
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('Backend Timeout: $e');
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('Backend ClientException: $e');
      debugPrint('Make sure the backend server is running on $backendUrl');
      rethrow;
    } catch (e) {
      debugPrint('Backend Unexpected Error: $e');
      rethrow;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Disease Risk Assessment'),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                          strokeWidth: 4,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'Analyzing your health profile...',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.white, size: 40),
                                    SizedBox(height: 12),
                                    Text(
                                      'Complete Your Health Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Get personalized cardiovascular risk assessment',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),

                    // Age Slider
                    _buildSectionCard(
                      'Age',
                      '${age} years',
                      Slider(
                        value: age.toDouble(),
                        min: 18,
                        max: 100,
                        divisions: 82,
                        activeColor: Color(0xFF2196F3),
                        onChanged: (val) => setState(() => age = val.toInt()),
                      ),
                    ),

                    // Sex Selection
                    _buildSectionCard(
                      'Gender',
                      null,
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              'Male',
                              sex == 'Male',
                              Icons.male,
                              () => setState(() => sex = 'Male'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildChoiceChip(
                              'Female',
                              sex == 'Female',
                              Icons.female,
                              () => setState(() => sex = 'Female'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BMI Slider
                    _buildSectionCard(
                      'BMI (Body Mass Index)',
                      '${bmi.toStringAsFixed(1)} ${_getBMICategory(bmi)}',
                      Slider(
                        value: bmi,
                        min: 15,
                        max: 50,
                        divisions: 350,
                        activeColor: Color(0xFF2196F3),
                        onChanged: (val) => setState(() => bmi = val),
                      ),
                    ),

                    // Health Questions
                    _buildDropdown('Do you smoke?', smoking, ['Yes', 'No'],
                        (val) => setState(() => smoking = val!), Icons.smoking_rooms),

                    _buildDropdown('Physical activity in past 30 days?',
                        physicalActivity, ['Yes', 'No'],
                        (val) => setState(() => physicalActivity = val!), Icons.fitness_center),

                    _buildDropdown('Heavy alcohol consumption?', alcohol,
                        ['Yes', 'No'], (val) => setState(() => alcohol = val!), Icons.wine_bar),

                    _buildDropdown(
                        'General Health',
                        generalHealth,
                        ['Excellent', 'Very good', 'Good', 'Fair', 'Poor'],
                        (val) => setState(() => generalHealth = val!), Icons.health_and_safety),

                    _buildSectionCard(
                      'Sleep Hours',
                      '$sleepHours hours per night',
                      Slider(
                        value: sleepHours.toDouble(),
                        min: 3,
                        max: 12,
                        divisions: 9,
                        activeColor: Color(0xFF2196F3),
                        onChanged: (val) =>
                            setState(() => sleepHours = val.toInt()),
                      ),
                    ),

                    _buildDropdown('Do you have diabetes?', diabetes,
                        ['Yes', 'No', 'Borderline'],
                        (val) => setState(() => diabetes = val!), Icons.bloodtype),

                    SizedBox(height: 24),

                    // Submit Button
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.95 + (0.05 * value),
                          child: Opacity(
                            opacity: value,
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : submitData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: Color(0xFF2196F3).withOpacity(0.4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.analytics_outlined),
                                    SizedBox(width: 12),
                                    Text(
                                      'Analyze My Risk',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return '(Underweight)';
    if (bmi < 25) return '(Normal)';
    if (bmi < 30) return '(Overweight)';
    return '(Obese)';
  }

  Widget _buildSectionCard(String title, String? subtitle, Widget child) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF2196F3).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xFF2196F3) : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Color(0xFF2196F3) : Colors.grey[600],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Color(0xFF2196F3) : Colors.grey[700],
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF2196F3), size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ENHANCED RESULT SCREEN
class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final Map<String, dynamic>? healthData;

  ResultScreen({required this.result, this.healthData});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('Low')) return Color(0xFF4CAF50);
    if (riskLevel.contains('Medium')) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    final riskPercentage = widget.result['risk_percentage'] as double;
    final riskLevel = widget.result['risk_level'] as String;
    final topFactors = widget.result['top_risk_factors'] as List;
    final recommendations = widget.result['recommendations'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Results'),
        backgroundColor: _getRiskColor(riskLevel),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Risk Score Card
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  color: _getRiskColor(riskLevel).withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Your Cardiovascular Risk',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 24),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: CircularProgressIndicator(
                                value: riskPercentage / 100,
                                strokeWidth: 16,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _getRiskColor(riskLevel)),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${riskPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: _getRiskColor(riskLevel),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getRiskColor(riskLevel),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    riskLevel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Diet Plan',
                    Icons.restaurant_menu,
                    Color(0xFF457B9D),
                    () => _getDietPlan(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Exercise Plan',
                    Icons.fitness_center,
                    Color(0xFF4CAF50),
                    () => _getExercisePlan(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Risk Factors
            ...(topFactors.isNotEmpty ? [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB703), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Main Risk Factors',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ...topFactors.map((factor) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFB703).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.info_outline,
                                      color: Color(0xFFFFB703), size: 20),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        factor['factor'] as String,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${factor['impact']} Impact',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ] : []),

            // Recommendations
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFF4CAF50), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Personalized Recommendations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ...recommendations.map((rec) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.check_circle,
                                    color: Color(0xFF4CAF50), size: 18),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  rec.toString(),
                                  style: TextStyle(fontSize: 15, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.refresh),
                    label: Text('Check Again'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Color(0xFF2196F3)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(initialHealthData: widget.healthData),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0.0, 0.1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.chat),
                    label: Text('Ask AI Assistant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getDietPlan(BuildContext context) async {
    if (widget.healthData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health data not available')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final dietPlan = await _getPlanFromClaude('diet', widget.healthData!);
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      if (dietPlan != null) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PlanScreen(
              title: 'Personalized Diet Plan',
              content: dietPlan,
              icon: Icons.restaurant_menu,
              color: Color(0xFF2196F3),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating diet plan')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _getExercisePlan(BuildContext context) async {
    if (widget.healthData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health data not available')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final exercisePlan = await _getPlanFromClaude('exercise', widget.healthData!);
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      if (exercisePlan != null) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PlanScreen(
              title: 'Personalized Exercise Plan',
              content: exercisePlan,
              icon: Icons.fitness_center,
              color: Color(0xFF4CAF50),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating exercise plan')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<String?> _getPlanFromClaude(String planType, Map<String, dynamic> healthData) async {
    try {
      debugPrint('Calling backend /plan endpoint for $planType');
      
      final response = await http.post(
        Uri.parse('$backendUrl/plan'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'plan_type': planType,
          'health_data': healthData,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );

      debugPrint('Plan Backend Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['plan'] as String;
      } else {
        final errorBody = response.body;
        debugPrint('Plan Backend Error: Status ${response.statusCode}');
        debugPrint('Plan Backend Error Body: $errorBody');
        
        final errorData = jsonDecode(errorBody);
        throw Exception(errorData['error'] ?? 'Backend returned status ${response.statusCode}');
      }
    } on SocketException catch (e) {
      debugPrint('Plan Backend SocketException: $e');
      debugPrint('Make sure the backend server is running on $backendUrl');
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('Plan Backend Timeout: $e');
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('Plan Backend ClientException: $e');
      debugPrint('Make sure the backend server is running on $backendUrl');
      rethrow;
    } catch (e) {
      debugPrint('Plan Backend Unexpected Error: $e');
      rethrow;
    }
  }
}

// Plan Display Screen
class PlanScreen extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  PlanScreen({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              content,
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ENHANCED ABOUT SCREEN
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About HeartAI')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.favorite, size: 60, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'HeartAI',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cardiovascular Health Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              Icons.psychology,
              'AI-Powered Analysis',
              'Advanced machine learning model (Random Forest) with 90.73% accuracy, trained on 387,000+ patient records.',
            ),
            _buildInfoCard(
              Icons.restaurant_menu,
              'Personalized Diet Plans',
              'Get customized meal plans tailored to your health profile, focusing on heart-healthy nutrition.',
            ),
            _buildInfoCard(
              Icons.fitness_center,
              'Exercise Recommendations',
              'Receive personalized workout routines designed to improve cardiovascular health based on your fitness level.',
            ),
            _buildInfoCard(
              Icons.chat_bubble_outline,
              'AI Health Assistant',
              '24/7 access to Dr. HeartAI for real-time health analysis, questions, and guidance.',
            ),
            _buildInfoCard(
              Icons.analytics,
              'Model Performance',
              '• Accuracy: 90.73%\n• ROC-AUC: 87.87%\n• Explainable AI with SHAP analysis',
            ),
            _buildInfoCard(
              Icons.warning_amber,
              'Important Disclaimer',
              'This app is for educational and informational purposes only. Always consult healthcare professionals for medical decisions and before starting any diet or exercise program.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(0xFF2196F3), size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ENHANCED CHAT SCREEN
class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? initialHealthData;

  const ChatScreen({super.key, this.initialHealthData});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    if (widget.initialHealthData != null) {
      _addWelcomeMessage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add({
      'role': 'assistant',
      'content': 'Hello! I\'m Dr. HeartAI, your personal cardiovascular health assistant. I have your health profile and I\'m ready to help you with:\n\n• Real-time health analysis\n• Personalized diet plans\n• Custom exercise routines\n• Heart health questions\n\nHow can I assist you today?',
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      debugPrint('Chat: Calling backend /chat endpoint');
      
      final response = await http.post(
        Uri.parse('$backendUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'user_data': widget.initialHealthData,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );

      debugPrint('Chat Backend Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Chat Backend Error Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['response'] as String;
        if (mounted) {
          setState(() {
            _messages.add({'role': 'assistant', 'content': assistantMessage});
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('Chat Backend Error: Status ${response.statusCode}, Body: ${response.body}');
        if (mounted) {
          _addErrorMessage(errorData['error'] ?? 'Failed to get response. Status: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      if (mounted) {
        _addErrorMessage('Cannot connect to backend server. Make sure the server is running on $backendUrl');
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      if (mounted) {
        _addErrorMessage('Request timed out. Please try again.');
      }
    } on http.ClientException catch (e) {
      debugPrint('Client error: $e');
      if (mounted) {
        _addErrorMessage('Failed to connect to backend server. Make sure it\'s running on $backendUrl');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      if (mounted) {
        _addErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _addErrorMessage([String? customMessage]) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': customMessage ?? 'Sorry, I\'m having trouble connecting. Please try again.',
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickMessage(String message) {
    _controller.text = message;
    _sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.psychology, size: 20),
            ),
            SizedBox(width: 12),
            Text('Dr. HeartAI Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Action Buttons
          if (_messages.isEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickButton('Analyze my health', Icons.analytics),
                      _buildQuickButton('Create diet plan', Icons.restaurant_menu),
                      _buildQuickButton('Exercise routine', Icons.fitness_center),
                      _buildQuickButton('Heart health tips', Icons.lightbulb_outline),
                    ],
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Ask me about heart health!',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'I can help with diet, exercise, and health analysis',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingMessage();
                      }
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(isUser ? 20 * (1 - value) : -20 * (1 - value), 0),
                              child: _buildMessageBubble(message['content']!, isUser),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about heart health, diet, or exercise...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      suffixIcon: _isLoading
                          ? Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                                ),
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: _sendMessage,
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, IconData icon) {
    return InkWell(
      onTap: () => _sendQuickMessage(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Color(0xFF2196F3)),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser 
              ? LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
            bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Row(
                children: [
                  Icon(Icons.psychology, size: 16, color: Color(0xFFE63946)),
                  SizedBox(width: 6),
                  Text(
                    'Dr. HeartAI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            if (!isUser) SizedBox(height: 4),
            Text(
              content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.grey[800],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Dr. HeartAI is thinking...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
