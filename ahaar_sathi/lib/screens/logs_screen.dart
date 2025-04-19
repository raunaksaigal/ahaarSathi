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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(foodEntry.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories: ${foodEntry.calories} kcal'),
            SizedBox(height: 8),
            Text('Meal Type: ${foodEntry.mealType}'),
            SizedBox(height: 8),
            Text('Time: ${foodEntry.formattedTime}'),
            SizedBox(height: 16),
            Text('Nutrition Info:'),
            SizedBox(height: 4),
            if (foodEntry.nutritionInfo.containsKey('carbs'))
              Text('Carbs: ${foodEntry.nutritionInfo['carbs']}g'),
            if (foodEntry.nutritionInfo.containsKey('protein'))
              Text('Protein: ${foodEntry.nutritionInfo['protein']}g'),
            if (foodEntry.nutritionInfo.containsKey('fat'))
              Text('Fat: ${foodEntry.nutritionInfo['fat']}g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
} 