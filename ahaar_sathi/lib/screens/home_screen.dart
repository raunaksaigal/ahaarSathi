import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/donut_chart.dart';
import '../widgets/food_card.dart';
import '../models/food_entry.dart';
import 'food_logging_screen.dart';
import 'water_logging_screen.dart';
import 'water_logging_screen_dark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_dataLoaded) return;
    
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);

    try {
      // Initialize user if needed
      if (userProvider.user == null) {
        await userProvider.initUser();
      }
      
      if (userProvider.user != null) {
        // Load data in parallel
        await Future.wait([
          nutritionProvider.fetchFoodEntries(userProvider.user!.id),
          nutritionProvider.fetchWaterEntries(userProvider.user!.id),
          nutritionProvider.fetchDashboardData(userProvider.user!.id),
        ]);
        
        _dataLoaded = true;
      }
    } catch (e) {
      // Handle errors silently but show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not connect to server. Using sample data.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final nutritionProvider = Provider.of<NutritionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = userProvider.user;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Handle when user is not available yet
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              "Loading user profile...",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // Get today's food entries (or empty list if none)
    final todayFoodEntries = nutritionProvider.foodEntries.take(3).toList();
    
    // Calculate calorie and water percentages
    final caloriePercentage = user.dailyCalorieTarget > 0 
        ? (nutritionProvider.totalCaloriesToday / user.dailyCalorieTarget).clamp(0.0, 1.0)
        : 0.0;
    
    final waterPercentage = user.dailyWaterTarget > 0 
        ? (nutritionProvider.totalWaterToday / user.dailyWaterTarget).clamp(0.0, 1.0)
        : 0.0;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: theme.colorScheme.primary,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with greeting
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user.name.split(' ')[0]}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  'Track your nutrition journey',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                              child: Icon(
                                Icons.person_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Summary cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Calories card
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Calories',
                                value: '${nutritionProvider.totalCaloriesToday}',
                                target: '${user.dailyCalorieTarget}',
                                percentage: caloriePercentage,
                                color: Colors.orange.shade300,
                                icon: Icons.local_fire_department_rounded,
                                unit: 'kcal',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const FoodLoggingScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Water card
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Water',
                                value: '${(nutritionProvider.totalWaterToday / 1000).toStringAsFixed(1)}',
                                target: '${(user.dailyWaterTarget / 1000).toStringAsFixed(1)}',
                                percentage: waterPercentage,
                                color: Colors.blue.shade300,
                                icon: Icons.water_drop_rounded,
                                unit: 'L',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => themeProvider.isDarkMode 
                                        ? const WaterLoggingScreenDark()
                                        : const WaterLoggingScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick actions section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Quick Actions',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.teal.shade700,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Add food button
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                icon: Icons.restaurant_rounded,
                                label: 'Add Food',
                                color: Colors.green,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const FoodLoggingScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Add water button
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                icon: Icons.water_drop_rounded,
                                label: 'Add Water',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => themeProvider.isDarkMode 
                                        ? const WaterLoggingScreenDark()
                                        : const WaterLoggingScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Camera button
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                icon: Icons.camera_alt_rounded,
                                label: 'Camera',
                                color: Colors.purple,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const FoodLoggingScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Recent meals section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Meals',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.teal.shade700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to logs screen via bottom tab
                                DefaultTabController.of(context)?.animateTo(1);
                              },
                              child: Text(
                                'See all',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Food entries list or empty state
                      todayFoodEntries.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 24),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDarkMode 
                                            ? Colors.grey.shade800.withOpacity(0.3) 
                                            : Colors.grey.shade200.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 48,
                                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No meals logged today',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap the "Add Food" button to log your first meal',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: todayFoodEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = todayFoodEntries[index];
                                  return FoodCard(
                                    foodEntry: entry,
                                    onTap: () {
                                      // Show a food detail dialog
                                      _showFoodDetails(context, entry);
                                    },
                                  );
                                },
                              ),
                            ),
                      
                      // Bottom padding to avoid FAB overlap
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String target,
    required double percentage,
    required Color color,
    required IconData icon,
    required String unit,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDarkMode 
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: color,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Value
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Target
            Text(
              'Target: $target $unit',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDarkMode 
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFoodDetails(BuildContext context, FoodEntry foodEntry) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          foodEntry.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              "Calories", 
              "${foodEntry.calories} kcal", 
              Icons.local_fire_department_rounded,
              Colors.orange,
              isDarkMode
            ),
            const SizedBox(height: 12),
            _infoRow(
              "Meal Type", 
              foodEntry.mealType, 
              Icons.restaurant_rounded,
              Colors.green,
              isDarkMode
            ),
            const SizedBox(height: 12),
            _infoRow(
              "Time", 
              foodEntry.formattedTime, 
              Icons.access_time_rounded,
              Colors.blue,
              isDarkMode
            ),
            
            const SizedBox(height: 16),
            Text(
              'Nutrition Info:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (foodEntry.nutritionInfo.containsKey('carbs'))
              _nutrientRow('Carbs', '${foodEntry.nutritionInfo['carbs']}g', isDarkMode),
            if (foodEntry.nutritionInfo.containsKey('protein'))
              _nutrientRow('Protein', '${foodEntry.nutritionInfo['protein']}g', isDarkMode),
            if (foodEntry.nutritionInfo.containsKey('fat'))
              _nutrientRow('Fat', '${foodEntry.nutritionInfo['fat']}g', isDarkMode),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoRow(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _nutrientRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
} 