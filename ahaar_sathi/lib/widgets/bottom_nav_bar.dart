import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AhaarSathiBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const AhaarSathiBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final unselectedColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500;
    
    return BottomAppBar(
      elevation: 8,
      notchMargin: 8.0,
      color: backgroundColor,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          boxShadow: isDarkMode 
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              primaryColor: primaryColor,
              unselectedColor: unselectedColor,
            ),
            // Logs
            _buildNavItem(
              context,
              icon: Icons.insights_rounded,
              label: 'Logs',
              index: 1,
              primaryColor: primaryColor,
              unselectedColor: unselectedColor,
            ),
            // Empty space for the centered FAB
            const SizedBox(width: 40),
            // Goals
            _buildNavItem(
              context,
              icon: Icons.track_changes_rounded,
              label: 'Goals',
              index: 2,
              primaryColor: primaryColor,
              unselectedColor: unselectedColor,
            ),
            // Profile
            _buildNavItem(
              context,
              icon: Icons.person_rounded,
              label: 'Profile',
              index: 3,
              primaryColor: primaryColor,
              unselectedColor: unselectedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required Color primaryColor,
    required Color unselectedColor,
  }) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? primaryColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 