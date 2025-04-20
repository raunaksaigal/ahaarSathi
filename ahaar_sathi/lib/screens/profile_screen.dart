import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/user.dart';
import '../widgets/calorie_donut_chart.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _ageController.text = user.age.toString();
      _heightController.text = user.height.toString();
      _weightController.text = user.weight.toString();
      _selectedGender = user.gender;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Parse input values
      final name = _nameController.text;
      final age = int.tryParse(_ageController.text) ?? 0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      
      // Update user profile
      await userProvider.updateUserProfile(
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: _selectedGender,
      );
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Profile header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _isEditing
                              ? TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                )
                              : Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Theme toggle
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'APPEARANCE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return SwitchListTile(
                                  title: const Text('Dark Mode'),
                                  subtitle: const Text('Use black & white minimalist theme'),
                                  secondary: Icon(
                                    themeProvider.isDarkMode 
                                        ? Icons.dark_mode 
                                        : Icons.light_mode,
                                  ),
                                  value: themeProvider.isDarkMode,
                                  onChanged: (value) {
                                    themeProvider.setDarkMode(value);
                                  },
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Edit button
                    if (!_isEditing)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                    
                    // Logout button
                    if (!_isEditing)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                await userProvider.logout();
                                
                                if (!mounted) return;
                                // Navigate to login screen using MaterialPageRoute
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error logging out: ${e.toString()}')),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      ),
                    
                    if (_isEditing) ...[
                      // Age field
                      const Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g., 30',
                          border: OutlineInputBorder(),
                          suffixText: 'years',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Height field
                      const Text(
                        'Height',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'e.g., 175',
                          border: OutlineInputBorder(),
                          suffixText: 'cm',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Weight field
                      const Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'e.g., 70',
                          border: OutlineInputBorder(),
                          suffixText: 'kg',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Gender field
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Save button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _initializeControllers(); // Reset to original values
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Profile details
                      _buildProfileItem('Age', '${user.age} years'),
                      _buildProfileItem('Height', '${user.height} cm'),
                      _buildProfileItem('Weight', '${user.weight} kg'),
                      _buildProfileItem('Gender', user.gender),
                      
                      const SizedBox(height: 32),
                      
                      // Calorie summary with donut chart
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          final isDarkMode = themeProvider.isDarkMode;
                          final textColor = isDarkMode ? Colors.white : Colors.black;
                          final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
                          final cardBorderColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
                          
                          return Card(
                            color: cardColor,
                            elevation: isDarkMode ? 0 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: cardBorderColor!,
                                width: isDarkMode ? 1 : 0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Daily Calories',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.info_outline,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          // Show info about calories
                                        },
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Donut chart
                                  Center(
                                    child: CalorieDonutChart(
                                      consumed: Provider.of<NutritionProvider>(context).totalCaloriesToday.toDouble(),
                                      total: user.dailyCalorieTarget.toDouble(),
                                      size: 160,
                                      thickness: 15,
                                      showText: true,
                                      showIcon: true,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Macronutrients
                                  Text(
                                    'Macronutrients',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Macros display
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMacroItem(
                                        context,
                                        'Carbs',
                                        '${(Provider.of<NutritionProvider>(context).totalCaloriesToday * 0.5 / 4).toInt()}g',
                                        'Goal: ${(user.dailyCalorieTarget * 0.5 / 4).toInt()}g',
                                        Colors.amber,
                                        isDarkMode,
                                      ),
                                      _buildMacroItem(
                                        context,
                                        'Protein',
                                        '${(Provider.of<NutritionProvider>(context).totalCaloriesToday * 0.3 / 4).toInt()}g',
                                        'Goal: ${(user.dailyCalorieTarget * 0.3 / 4).toInt()}g',
                                        Colors.red,
                                        isDarkMode,
                                      ),
                                      _buildMacroItem(
                                        context,
                                        'Fat',
                                        '${(Provider.of<NutritionProvider>(context).totalCaloriesToday * 0.2 / 9).toInt()}g',
                                        'Goal: ${(user.dailyCalorieTarget * 0.2 / 9).toInt()}g',
                                        Colors.blue,
                                        isDarkMode,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build macro item
  Widget _buildMacroItem(
    BuildContext context, 
    String title, 
    String value, 
    String target, 
    Color color, 
    bool isDarkMode
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            target,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
} 