import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DonutChart extends StatelessWidget {
  final double value;
  final double maxValue;
  final String centerText;
  final String bottomText;
  final Color primaryColor;
  
  const DonutChart({
    Key? key,
    required this.value,
    required this.maxValue,
    required this.centerText,
    required this.bottomText,
    this.primaryColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade200.withOpacity(0.5);
    final labelColor = isDarkMode ? Colors.white70 : Colors.grey.shade700;
    final valueColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      value: value,
                      color: primaryColor,
                      radius: 15,
                      showTitle: false,
                    ),
                    if (value < maxValue)
                      PieChartSectionData(
                        value: maxValue - value,
                        color: backgroundColor,
                        radius: 12,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      centerText,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                    Text(
                      '${((value / maxValue) * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Text(
          bottomText,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
} 