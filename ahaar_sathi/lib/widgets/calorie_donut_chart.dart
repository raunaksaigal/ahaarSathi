import 'dart:math';
import 'package:flutter/material.dart';

class CalorieDonutChart extends StatelessWidget {
  final double consumed;
  final double total;
  final double size;
  final double thickness;
  final bool showText;
  final bool showIcon;
  
  const CalorieDonutChart({
    Key? key,
    required this.consumed,
    required this.total,
    this.size = 120,
    this.thickness = 12,
    this.showText = true,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progress = total > 0 ? min(consumed / total, 1.0) : 0.0;
    
    // Colors based on theme
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final progressColor = _getProgressColor(progress);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(
              progress: 1.0,
              color: backgroundColor!,
              thickness: thickness,
            ),
          ),
          
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(
              progress: progress,
              color: progressColor,
              thickness: thickness,
            ),
          ),
          
          // Center content
          if (showText || showIcon)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showIcon)
                    Icon(
                      Icons.local_fire_department,
                      color: progressColor,
                      size: size * 0.2,
                    ),
                  if (showText) ...[
                    if (showIcon) SizedBox(height: 4),
                    Text(
                      '${consumed.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.18,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'of ${total.toInt()}',
                      style: TextStyle(
                        fontSize: size * 0.1,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Returns a color based on the progress value
  Color _getProgressColor(double progress) {
    if (progress >= 0.95) {
      return Colors.red;  // Over or at goal
    } else if (progress >= 0.75) {
      return Colors.orange;  // Near goal
    } else {
      return Colors.green;  // Under goal
    }
  }
}

class _DonutChartPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double thickness;
  
  _DonutChartPainter({
    required this.progress,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // The background arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    
    // Calculate the sweep angle for the progress
    final sweepAngle = 2 * pi * progress;
    
    // Draw the arc
    canvas.drawArc(
      rect,
      -pi / 2, // Start from the top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness;
  }
}

// Usage example for both light and dark themes
class CalorieDonutChartExample extends StatelessWidget {
  final double consumed;
  final double total;
  
  const CalorieDonutChartExample({
    Key? key,
    required this.consumed,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          Text(
            'Calories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Daily intake',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Donut chart
          Center(
            child: CalorieDonutChart(
              consumed: consumed,
              total: total,
              size: 150,
              thickness: 15,
              showText: true,
              showIcon: true,
            ),
          ),
          
          // Progress text
          const SizedBox(height: 16),
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          LinearProgressIndicator(
            value: total > 0 ? min(consumed / total, 1.0) : 0.0,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(consumed / total),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          
          // Additional stats
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Carbs', '${(consumed * 0.5).toInt()} g', textColor, isDarkMode),
              _buildStat('Protein', '${(consumed * 0.3).toInt()} g', textColor, isDarkMode),
              _buildStat('Fat', '${(consumed * 0.2).toInt()} g', textColor, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper method to build stat items
  Widget _buildStat(String label, String value, Color textColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
  
  // Returns a color based on the progress value
  Color _getProgressColor(double progress) {
    if (progress >= 0.95) {
      return Colors.red;  // Over or at goal
    } else if (progress >= 0.75) {
      return Colors.orange;  // Near goal
    } else {
      return Colors.green;  // Under goal
    }
  }
} 