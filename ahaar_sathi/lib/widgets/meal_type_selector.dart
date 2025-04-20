import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealTypeSelector extends StatelessWidget {
  final String currentMealType;
  final Function(String) onMealTypeSelected;
  final bool isDarkMode;

  const MealTypeSelector({
    Key? key,
    required this.currentMealType,
    required this.onMealTypeSelected,
    required this.isDarkMode,
  }) : super(key: key);

  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentMealType == 'Select Meal Type' ? null : currentMealType,
          hint: Text(
            'Select Meal Type',
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          items: mealTypes.map((String mealType) {
            return DropdownMenuItem<String>(
              value: mealType,
              child: Row(
                children: [
                  Icon(
                    _getMealTypeIcon(mealType),
                    size: 20,
                    color: _getMealTypeColor(mealType),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    mealType,
                    style: GoogleFonts.inter(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onMealTypeSelected(newValue);
            }
          },
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.wb_sunny;
      case 'dinner':
        return Icons.nights_stay_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 