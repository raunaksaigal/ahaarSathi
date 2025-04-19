import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/food_logging_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/profile_screen.dart';
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
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        }
      ),
    );
  }
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
