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
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();
  String _selectedOption = 'camera'; // 'camera' or 'manual'

  // Controllers for manual entry
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String _selectedMealType = 'Lunch';

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });

        // Process the image
        await _processImage();
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
        setState(() {
          _imageFile = File(image.path);
        });

        // Process the image
        await _processImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User profile not loaded')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to server for food recognition
      final result = await nutritionProvider.recognizeFood(
        userProvider.user!.id,
        _imageFile!,
      );

      // Prefill form with recognized data
      if (result.containsKey('name')) {
        _nameController.text = result['name'];
      }
      
      if (result.containsKey('calories')) {
        _caloriesController.text = result['calories'].toString();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error but prefill with sample data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Using sample food data')),
      );
      
      // Provide sample data
      _nameController.text = 'Samosa';
      _caloriesController.text = '250';
    }
  }

  Future<void> _saveFoodEntry() async {
    // Basic validation
    if (_nameController.text.isEmpty || _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not loaded')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = 'https://example.com/food_placeholder.jpg';
      
      // Upload image if available
      if (_imageFile != null) {
        imageUrl = await nutritionProvider.uploadFoodImage(
          userProvider.user!.id,
          _imageFile!,
        );
      }

      // Create new food entry
      final foodEntry = FoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        name: _nameController.text,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
        nutritionInfo: {
          'carbs': 30,  // Default values
          'protein': 5,
          'fat': 15,
        },
      );

      // Save to backend (or local state in this case)
      await nutritionProvider.addFoodEntry(userProvider.user!.id, foodEntry);

      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food entry saved successfully')),
      );

      // Go back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving food entry: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions
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
                    // Method selection
                    Text(
                      'How would you like to log your food?',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // Option selection
                    Row(
                      children: [
                        // Camera option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOption = 'camera';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: _selectedOption == 'camera'
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedOption == 'camera'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: isSmallScreen ? 40 : 48,
                                    color: _selectedOption == 'camera'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Take a Picture',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Manual entry option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOption = 'manual';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: _selectedOption == 'manual'
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedOption == 'manual'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: isSmallScreen ? 40 : 48,
                                    color: _selectedOption == 'manual'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Manual Entry',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    
                    // Camera option content
                    if (_selectedOption == 'camera') ...[
                      _imageFile == null
                          ? Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: isSmallScreen ? 70 : 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Take a picture of your food',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  isSmallScreen 
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _takePicture,
                                            icon: const Icon(Icons.camera_alt),
                                            label: const Text('Take Picture'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: _pickImage,
                                            icon: const Icon(Icons.photo_library),
                                            label: const Text('From Gallery'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _takePicture,
                                          icon: const Icon(Icons.camera_alt),
                                          label: const Text('Take Picture'),
                                        ),
                                        const SizedBox(width: 16),
                                        OutlinedButton.icon(
                                          onPressed: _pickImage,
                                          icon: const Icon(Icons.photo_library),
                                          label: const Text('From Gallery'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                // Display the captured image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _imageFile!,
                                    width: double.infinity,
                                    height: isSmallScreen ? 180 : 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _takePicture,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Retake'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Gallery'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                    
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    
                    // Food details form (for both options)
                    if (_imageFile != null || _selectedOption == 'manual') ...[
                      Text(
                        'Food Details',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Food name
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Food Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Calories
                      TextField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                          suffixText: 'kcal',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Meal type
                      DropdownButtonFormField<String>(
                        value: _selectedMealType,
                        decoration: const InputDecoration(
                          labelText: 'Meal Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Breakfast',
                            child: Text('Breakfast'),
                          ),
                          DropdownMenuItem(
                            value: 'Lunch',
                            child: Text('Lunch'),
                          ),
                          DropdownMenuItem(
                            value: 'Dinner',
                            child: Text('Dinner'),
                          ),
                          DropdownMenuItem(
                            value: 'Snack',
                            child: Text('Snack'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMealType = value;
                            });
                          }
                        },
                      ),
                      
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saveFoodEntry,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Food Entry',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
} 