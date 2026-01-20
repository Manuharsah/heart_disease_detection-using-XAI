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

// ============================================
// ADD THIS SPLASH SCREEN CLASS
// ============================================
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Navigate to HomePage after 2.5 seconds
    Future.delayed(Duration(milliseconds: 6000), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
            return FadeTransition(opacity: fadeAnimation, child: child);
          },
          transitionDuration: Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6366F1),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heart icon with animation
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFC7D2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 100,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                
                // PULSE AI Text
                Text(
                  'PULSE AI',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                
                // Subtitle
                Text(
                  'Heart Health Predictor',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40),
                
                // Loading indicator
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Container(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeartDiseaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartAI - Cardiovascular Health',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6366F1),
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF14B8A6),
          tertiary: Color(0xFF10B981),
          surface: Color(0xFFFFFFFF),
          surfaceVariant: Color(0xFFF8FAFC),
          background: Color(0xFFF1F5F9),
          onBackground: Color(0xFF0F172A),
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.white,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Color(0xFF6366F1),
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
          displaySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF475569),
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // CHANGED FROM HomePage() TO SplashScreen()
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============================================
// ALL YOUR EXISTING CODE BELOW (NO CHANGES NEEDED)
// ============================================

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Widget> get _pages => [
    InputScreen(key: ValueKey('input')),
    AboutScreen(key: ValueKey('about')),
    ChatScreen(key: ValueKey('chat')),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _pages[_currentIndex],
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF6366F1),
            unselectedItemColor: Color(0xFF94A3B8),
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 0 
                        ? Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 22,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 22,
                  ),
                ),
                label: 'Risk Check',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 1 
                        ? Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 22,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.info,
                    size: 22,
                  ),
                ),
                label: 'About',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 2 
                        ? Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 22,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.chat_bubble,
                    size: 22,
                  ),
                ),
                label: 'AI Assistant',
              ),
            ],
          ),
        ),
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
              return FadeTransition(opacity: fadeAnimation, child: child);
            },
            transitionDuration: Duration(milliseconds: 400),
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
        content: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Heart Disease Risk Assessment',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
                        scale: 0.8 + (0.2 * value),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: isLoading ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      'Analyzing your health profile...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
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
                                  scale: 0.95 + (0.05 * value),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      padding: EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF6366F1).withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.favorite, color: Colors.white, size: 32),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Complete Your Health Profile',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Get personalized cardiovascular risk assessment',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 14,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),

                            // Age Slider
                            _buildSectionCard(
                              theme,
                              'Age',
                              '${age} years',
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                                  activeTrackColor: Color(0xFF6366F1),
                                  inactiveTrackColor: Color(0xFFE2E8F0),
                                  thumbColor: Colors.white,
                                  overlayColor: Color(0xFF6366F1).withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: age.toDouble(),
                                  min: 18,
                                  max: 100,
                                  divisions: 82,
                                  onChanged: (val) => setState(() => age = val.toInt()),
                                ),
                              ),
                            ),

                            // Sex Selection
                            _buildSectionCard(
                              theme,
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
                              theme,
                              'BMI (Body Mass Index)',
                              '${bmi.toStringAsFixed(1)} ${_getBMICategory(bmi)}',
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                                  activeTrackColor: Color(0xFF6366F1),
                                  inactiveTrackColor: Color(0xFFE2E8F0),
                                  thumbColor: Colors.white,
                                  overlayColor: Color(0xFF6366F1).withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: bmi,
                                  min: 15,
                                  max: 50,
                                  divisions: 350,
                                  onChanged: (val) => setState(() => bmi = val),
                                ),
                              ),
                            ),

                            // Health Questions
                            _buildDropdown(
                              theme,
                              'Do you smoke?',
                              smoking,
                              ['Yes', 'No'],
                              (val) => setState(() => smoking = val!),
                              Icons.smoking_rooms,
                            ),

                            _buildDropdown(
                              theme,
                              'Physical activity in past 30 days?',
                              physicalActivity,
                              ['Yes', 'No'],
                              (val) => setState(() => physicalActivity = val!),
                              Icons.fitness_center,
                            ),

                            _buildDropdown(
                              theme,
                              'Heavy alcohol consumption?',
                              alcohol,
                              ['Yes', 'No'],
                              (val) => setState(() => alcohol = val!),
                              Icons.wine_bar,
                            ),

                            _buildDropdown(
                              theme,
                              'General Health',
                              generalHealth,
                              ['Excellent', 'Very good', 'Good', 'Fair', 'Poor'],
                              (val) => setState(() => generalHealth = val!),
                              Icons.health_and_safety,
                            ),

                            _buildSectionCard(
                              theme,
                              'Sleep Hours',
                              '$sleepHours hours per night',
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                                  activeTrackColor: Color(0xFF6366F1),
                                  inactiveTrackColor: Color(0xFFE2E8F0),
                                  thumbColor: Colors.white,
                                  overlayColor: Color(0xFF6366F1).withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: sleepHours.toDouble(),
                                  min: 3,
                                  max: 12,
                                  divisions: 9,
                                  onChanged: (val) => setState(() => sleepHours = val.toInt()),
                                ),
                              ),
                            ),

                            _buildDropdown(
                              theme,
                              'Do you have diabetes?',
                              diabetes,
                              ['Yes', 'No', 'Borderline'],
                              (val) => setState(() => diabetes = val!),
                              Icons.bloodtype,
                            ),

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
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF6366F1).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : submitData,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(double.infinity, 56),
                                          backgroundColor: Color(0xFF6366F1),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.analytics_outlined, size: 22),
                                            SizedBox(width: 12),
                                            Text(
                                              'Analyze My Risk',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
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
                ],
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

  Widget _buildSectionCard(ThemeData theme, String title, String? subtitle, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF6366F1) : Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xFF6366F1) : Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Color(0xFF64748B),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Color(0xFF475569),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    ThemeData theme,
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    label,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Color(0xFF0F172A),
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
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                style: theme.textTheme.bodyLarge,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6366F1)),
              ),
            ],
          ),
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    if (riskLevel.contains('Low')) return Color(0xFF10B981);
    if (riskLevel.contains('Medium')) return Color(0xFFF59E0B);
    return Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskPercentage = widget.result['risk_percentage'] as double;
    final riskLevel = widget.result['risk_level'] as String;
    final topFactors = widget.result['top_risk_factors'] as List;
    final recommendations = widget.result['recommendations'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Results',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Risk Score Card
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getRiskColor(riskLevel).withOpacity(0.1),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _getRiskColor(riskLevel).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Cardiovascular Risk',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Color(0xFF0F172A),
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
                                    strokeWidth: 12,
                                    backgroundColor: Color(0xFFE2E8F0),
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
                                        fontWeight: FontWeight.w800,
                                        color: _getRiskColor(riskLevel),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _getRiskColor(riskLevel),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        riskLevel.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
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
                    SizedBox(height: 20),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Diet Plan',
                            Icons.restaurant_menu,
                            Color(0xFF6366F1),
                            () => _getDietPlan(context),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Exercise Plan',
                            Icons.fitness_center,
                            Color(0xFF10B981),
                            () => _getExercisePlan(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Risk Factors
                    if (topFactors.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFD97706),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Main Risk Factors',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Color(0xFF0F172A),
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
                                          color: Color(0xFFFEF3C7).withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.info_outline,
                                            color: Color(0xFFD97706), size: 18),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              factor['factor'] as String,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '${factor['impact']} Impact',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Color(0xFF64748B),
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
                      SizedBox(height: 20),
                    ],

                    // Recommendations
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.lightbulb_outline,
                                    color: Color(0xFF059669), size: 20),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Personalized Recommendations',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Color(0xFF0F172A),
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
                                        color: Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(Icons.check_circle,
                                          color: Color(0xFF059669), size: 16),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        rec.toString(),
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 20, color: Color(0xFF6366F1)),
                                SizedBox(width: 8),
                                Text(
                                  'Check Again',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6366F1).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ChatScreen(initialHealthData: widget.healthData),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      final slideAnimation = Tween<Offset>(
                                        begin: Offset(0.0, 0.1),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                          parent: animation, curve: Curves.easeOut));
                                      final fadeAnimation = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).animate(CurvedAnimation(
                                          parent: animation, curve: Curves.easeOut));
                                      return SlideTransition(
                                        position: slideAnimation,
                                        child: FadeTransition(
                                          opacity: fadeAnimation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6366F1),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ask AI Assistant',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      ),
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
              color: Color(0xFF6366F1),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
              return FadeTransition(opacity: fadeAnimation, child: child);
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ),
      ),
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
              color: Color(0xFF10B981),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
              return FadeTransition(opacity: fadeAnimation, child: child);
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ENHANCED ABOUT SCREEN
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About HeartAI',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.favorite, size: 48, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'HeartAI',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cardiovascular Health Assistant',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(
                    context,
                    Icons.psychology,
                    'AI-Powered Analysis',
                    'Advanced machine learning model (Random Forest) with 90.73% accuracy, trained on 387,000+ patient records.',
                    Color(0xFF6366F1),
                  ),
                  _buildInfoCard(
                    context,
                    Icons.restaurant_menu,
                    'Personalized Diet Plans',
                    'Get customized meal plans tailored to your health profile, focusing on heart-healthy nutrition.',
                    Color(0xFF10B981),
                  ),
                  _buildInfoCard(
                    context,
                    Icons.fitness_center,
                    'Exercise Recommendations',
                    'Receive personalized workout routines designed to improve cardiovascular health based on your fitness level.',
                    Color(0xFF8B5CF6),
                  ),
                  _buildInfoCard(
                    context,
                    Icons.chat_bubble_outline,
                    'AI Health Assistant',
                    '24/7 access to Dr. HeartAI for real-time health analysis, questions, and guidance.',
                    Color(0xFFF59E0B),
                  ),
                  _buildInfoCard(
                    context,
                    Icons.analytics,
                    'Model Performance',
                    '• Accuracy: 90.73%\n• ROC-AUC: 87.87%\n• Explainable AI with SHAP analysis',
                    Color(0xFF6366F1),
                  ),
                  _buildInfoCard(
                    context,
                    Icons.warning_amber,
                    'Important Disclaimer',
                    'This app is for educational and informational purposes only. Always consult healthcare professionals for medical decisions and before starting any diet or exercise program.',
                    Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String title, String content, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.psychology, size: 20, color: Color(0xFF6366F1)),
            ),
            SizedBox(width: 12),
            Text(
              'Dr. HeartAI Assistant',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Action Buttons
          if (_messages.isEmpty)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
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
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chat_bubble_outline, size: 48, color: Color(0xFF94A3B8)),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ask me about heart health!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'I can help with diet, exercise, and health analysis',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Color(0xFF94A3B8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(20),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about heart health, diet, or exercise...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: _isLoading
                          ? Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send_rounded, color: Colors.white, size: 22),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Dr. HeartAI',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser 
                    ? LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                ),
                border: isUser 
                    ? null 
                    : Border.all(color: Color(0xFFF1F5F9)),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: Color(0xFF6366F1).withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isUser ? Colors.white : Color(0xFF475569),
                  height: 1.5,
                ),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Thinking...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}