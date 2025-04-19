import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';

class ApiService {
  // Base URL for the Django backend API
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Use this for Android emulator
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
} 