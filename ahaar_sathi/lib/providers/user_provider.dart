import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isAuthenticated;
  
  // Initialize user data with fake data
  Future<void> initUser() async {
    _setLoading(true);
    
    try {
      // Simulate delay for loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create fake user directly
      _user = User(
        id: '1',
        name: 'Arjun Singh',
        age: 28,
        height: 175.0,
        weight: 70.0,
        gender: 'Male',
        dailyCalorieTarget: 2000,
        dailyWaterTarget: 2500,
      );
      
      // Save user ID to preferences so it persists
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _user!.id);
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Initialize user data as guest
  Future<void> initGuestUser() async {
    _setLoading(true);
    
    try {
      // Create guest user
      _user = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest User',
        age: 30,
        height: 170.0,
        weight: 65.0,
        gender: 'Other',
        dailyCalorieTarget: 2000,
        dailyWaterTarget: 2500,
      );
      
      // Save guest status to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _user!.id);
      await prefs.setBool('is_guest', true);
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Fetch user profile from API (commented out, using fake data)
  Future<void> fetchUserProfile(String userId) async {
    _setLoading(true);
    
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Uncomment when API is ready
      // final user = await _apiService.getUserProfile(userId);
      // _user = user;
      
      // For now, just use fake data
      _user = User(
        id: userId,
        name: 'Arjun Singh',
        age: 28,
        height: 175.0,
        weight: 70.0,
        gender: 'Male',
        dailyCalorieTarget: 2000,
        dailyWaterTarget: 2500,
      );
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    int? dailyCalorieTarget,
    int? dailyWaterTarget,
  }) async {
    if (_user == null) return;
    
    _setLoading(true);
    
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedUser = _user!.copyWith(
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        dailyCalorieTarget: dailyCalorieTarget,
        dailyWaterTarget: dailyWaterTarget,
      );
      
      // Uncomment when API is ready
      // final user = await _apiService.updateUserProfile(updatedUser);
      // _user = user;
      
      // For now, just use the updated user directly
      _user = updatedUser;
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final isGuest = prefs.getBool('is_guest') ?? false;
    
    if (userId != null) {
      if (isGuest) {
        await initGuestUser();
      } else {
        await fetchUserProfile(userId);
      }
      _isAuthenticated = true;
    }
  }
  
  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
<<<<<<< HEAD
      final apiService = ApiService();
      final user = await apiService.login(email, password);
      
      _user = user;
=======
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, accept any email/password
      _user = User(
        id: '1',
        name: 'Arjun Singh',
        age: 28,
        height: 175.0,
        weight: 70.0,
        gender: 'Male',
        dailyCalorieTarget: 2000,
        dailyWaterTarget: 2500,
      );
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
      
      // Save user ID to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _user!.id);
      await prefs.setBool('is_guest', false);
      
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Logout method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('is_guest');
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
  
<<<<<<< HEAD
  // Signup method
  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    try {
      final apiService = ApiService();
      final user = await apiService.signup(name, email, password);
      
      _user = user;
      
      // Save user ID to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _user!.id);
      await prefs.setBool('is_guest', false);
      
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
=======
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 