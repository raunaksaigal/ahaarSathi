import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/food_card.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import 'water_logging_screen.dart';
import 'water_logging_screen_dark.dart';
import 'package:google_fonts/google_fonts.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 2, vsync: this);
    
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_selectedDay == null) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);

    try {
      // Make sure user is initialized
      if (userProvider.user == null) {
        await userProvider.initUser();
      }
      
      if (userProvider.user != null) {
        final date = DateFormat('yyyy-MM-dd').format(_selectedDay!);
        await Future.wait([
          nutritionProvider.fetchFoodEntries(userProvider.user!.id, date: date),
          nutritionProvider.fetchWaterEntries(userProvider.user!.id, date: date),
        ]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load entries. Using sample data.'),
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
    final nutritionProvider = Provider.of<NutritionProvider>(context);
    
    // Get date string for the selected day
    final selectedDateStr = _selectedDay != null 
        ? DateFormat('MMM dd, yyyy').format(_selectedDay!)
        : DateFormat('MMM dd, yyyy').format(DateTime.now());
    
    return Scaffold(
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadData();
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          
          const Divider(),
          
          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Logs for $selectedDateStr',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // Refresh button
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.restaurant),
                text: 'Food',
              ),
              Tab(
                icon: Icon(Icons.water_drop),
                text: 'Water',
              ),
            ],
          ),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Food tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : nutritionProvider.foodEntries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.no_food,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No meals logged on $selectedDateStr',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/food_logging');
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text('Add a meal'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: nutritionProvider.foodEntries.length,
                            itemBuilder: (context, index) {
                              final entry = nutritionProvider.foodEntries[index];
                              return FoodCard(
                                foodEntry: entry,
                                onTap: () {
                                  _showFoodDetails(context, entry);
                                },
                              );
                            },
                          ),
                
                // Water tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : nutritionProvider.waterEntries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No water logged on $selectedDateStr',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => themeProvider.isDarkMode
                                            ? const WaterLoggingScreenDark()
                                            : const WaterLoggingScreen(),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text('Add water'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: nutritionProvider.waterEntries.length,
                            itemBuilder: (context, index) {
                              final entry = nutritionProvider.waterEntries[index];
                              return _buildWaterCard(entry);
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWaterCard(WaterEntry waterEntry) {
    final timeStr = DateFormat.Hm().format(waterEntry.timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.blue,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${waterEntry.amount} ml',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Added at $timeStr',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
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
        content: SingleChildScrollView(
          child: Column(
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
              _nutrientRow('Carbs', foodEntry.carbs, isDarkMode),
              _nutrientRow('Protein', foodEntry.protein, isDarkMode),
              _nutrientRow('Fat', foodEntry.fat, isDarkMode),
              _nutrientRow('Sugar', foodEntry.sugar, isDarkMode),
              _nutrientRow('Fibre', foodEntry.fibre, isDarkMode),
              _nutrientRow('Sodium', foodEntry.sodium, isDarkMode),
              _nutrientRow('Calcium', foodEntry.calcium, isDarkMode),
              _nutrientRow('Iron', foodEntry.iron, isDarkMode),
              _nutrientRow('Vitamin C', foodEntry.vitaminC, isDarkMode),
              _nutrientRow('Folate', foodEntry.folate, isDarkMode),
            ],
          ),
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
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Widget _nutrientRow(String label, String value, bool isDarkMode) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
} 