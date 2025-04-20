import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'providers/user_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/food_logging_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AhaarSathi',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              fontFamily: GoogleFonts.inter().fontFamily,
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: Colors.teal,
                secondary: Colors.tealAccent.shade700,
                surface: Colors.white,
                background: Colors.grey.shade50,
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade800,
                titleTextStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.teal.shade800,
                ),
                iconTheme: IconThemeData(color: Colors.teal.shade800),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.teal.shade300),
                ),
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.light().textTheme,
              ).copyWith(
                titleLarge: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Colors.teal.shade900,
                ),
                titleMedium: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                bodyLarge: GoogleFonts.inter(
                  fontSize: 16,
                ),
                bodyMedium: GoogleFonts.inter(
                  fontSize: 14,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: GoogleFonts.inter().fontFamily,
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: Colors.tealAccent,
                secondary: Colors.tealAccent.shade400,
                surface: Colors.grey.shade900,
                background: Colors.black,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey.shade900,
                elevation: 0,
                titleTextStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.tealAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.tealAccent.shade700),
                ),
              ),
              scaffoldBackgroundColor: Colors.black,
              cardColor: Colors.grey.shade900,
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme,
              ).copyWith(
                titleLarge: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Colors.white,
                ),
                titleMedium: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.white,
                ),
                bodyLarge: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white,
                ),
                bodyMedium: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade800),
                ),
                color: Colors.grey.shade900,
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        }
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _horizontalAnimation;
  late Animation<double> _strokeAnimation1;
  late Animation<double> _strokeAnimation2;
  late Animation<double> _strokeAnimation3;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    
    // Make the Namaste text fully appear first (0.0-0.2 interval)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );
    
    // Slide in animation completes faster to ensure text is fully visible
    _horizontalAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
      ),
    );
    
    // Animations for strokes start after Namaste is fully visible
    _strokeAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.4, curve: Curves.easeInOut),
      ),
    );
    
    _strokeAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.55, curve: Curves.easeInOut),
      ),
    );
    
    _strokeAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    // Glow animation happens last and cycles
    _glowAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _controller.forward();
    
    // Check authentication status after animation
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (!mounted) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.checkAuthStatus();
    
    if (!mounted) return;
    
    if (userProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Silver Namaste text with animated glow
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(_horizontalAnimation.value, 0),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base silver text (not affected by fade)
                          Center(
                            child: Text(
                              "नमस्ते",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2.0,
                                height: 1.2,
                                color: Colors.grey.shade600.withOpacity(_fadeAnimation.value),
                              ),
                            ),
                          ),
                          
                          // Circular fade in/out effect on white text
                          ShaderMask(
                            shaderCallback: (rect) {
                              return RadialGradient(
                                center: Alignment.center,
                                radius: _glowAnimation.value * 0.5,
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              "नमस्ते",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2.0,
                                height: 1.2,
                                color: Colors.white,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5 * _glowAnimation.value),
                                    blurRadius: 15.0,
                                    spreadRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Animated horizontal lines
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 60,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: LinePainter(
                      progress: _strokeAnimation1.value,
                      color: Colors.white.withOpacity(0.4),
                      startX: MediaQuery.of(context).size.width * 0.2,
                      endX: MediaQuery.of(context).size.width * 0.8,
                    ),
                  ),
                ),
                
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 + 100,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: LinePainter(
                      progress: _strokeAnimation2.value,
                      color: Colors.white.withOpacity(0.4),
                      startX: MediaQuery.of(context).size.width * 0.2,
                      endX: MediaQuery.of(context).size.width * 0.8,
                      reverse: true,
                    ),
                  ),
                ),
                
                // App name appears last with subtle fade-in
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _strokeAnimation3.value,
                      child: Column(
                        children: [
                          Text(
                            "AHAAR SATHI",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 8.0,
                              color: const Color(0xFFCCCCCC),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your Nutrition Companion",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.0,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Custom painter for animated horizontal lines
class LinePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double startX;
  final double endX;
  final bool reverse;
  
  LinePainter({
    required this.progress,
    required this.color,
    required this.startX,
    required this.endX,
    this.reverse = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final start = reverse ? Offset(endX - (endX - startX) * progress, 0) : Offset(startX, 0);
    final end = reverse ? Offset(endX, 0) : Offset(startX + (endX - startX) * progress, 0);
    
    canvas.drawLine(start, end, paint);
  }
  
  @override
  bool shouldRepaint(LinePainter oldDelegate) => 
    oldDelegate.progress != progress || 
    oldDelegate.color != color;
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Initialize user data when the app starts
  @override
  void initState() {
    super.initState();
    _initUserData();
  }
  
  Future<void> _initUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initUser();
  }
  
  // All screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const LogsScreen(),
    const GoalsScreen(),
    const ProfileScreen(),
  ];
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: _currentIndex == 0 
        ? null  // No AppBar on Home screen as it has its own header
        : AppBar(
            title: Text(
              _getAppBarTitle(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FoodLoggingScreen(),
            ),
          );
        },
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AhaarSathiBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
  
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Daily Logs';
      case 2:
        return 'Your Goals';
      case 3:
        return 'Profile';
      default:
        return 'AhaarSathi';
    }
  }
}
