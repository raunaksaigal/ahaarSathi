import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _calorieController = TextEditingController();
  final _waterController = TextEditingController();
  bool _isLoading = false;
  final _scrollController = ScrollController();
  
  // Mock data for demonstration purposes
  final List<Map<String, dynamic>> _weightData = [
    {'date': DateTime.now().subtract(const Duration(days: 30)), 'weight': 73.5},
    {'date': DateTime.now().subtract(const Duration(days: 25)), 'weight': 73.0},
    {'date': DateTime.now().subtract(const Duration(days: 20)), 'weight': 72.2},
    {'date': DateTime.now().subtract(const Duration(days: 15)), 'weight': 71.8},
    {'date': DateTime.now().subtract(const Duration(days: 10)), 'weight': 71.0},
    {'date': DateTime.now().subtract(const Duration(days: 5)), 'weight': 70.5},
    {'date': DateTime.now(), 'weight': 70.0},
  ];
  
  final List<Map<String, dynamic>> _calorieData = [
    {'day': 'Mon', 'actual': 1980, 'target': 2000},
    {'day': 'Tue', 'actual': 1850, 'target': 2000},
    {'day': 'Wed', 'actual': 2100, 'target': 2000},
    {'day': 'Thu', 'actual': 1920, 'target': 2000},
    {'day': 'Fri', 'actual': 1790, 'target': 2000},
    {'day': 'Sat', 'actual': 2050, 'target': 2000},
    {'day': 'Sun', 'actual': 1850, 'target': 2000},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _waterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      _calorieController.text = user.dailyCalorieTarget.toString();
      _waterController.text = (user.dailyWaterTarget / 1000).toString(); // Convert ml to L
    }
  }

  Future<void> _saveGoals() async {
    // Basic validation
    if (_calorieController.text.isEmpty || _waterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Parse input values
      final calorieTarget = int.tryParse(_calorieController.text) ?? 0;
      final waterTarget = (double.tryParse(_waterController.text) ?? 0) * 1000; // Convert L to ml
      
      // Update user profile
      await userProvider.updateUserProfile(
        dailyCalorieTarget: calorieTarget,
        dailyWaterTarget: waterTarget.toInt(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating goals: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Generate weight trend line chart data
  List<FlSpot> _getWeightSpots() {
    return _weightData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final item = entry.value;
      return FlSpot(index, item['weight']);
    }).toList();
  }
  
  // Generate bar groups for calorie chart
  List<BarChartGroupData> _getCalorieBarGroups() {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < _calorieData.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: _calorieData[i]['actual'],
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: _calorieData[i]['target'],
              color: Colors.orange.withOpacity(0.5),
              width: 12,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }
  
  // Generate line data for calorie chart
  List<LineChartBarData> _getCalorieLineData() {
    List<FlSpot> actualSpots = [];
    List<FlSpot> targetSpots = [];
    
    for (int i = 0; i < _calorieData.length; i++) {
      actualSpots.add(FlSpot(i.toDouble(), _calorieData[i]['actual'].toDouble()));
      targetSpots.add(FlSpot(i.toDouble(), _calorieData[i]['target'].toDouble()));
    }
    
    return [
      LineChartBarData(
        spots: actualSpots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.blue,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      LineChartBarData(
        spots: targetSpots,
        isCurved: true,
        color: Colors.orange.withOpacity(0.8),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: Colors.orange.withOpacity(0.8),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        dashArray: [5, 5],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final cardBorderColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
    final chartLineColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Set Your Goals',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Weight trend chart
                  Card(
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chart title with legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weight Trend',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Weight (kg)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last 30 days',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Weight line chart
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: chartLineColor.withOpacity(0.1),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 5 != 0 && value != 0 && value != _weightData.length - 1) {
                                          return const SizedBox.shrink();
                                        }
                                        final index = value.toInt();
                                        if (index < 0 || index >= _weightData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final date = _weightData[index]['date'] as DateTime;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            DateFormat('d MMM').format(date),
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            value.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                minX: 0,
                                maxX: (_weightData.length - 1).toDouble(),
                                minY: _weightData.map((data) => data['weight'] as double).reduce((a, b) => a < b ? a : b) - 0.5,
                                maxY: _weightData.map((data) => data['weight'] as double).reduce((a, b) => a > b ? a : b) + 0.5,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getWeightSpots(),
                                    isCurved: true,
                                    curveSmoothness: 0.3,
                                    color: Colors.green,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: Colors.green,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.green.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Start/End weight comparison
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Start: ',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_weightData.first['weight']} kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Current: ',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_weightData.last['weight']} kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Change: ',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${(_weightData.last['weight'] - _weightData.first['weight']).toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _weightData.last['weight'] < _weightData.first['weight'] 
                                          ? Colors.green 
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Calorie comparison chart
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: cardBorderColor,
                        width: isDarkMode ? 1 : 0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chart title with legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weekly Calorie Intake',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Actual',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Target',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last 7 days',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Replace bar chart with line chart
                          SizedBox(
                            height: 220,
                            child: LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipBgColor: isDarkMode ? Colors.grey[800]! : Colors.white,
                                    tooltipRoundedRadius: 8,
                                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                      return touchedBarSpots.map((barSpot) {
                                        final flSpot = barSpot;
                                        final index = flSpot.x.toInt();
                                        if (index < 0 || index >= _calorieData.length) {
                                          return null;
                                        }
                                        
                                        final String label = barSpot.barIndex == 0 ? 'Actual' : 'Target';
                                        final color = barSpot.barIndex == 0 ? Colors.blue : Colors.orange;
                                        
                                        return LineTooltipItem(
                                          '$label: ${flSpot.y.toInt()} kcal',
                                          TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= _calorieData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _calorieData[index]['day'],
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.7),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 500 != 0) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            '${value.toInt()}',
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 500,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: chartLineColor.withOpacity(0.1),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                minX: 0,
                                maxX: (_calorieData.length - 1).toDouble(),
                                minY: 0,
                                maxY: 2500,
                                lineBarsData: _getCalorieLineData(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Daily calorie intake goal
                  Text(
                    'Daily Calorie Target',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _calorieController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g., 2000',
                      border: const OutlineInputBorder(),
                      suffixText: 'kcal',
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recommended daily calorie intake varies based on age, gender, height, weight, and activity level.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Daily water intake goal
                  Text(
                    'Daily Water Target',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _waterController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'e.g., 2.5',
                      border: const OutlineInputBorder(),
                      suffixText: 'liters',
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The recommended daily water intake is around 2-3 liters (8-12 cups) for most adults.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveGoals,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDarkMode ? Colors.blue : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isDarkMode ? 0 : 2,
                      ),
                      child: const Text(
                        'Save Goals',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 