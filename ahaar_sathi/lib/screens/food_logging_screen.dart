import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_bar.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/food_entry.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
=======
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({Key? key}) : super(key: key);

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _servingController = TextEditingController(text: '1');
  bool _isLoading = false;
  bool _showSearchResults = false;
  bool _isFromImagePrediction = false;
  Map<String, dynamic>? _foodData;
  Map<String, dynamic>? _baseFoodData;
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    _servingController.dispose();
    super.dispose();
  }

  void _updateServing(double value) {
    setState(() {
      _servingController.text = value.toString();
      if (_baseFoodData != null) {
<<<<<<< HEAD
        final baseCalories = (_baseFoodData!['calories(kcal)'] as num?)?.toDouble() ?? 0.0;
        final baseProtein = (_baseFoodData!['protein'] as num?)?.toDouble() ?? 0.0;
        final baseCarbs = (_baseFoodData!['carbs'] as num?)?.toDouble() ?? 0.0;
        final baseFat = (_baseFoodData!['fat'] as num?)?.toDouble() ?? 0.0;
        final baseSugar = (_baseFoodData!['sugar'] as num?)?.toDouble() ?? 0.0;
        final baseFibre = (_baseFoodData!['fibre'] as num?)?.toDouble() ?? 0.0;
        final baseSodium = (_baseFoodData!['sodium'] as num?)?.toDouble() ?? 0.0;
        final baseCalcium = (_baseFoodData!['calcium'] as num?)?.toDouble() ?? 0.0;
        final baseIron = (_baseFoodData!['iron'] as num?)?.toDouble() ?? 0.0;
        final baseVitamin = (_baseFoodData!['vitamin'] as num?)?.toDouble() ?? 0.0;
        final baseFolate = (_baseFoodData!['folate'] as num?)?.toDouble() ?? 0.0;
=======
        final baseCalories = (_baseFoodData!['calories'] as num?)?.toDouble() ?? 0.0;
        final baseProtein = (_baseFoodData!['protein'] as num?)?.toDouble() ?? 0.0;
        final baseCarbs = (_baseFoodData!['carbs'] as num?)?.toDouble() ?? 0.0;
        final baseFat = (_baseFoodData!['fat'] as num?)?.toDouble() ?? 0.0;
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
        
        _foodData = {
          ..._baseFoodData!,
          'calories': (baseCalories * value).round(),
          'protein': (baseProtein * value).round(),
          'carbs': (baseCarbs * value).round(),
          'fat': (baseFat * value).round(),
<<<<<<< HEAD
          'sugar': (baseSugar * value).round(),
          'fibre': (baseFibre * value).round(),
          'sodium': (baseSodium * value).round(),
          'calcium': (baseCalcium * value).round(),
          'iron': (baseIron * value).round(),
          'vitamin': (baseVitamin * value).round(),
          'folate': (baseFolate * value).round(),
=======
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
        };
      }
    });
  }

  Future<void> _searchFood() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSearchResults = false;
      _isFromImagePrediction = false;
    });

    try {
<<<<<<< HEAD
      final apiService = ApiService();
      final result = await apiService.searchFood(_searchController.text);
      print("Result: $result");

      final baseData = {
        'name': result['dish_name'],
        'calories(kcal)': (result['calories(kcal)'] as num?)?.toDouble() ?? 0.0,
        'protein': (result['protein(g)'] as num?)?.toDouble() ?? 0.0,
        'carbs': (result['carbohydrates(g)'] as num?)?.toDouble() ?? 0.0,
        'fat': (result['fats(g)'] as num?)?.toDouble() ?? 0.0,
        'sugar': (result['sugar(g)'] as num?)?.toDouble() ?? 0.0,
        'fibre': (result['fibre(g)'] as num?)?.toDouble() ?? 0.0,
        'sodium': (result['sodium(mg)'] as num?)?.toDouble() ?? 0.0,
        'calcium': (result['calcium(mg)'] as num?)?.toDouble() ?? 0.0,
        'iron': (result['iron(mg)'] as num?)?.toDouble() ?? 0.0,
        'vitamin': (result['vitamin_c(mg)'] as num?)?.toDouble() ?? 0.0,
        'folate': (result['folate(microg)'] as num?)?.toDouble() ?? 0.0,
        'serving_size': '100g',
      };

      setState(() {
        _baseFoodData = baseData;
        final servingSize = double.tryParse(_servingController.text) ?? 1.0;
        
        _foodData = {
          ...baseData,
          'calories': (baseData['calories(kcal)'] as num?)?.toDouble() ?? 0.0,
          'protein': (baseData['protein'] as num?)?.toDouble() ?? 0.0,
          'carbs': (baseData['carbs'] as num?)?.toDouble() ?? 0.0,
          'fat': (baseData['fat'] as num?)?.toDouble() ?? 0.0,
          'sugar': (baseData['sugar'] as num?)?.toDouble() ?? 0.0,
          'fibre': (baseData['fibre'] as num?)?.toDouble() ?? 0.0,
          'sodium': (baseData['sodium'] as num?)?.toDouble() ?? 0.0,
          'calcium': (baseData['calcium'] as num?)?.toDouble() ?? 0.0,
          'iron': (baseData['iron'] as num?)?.toDouble() ?? 0.0,
          'vitamin': (baseData['vitamin'] as num?)?.toDouble() ?? 0.0,
          'folate': (baseData['folate'] as num?)?.toDouble() ?? 0.0,
=======
      // TODO: Call API to search for food
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      final baseData = {
        'name': _searchController.text,
        'calories': 250.0,
        'protein': 10.0,
        'carbs': 30.0,
        'fat': 8.0,
        'serving_size': '100g',
      };
      setState(() {
        _baseFoodData = baseData;
        final servingSize = double.tryParse(_servingController.text) ?? 1.0;
        final baseCalories = (baseData['calories'] as num?)?.toDouble() ?? 0.0;
        final baseProtein = (baseData['protein'] as num?)?.toDouble() ?? 0.0;
        final baseCarbs = (baseData['carbs'] as num?)?.toDouble() ?? 0.0;
        final baseFat = (baseData['fat'] as num?)?.toDouble() ?? 0.0;
        
        _foodData = {
          ...baseData,
          'calories': (baseCalories * servingSize).round(),
          'protein': (baseProtein * servingSize).round(),
          'carbs': (baseCarbs * servingSize).round(),
          'fat': (baseFat * servingSize).round(),
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
        };
        _showSearchResults = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching food: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _showSearchResults = false;
    });

    try {
      final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);
<<<<<<< HEAD
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.user == null) {
        throw Exception('User not logged in');
      }

      final result = await nutritionProvider.recognizeFood(userProvider.user!.id, imageFile);

      if (result['success']) {
        final prediction = result['prediction_detail']['nutrition'];
        final baseData = {
          'name': prediction['dish_name'] ?? 'Unknown Food',
          'calories(kcal)': (prediction['calories(kcal)'] as num?)?.toDouble() ?? 0.0,
          'protein': (prediction['protein(g)'] as num?)?.toDouble() ?? 0.0,
          'carbs': (prediction['carbohydrates(g)'] as num?)?.toDouble() ?? 0.0,
          'fat': (prediction['fats(g)'] as num?)?.toDouble() ?? 0.0,
          'sugar': (prediction['sugar(g)'] as num?)?.toDouble() ?? 0.0,
          'fibre': (prediction['fibre(g)'] as num?)?.toDouble() ?? 0.0,
          'sodium': (prediction['sodium(mg)'] as num?)?.toDouble() ?? 0.0,
          'calcium': (prediction['calcium(mg)'] as num?)?.toDouble() ?? 0.0,
          'iron': (prediction['iron(mg)'] as num?)?.toDouble() ?? 0.0,
          'vitamin': (prediction['vitamin(mg)'] as num?)?.toDouble() ?? 0.0,
          'folate': (prediction['folate(microg)'] as num?)?.toDouble() ?? 0.0,
=======
      final result = await nutritionProvider.recognizeFood(imageFile);

      if (result['success']) {
        final prediction = result['prediction'];
        final baseData = {
          'name': prediction['class'] ?? 'Unknown Food',
          'calories': (prediction['confidence'] as num?)?.toDouble() ?? 0.0,
          'protein': (prediction['protein'] as num?)?.toDouble() ?? 0.0,
          'carbs': (prediction['carbs'] as num?)?.toDouble() ?? 0.0,
          'fat': (prediction['fat'] as num?)?.toDouble() ?? 0.0,
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
          'serving_size': '100g',
        };
        setState(() {
          _baseFoodData = baseData;
          final servingSize = double.tryParse(_servingController.text) ?? 1.0;
<<<<<<< HEAD
          final baseCalories = (baseData['calories(kcal)'] as num?)?.toDouble() ?? 0.0;
=======
          final baseCalories = (baseData['calories'] as num?)?.toDouble() ?? 0.0;
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
          final baseProtein = (baseData['protein'] as num?)?.toDouble() ?? 0.0;
          final baseCarbs = (baseData['carbs'] as num?)?.toDouble() ?? 0.0;
          final baseFat = (baseData['fat'] as num?)?.toDouble() ?? 0.0;
          
          _foodData = {
            ...baseData,
<<<<<<< HEAD
            'calories': (baseData['calories(kcal)'] as num?)?.toDouble() ?? 0.0,
=======
            'calories': (baseCalories * servingSize).round(),
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
            'protein': (baseProtein * servingSize).round(),
            'carbs': (baseCarbs * servingSize).round(),
            'fat': (baseFat * servingSize).round(),
          };
          _showSearchResults = true;
          _isLoading = false;
          _isFromImagePrediction = true;
          _imageFile = imageFile;
        });
      } else {
        throw Exception('Failed to recognize food');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      appBar: const AhaarSathiAppBar(
        title: 'Log Food',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar with camera icon
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Search for food...',
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _searchFood(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.black),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take a picture'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _takePicture();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose from gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    if (_showSearchResults && _foodData != null) ...[
                      const SizedBox(height: 24),
                      
                      // Display image if it came from image prediction
                      if (_isFromImagePrediction && _imageFile != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      
                      // Food name and correction option
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _foodData!['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isFromImagePrediction)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showSearchResults = false;
                                  _searchController.text = _foodData!['name'];
                                  _isFromImagePrediction = false;
                                });
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Incorrect?'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      
                      // Nutrition information
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
<<<<<<< HEAD
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nutrition Info:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _nutrientRow('Calories', '${_foodData!['calories']} kcal', Icons.local_fire_department_rounded, Colors.orange),
                              _nutrientRow('Protein', '${_foodData!['protein']}g', Icons.fitness_center_rounded, Colors.blue),
                              _nutrientRow('Carbs', '${_foodData!['carbs']}g', Icons.grain_rounded, Colors.green),
                              _nutrientRow('Fat', '${_foodData!['fat']}g', Icons.water_drop_rounded, Colors.red),
                              _nutrientRow('Sugar', '${_foodData!['sugar']}g', Icons.cake_rounded, Colors.pink),
                              _nutrientRow('Fibre', '${_foodData!['fibre']}g', Icons.grass_rounded, Colors.brown),
                              _nutrientRow('Sodium', '${_foodData!['sodium']}mg', Icons.science_rounded, Colors.blueGrey),
                              _nutrientRow('Calcium', '${_foodData!['calcium']}mg', Icons.egg_rounded, Colors.cyan),
                              _nutrientRow('Iron', '${_foodData!['iron']}mg', Icons.bloodtype_rounded, Colors.redAccent),
                              _nutrientRow('Vitamin C', '${_foodData!['vitamin']}mg', Icons.medical_services_rounded, Colors.orangeAccent),
                              _nutrientRow('Folate', '${_foodData!['folate']}μg', Icons.eco_rounded, Colors.lightGreen),
=======
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Calories'),
                                  Text('${_foodData!['calories']} kcal'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Protein'),
                                  Text('${_foodData!['protein']}g'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Carbs'),
                                  Text('${_foodData!['carbs']}g'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Fat'),
                                  Text('${_foodData!['fat']}g'),
                                ],
                              ),
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Serving size adjustment
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Serving Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: double.parse(_servingController.text),
                                  min: 0.5,
                                  max: 5,
                                  divisions: 9,
                                  label: '${_servingController.text}x',
                                  onChanged: _updateServing,
                                ),
                              ),
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextField(
                                  controller: _servingController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    suffix: Text('x'),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _updateServing(double.parse(value));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
<<<<<<< HEAD

  Widget _nutrientRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
=======
>>>>>>> d597129a216602c46030b9bd855f77bc9f5f8a4c
} 