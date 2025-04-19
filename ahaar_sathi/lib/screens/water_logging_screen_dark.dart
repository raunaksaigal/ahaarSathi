import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/water_entry.dart';
import 'dart:math' as math;

class WaterLoggingScreenDark extends StatefulWidget {
  const WaterLoggingScreenDark({Key? key}) : super(key: key);

  @override
  State<WaterLoggingScreenDark> createState() => _WaterLoggingScreenDarkState();
}

class _WaterLoggingScreenDarkState extends State<WaterLoggingScreenDark> with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });
    _animationController.repeat(reverse: false);
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

      // Show success message with custom snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.greenAccent[100]),
              const SizedBox(width: 10),
              const Text(
                'Water entry saved successfully',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.grey[900],
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
    
    // Get responsive dimensions
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE, d MMM').format(DateTime.now()),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.lock, color: Colors.white60, size: 14),
          ],
        ),
        centerTitle: true,
        actions: [
          // Save button
          IconButton(
            icon: const Icon(Icons.done_rounded, color: Colors.white),
            onPressed: _saveWaterEntry,
            tooltip: 'Save water entry',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 20.0,
                  vertical: isSmallScreen ? 8.0 : 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop_rounded,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "WATER INTAKE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    
                    // Water progress container with animated wave
                    Container(
                      height: isSmallScreen ? 200 : 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Water level with wave animation
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: (isSmallScreen ? 200 : 240) * progress,
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    // First wave
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: WavePainter(
                                          animation: _animation,
                                          waveColor: Colors.blue.withOpacity(0.2),
                                          waveCount: 2,
                                        ),
                                      ),
                                    ),
                                    // Second wave (offset)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: WavePainter(
                                          animation: _animation,
                                          waveColor: Colors.blue.withOpacity(0.3),
                                          waveCount: 3,
                                          offset: math.pi,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Content overlay
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 20 : 25,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Current amount
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${(nutritionProvider.totalWaterToday / 1000).toStringAsFixed(1)}L",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 36 : 42,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (user != null)
                                      Text(
                                        "of ${(user.dailyWaterTarget / 1000).toStringAsFixed(1)}L goal",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white60,
                                        ),
                                      ),
                                  ],
                                ),
                                
                                // Progress indicators
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "TODAY'S PROGRESS",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 8,
                                              backgroundColor: Colors.grey[800],
                                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "${(progress * 100).toInt()}%",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    
                    // Amount input section
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 16 : 20,
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "AMOUNT",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey[800]!,
                                    width: 1,
                                  ),
                                ),
                                width: 120,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            final numValue = double.tryParse(value);
                                            if (numValue != null && numValue <= 1000) {
                                              setState(() {
                                                _sliderValue = numValue;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    const Text(
                                      ' ml',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Custom styled slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.blue,
                              inactiveTrackColor: Colors.grey[800],
                              thumbColor: Colors.white,
                              overlayColor: Colors.blue.withOpacity(0.1),
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: isSmallScreen ? 6 : 8,
                                elevation: 4,
                                pressedElevation: 8,
                              ),
                              trackHeight: isSmallScreen ? 3 : 4,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0 ml',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '1000 ml',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    
                    // Quick add buttons section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "QUICK ADD",
                            style: TextStyle(
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.2,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Grid of quick add buttons
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
                                    color: isSelected ? Colors.blue : Colors.grey[850],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Colors.blue : Colors.grey[700]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${amount}ml",
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24 : 30),
                    
                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveWaterEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.water_drop),
                            SizedBox(width: 8),
                            Text(
                              "ADD WATER",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
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

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color waveColor;
  final int waveCount;
  final double offset;

  WavePainter({
    required this.animation, 
    required this.waveColor, 
    this.waveCount = 2,
    this.offset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = waveColor;
    final path = Path();
    
    final baseHeight = size.height * 0.1;
    final frequency = waveCount * math.pi / size.width;
    
    path.moveTo(0, size.height);
    
    for (int i = 0; i <= size.width.toInt(); i++) {
      path.lineTo(
        i.toDouble(),
        size.height - 
          baseHeight * math.sin((animation.value * 360 - i) * frequency + offset),
      );
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
} 