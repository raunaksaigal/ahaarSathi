import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  
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
  
  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Call the API service logout method if we had real authentication
      if (_user != null) {
        await _apiService.logout(_user!.id);
      }
      
      // Clear stored user data
      _user = null;
      
      // Remove user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
} 