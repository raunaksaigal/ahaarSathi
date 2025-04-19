import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;

  // Constructor - loads saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      // Default to light mode if there's an error
      _isDarkMode = false;
    }
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    // Save the preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      // Error saving preference
      print('Error saving theme preference: $e');
    }
    
    notifyListeners();
  }

  // Set a specific theme
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      
      // Save the preference
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', _isDarkMode);
      } catch (e) {
        // Error saving preference
        print('Error saving theme preference: $e');
      }
      
      notifyListeners();
    }
  }
} 