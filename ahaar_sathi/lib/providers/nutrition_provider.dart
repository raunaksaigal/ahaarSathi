import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import '../services/api_service.dart';

class NutritionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<FoodEntry> _foodEntries = [];
  List<WaterEntry> _waterEntries = [];
  Map<String, dynamic>? _dashboardData;
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<FoodEntry> get foodEntries => _foodEntries;
  List<WaterEntry> get waterEntries => _waterEntries;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Calculate total calories consumed today
  int get totalCaloriesToday {
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
    
    return _foodEntries
        .where((entry) => DateFormat('yyyy-MM-dd').format(entry.timestamp) == todayFormatted)
        .fold(0, (sum, entry) => sum + entry.calories.round());
  }
  
  // Calculate total water consumed today (in milliliters)
  int get totalWaterToday {
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
    
    return _waterEntries
        .where((entry) => DateFormat('yyyy-MM-dd').format(entry.timestamp) == todayFormatted)
        .fold(0, (sum, entry) => sum + entry.amount);
  }
  
  // Load fake food entries
  void _loadFakeData() {
    // Sample food entries
    _foodEntries = [
      FoodEntry(
        id: '1',
        name: 'Paneer Butter Masala',
        calories: 450,
        imageUrl: 'https://example.com/paneer.jpg',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        mealType: 'Lunch',
        nutritionInfo: {
          'carbs': 30,
          'protein': 15,
          'fat': 25,
        },
      ),
      FoodEntry(
        id: '2',
        name: 'Aloo Paratha',
        calories: 320,
        imageUrl: 'https://example.com/paratha.jpg',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        mealType: 'Breakfast',
        nutritionInfo: {
          'carbs': 45,
          'protein': 8,
          'fat': 12,
        },
      ),
      FoodEntry(
        id: '3',
        name: 'Masala Chai',
        calories: 120,
        imageUrl: 'https://example.com/chai.jpg',
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
        mealType: 'Breakfast',
        nutritionInfo: {
          'carbs': 15,
          'protein': 3,
          'fat': 5,
        },
      ),
    ];

    // Sample water entries
    _waterEntries = [
      WaterEntry(
        id: '1',
        amount: 250,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      WaterEntry(
        id: '2',
        amount: 300,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      WaterEntry(
        id: '3',
        amount: 200,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    // Sample dashboard data
    _dashboardData = {
      'daily_summary': {
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'total_calories': 890,
        'total_water': 750,
        'calorie_target': 2000,
        'water_target': 2000,
      },
      'weekly_summary': {
        'start_date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 6))),
        'end_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'days': [
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 6))), 'calories': 1750},
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 5))), 'calories': 1900},
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 4))), 'calories': 1650},
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 3))), 'calories': 1800},
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 2))), 'calories': 1700},
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1))), 'calories': 1850},
          {'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'calories': 890},
        ],
      },
    };
  }
  
  // Fetch food entries (with fake data)
  Future<void> fetchFoodEntries(String userId, {String? date}) async {
    _setLoading(true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Uncomment this when API is ready
      // final entries = await _apiService.getFoodEntries(userId, date: date);
      // _foodEntries = entries;
      
      // Use fake data for now
      _loadFakeData();
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Add food entry
  Future<void> addFoodEntry(String userId, FoodEntry foodEntry) async {
    _setLoading(true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Uncomment this when API is ready
      // final newEntry = await _apiService.addFoodEntry(userId, foodEntry);
      
      // For now, just add the entry to our list
      _foodEntries.add(foodEntry);
      _foodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Upload food image
  Future<String> uploadFoodImage(String userId, File imageFile) async {
    _setLoading(true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Uncomment this when API is ready
      // final imageUrl = await _apiService.uploadFoodImage(userId, imageFile);
      
      // Return dummy URL for now
      const imageUrl = 'https://example.com/uploaded_image.jpg';
      
      _setLoading(false);
      return imageUrl;
    } catch (e) {
      _setError(e.toString());
      return '';
    }
  }
  
  // Image prediction and food recognition
  Future<Map<String, dynamic>> recognizeFood(String userId, File imageFile) async {
    try {
      _setLoading(true);
      final result = await _apiService.predictImage(imageFile);
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Submit feedback for a prediction
  Future<bool> submitPredictionFeedback({
    required String imageId,
    required bool isCorrect,
    String? correctClass,
    String? feedback,
  }) async {
    _setLoading(true);
    try {
      final success = await _apiService.submitPredictionFeedback(
        imageId: imageId,
        isCorrect: isCorrect,
        correctClass: correctClass,
        feedback: feedback,
      );
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to determine current meal type
  String _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'Lunch';
    } else if (hour >= 16 && hour < 20) {
      return 'Snack';
    } else {
      return 'Dinner';
    }
  }
  
  // Fetch water entries
  Future<void> fetchWaterEntries(String userId, {String? date}) async {
    _setLoading(true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Uncomment this when API is ready
      // final entries = await _apiService.getWaterEntries(userId, date: date);
      // _waterEntries = entries;
      
      // Use fake data for now
      _loadFakeData();
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Add water entry
  Future<void> addWaterEntry(String userId, WaterEntry waterEntry) async {
    _setLoading(true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Uncomment this when API is ready
      // final newEntry = await _apiService.addWaterEntry(userId, waterEntry);
      
      // For now, just add the entry to our list
      _waterEntries.add(waterEntry);
      _waterEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Fetch dashboard data
  Future<void> fetchDashboardData(String userId) async {
    _setLoading(true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Uncomment this when API is ready
      // final data = await _apiService.getDashboardData(userId);
      // _dashboardData = data;
      
      // Use fake data for now
      _loadFakeData();
      
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

  // Update food entry
  void updateFoodEntry(FoodEntry updatedEntry) {
    final index = _foodEntries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      _foodEntries[index] = updatedEntry;
      notifyListeners();
    }
  }
} 