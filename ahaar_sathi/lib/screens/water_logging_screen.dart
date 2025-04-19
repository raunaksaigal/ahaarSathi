import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/water_entry.dart';
import 'dart:math' as math;

class WaterLoggingScreen extends StatefulWidget {
  const WaterLoggingScreen({Key? key}) : super(key: key);

  @override
  State<WaterLoggingScreen> createState() => _WaterLoggingScreenState();
}

class _WaterLoggingScreenState extends State<WaterLoggingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  double _sliderValue = 250;
  final List<int> _quickAmounts = [100, 200, 250, 300, 500, 750];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _amountController.text = _sliderValue.round().toString();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveWaterEntry() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter water amount')),
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
      // Create new water entry
      final waterEntry = WaterEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: int.tryParse(_amountController.text) ?? 0,
        timestamp: DateTime.now(),
      );

      // Save to backend (or local state in this case)
      await nutritionProvider.addWaterEntry(userProvider.user!.id, waterEntry);

      setState(() {
        _isLoading = false;
      });

      // Show success message with custom success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[200]),
              const SizedBox(width: 10),
              const Text('Water entry saved successfully'),
            ],
          ),
          backgroundColor: Colors.blue.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Go back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving water entry: ${e.toString()}')),
      );
    }
  }

  void _updateAmount(double value) {
    setState(() {
      _sliderValue = value;
      _amountController.text = value.round().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final nutritionProvider = Provider.of<NutritionProvider>(context);
    final user = userProvider.user;
    
    // Calculate current progress
    double progress = 0.0;
    if (user != null) {
      progress = nutritionProvider.totalWaterToday / user.dailyWaterTarget;
    }
    
    // Cap progress at 1.0 (100%)
    if (progress > 1.0) progress = 1.0;
    
    // Format date
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    
    // Get responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Tracker',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              dateStr,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveWaterEntry,
            tooltip: 'Save water entry',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Water progress visualization
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          height: isSmallScreen ? 180 : 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.blue.shade400, Colors.blue.shade700],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Water wave effect
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: (isSmallScreen ? 180 : 220) * progress * _animation.value,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CustomPaint(
                                    painter: WavePainter(
                                      animation: _animation,
                                      waveColor: Colors.white.withOpacity(0.3),
                                    ),
                                    child: Container(),
                                  ),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.water_drop_rounded,
                                          color: Colors.white.withOpacity(0.9),
                                          size: isSmallScreen ? 24 : 30,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${(nutritionProvider.totalWaterToday / 1000).toStringAsFixed(1)}L",
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 36 : 48,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.1),
                                                offset: const Offset(0, 3),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (user != null)
                                      Text(
                                        "of ${(user.dailyWaterTarget / 1000).toStringAsFixed(1)}L daily goal",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    // Progress percentage
                                    Text(
                                      "${(progress * 100).toInt()}% completed",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    
                    // Amount selection
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "AMOUNT",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        suffix: Text(
                                          'ml',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 14,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            _sliderValue = double.tryParse(value) ?? 0;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Slider with custom appearance
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.blue.shade400,
                                inactiveTrackColor: Colors.blue.shade100,
                                thumbColor: Colors.white,
                                overlayColor: Colors.blue.withOpacity(0.3),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: isSmallScreen ? 10 : 12,
                                  elevation: 4,
                                  pressedElevation: 8,
                                ),
                                trackHeight: isSmallScreen ? 6 : 8,
                              ),
                              child: Slider(
                                value: _sliderValue,
                                min: 0,
                                max: 1000,
                                divisions: 100,
                                onChanged: _updateAmount,
                              ),
                            ),
                            
                            // Min/Max labels
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '0 ml',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '1000 ml',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    
                    // Quick select buttons
                    const Text(
                      "QUICK ADD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Improved quick amount buttons
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _quickAmounts.length,
                      itemBuilder: (context, index) {
                        final amount = _quickAmounts[index];
                        final isSelected = _sliderValue == amount;
                        return InkWell(
                          onTap: () => _updateAmount(amount.toDouble()),
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Stack(
                              children: [
                                if (isSelected)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 14,
                                    ),
                                  ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        color: isSelected ? Colors.white : Colors.blue,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${amount}ml",
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    
                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveWaterEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.blue.shade200,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            const SizedBox(width: 8),
                            const Text(
                              "ADD WATER",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Custom wave painter for water animation
class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color waveColor;

  WavePainter({required this.animation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = waveColor;
    final path = Path();
    
    final baseWaveHeight = size.height * 0.05;
    final waveCount = 3; // Number of waves
    
    path.moveTo(0, size.height);
    
    for (int i = 0; i <= size.width.toInt(); i++) {
      // Multiple sin waves with offset for more realistic effect
      path.lineTo(
        i.toDouble(),
        size.height - 
          baseWaveHeight * math.sin((animation.value * 360 - i) * math.pi / 180 * waveCount / size.width) - 
          baseWaveHeight * 0.5 * math.sin((animation.value * 360 - i) * math.pi / 90 * waveCount / size.width),
      );
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
} 