class User {
  final String id;
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final int dailyCalorieTarget;
  final int dailyWaterTarget;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.dailyCalorieTarget,
    required this.dailyWaterTarget,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      gender: json['gender'],
      dailyCalorieTarget: json['daily_calorie_target'],
      dailyWaterTarget: json['daily_water_target'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'daily_calorie_target': dailyCalorieTarget,
      'daily_water_target': dailyWaterTarget,
    };
  }

  User copyWith({
    String? id,
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    int? dailyCalorieTarget,
    int? dailyWaterTarget,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyWaterTarget: dailyWaterTarget ?? this.dailyWaterTarget,
    );
  }
} 