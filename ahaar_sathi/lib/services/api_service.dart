import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';

class ApiService {
  // Base URL for the Django backend API
  final String baseUrl = 'http://192.168.29.84:8000'; // Use this for Android emulator
  // For physical device testing, use your computer's actual IP address
  // final String baseUrl = 'http://192.168.1.X:8000/api';

  // User API calls
  Future<User> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId/'));
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<User> updateUserProfile(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Food API calls
  Future<List<FoodEntry>> getFoodEntries(String userId, {String? date}) async {
    try {
      String url = '$baseUrl/users/$userId/food/';
      if (date != null) {
        url += '?date=$date';
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => FoodEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load food entries');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<FoodEntry> addFoodEntry(String userId, FoodEntry foodEntry) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/food/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(foodEntry.toJson()),
      );
      if (response.statusCode == 201) {
        return FoodEntry.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add food entry');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> uploadFoodImage(String userId, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/$userId/food/image-upload/'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['image_url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Water API calls
  Future<List<WaterEntry>> getWaterEntries(String userId, {String? date}) async {
    try {
      String url = '$baseUrl/users/$userId/water/';
      if (date != null) {
        url += '?date=$date';
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => WaterEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load water entries');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<WaterEntry> addWaterEntry(String userId, WaterEntry waterEntry) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/water/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(waterEntry.toJson()),
      );
      if (response.statusCode == 201) {
        return WaterEntry.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add water entry');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Food recognition API call
  Future<Map<String, dynamic>> recognizeFood(String userId, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/food-recognition/'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
      
      request.fields['user_id'] = userId;
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to recognize food');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get summary data for dashboard
  Future<Map<String, dynamic>> getDashboardData(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId/dashboard/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Authentication API calls
  Future<User> login(String email, String password) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/login'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'email': email,
      //     'password': password,
      //   }),
      // );
      
      // if (response.statusCode == 200) {
      //   return User.fromJson(json.decode(response.body));
      // } else {
      //   throw Exception('Failed to login: ${response.statusCode}');
      // }
      
      // Mock response for demo
      await Future.delayed(const Duration(seconds: 1));
      return User(
        id: 'user123',
        name: 'Demo User',
        age: 30,
        height: 170,
        weight: 65,
        gender: 'Male',
        dailyCalorieTarget: 2000,
        dailyWaterTarget: 2500,
      );
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<User> signup(String name, String email, String password) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/signup'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'name': name,
      //     'email': email,
      //     'password': password,
      //   }),
      // );
      
      // if (response.statusCode == 201) {
      //   return User.fromJson(json.decode(response.body));
      // } else {
      //   throw Exception('Failed to create account: ${response.statusCode}');
      // }
      
      // Mock response for demo
      await Future.delayed(const Duration(seconds: 1));
      return User(
        id: 'user123',
        name: name,
        age: 30,
        height: 170,
        weight: 65,
        gender: 'Male',
        dailyCalorieTarget: 2000,
        dailyWaterTarget: 2500,
      );
    } catch (e) {
      throw Exception('Error during signup: $e');
    }
  }

  Future<void> logout(String userId) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/logout'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'userId': userId,
      //   }),
      // );
      
      // if (response.statusCode != 200) {
      //   throw Exception('Failed to logout: ${response.statusCode}');
      // }
      
      // Mock response for demo
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/reset-password'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'email': email,
      //   }),
      // );
      
      // if (response.statusCode != 200) {
      //   throw Exception('Failed to reset password: ${response.statusCode}');
      // }
      
      // Mock response for demo
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    } catch (e) {
      throw Exception('Error during password reset: $e');
    }
  }

  // Image Prediction API calls
  Future<Map<String, dynamic>> predictImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/image/upload/'),
      );
      
      // Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'prediction': responseData['prediction_detail'],
          'image_id': responseData['id'],
        };
      } else {
        print('Error response: ${response.body}'); // Debug print
        throw Exception('Failed to predict image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in predictImage: $e'); // Debug print
      throw Exception('Error predicting image: $e');
    }
  }

  Future<bool> submitPredictionFeedback({
    required String imageId,
    required bool isCorrect,
    String? correctClass,
    String? feedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/image/feedback/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_id': imageId,
          'is_correct': isCorrect,
          'correct_class': correctClass,
          'feedback': feedback,
        }),
      );
      
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting feedback: $e');
    }
  }
} 