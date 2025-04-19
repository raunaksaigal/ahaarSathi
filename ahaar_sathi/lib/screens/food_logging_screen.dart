import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_bar.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/food_entry.dart';

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
        final baseCalories = (_baseFoodData!['calories'] as num?)?.toDouble() ?? 0.0;
        final baseProtein = (_baseFoodData!['protein'] as num?)?.toDouble() ?? 0.0;
        final baseCarbs = (_baseFoodData!['carbs'] as num?)?.toDouble() ?? 0.0;
        final baseFat = (_baseFoodData!['fat'] as num?)?.toDouble() ?? 0.0;
        
        _foodData = {
          ..._baseFoodData!,
          'calories': (baseCalories * value).round(),
          'protein': (baseProtein * value).round(),
          'carbs': (baseCarbs * value).round(),
          'fat': (baseFat * value).round(),
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
      final result = await nutritionProvider.recognizeFood(imageFile);

      if (result['success']) {
        final prediction = result['prediction'];
        final baseData = {
          'name': prediction['class'] ?? 'Unknown Food',
          'calories': (prediction['confidence'] as num?)?.toDouble() ?? 0.0,
          'protein': (prediction['protein'] as num?)?.toDouble() ?? 0.0,
          'carbs': (prediction['carbs'] as num?)?.toDouble() ?? 0.0,
          'fat': (prediction['fat'] as num?)?.toDouble() ?? 0.0,
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
} 