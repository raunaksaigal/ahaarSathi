import 'package:intl/intl.dart';

class FoodEntry {
  final String id;
  final String name;
  final int calories;
  final String imageUrl;
  final DateTime timestamp;
  final String mealType; // breakfast, lunch, dinner, snack
  final Map<String, dynamic> nutritionInfo; // protein, carbs, fat, etc.

  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.timestamp,
    required this.mealType,
    required this.nutritionInfo,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      imageUrl: json['image_url'],
      timestamp: DateTime.parse(json['timestamp']),
      mealType: json['meal_type'],
      nutritionInfo: json['nutrition_info'],
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'image_url': imageUrl,
      'timestamp': dateFormat.format(timestamp),
      'meal_type': mealType,
      'nutrition_info': nutritionInfo,
    };
  }

  String get formattedDate {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return dateFormat.format(timestamp);
  }

  String get formattedTime {
    final timeFormat = DateFormat('HH:mm');
    return timeFormat.format(timestamp);
  }
} 