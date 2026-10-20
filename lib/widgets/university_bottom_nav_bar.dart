// ============================================================
// UNIVERSITY BOTTOM NAVIGATION BAR (V2)
// Bottom Navigation Bar for University Tasks module:
// - الرئيسية (index 0) -> /university
// - المقررات (index 1) -> /university/courses
// - اليوم (index 2) -> /university/today
// - الأسبوع (index 3) -> /university/week
// - الإعدادات (index 4) -> /settings
// ============================================================

import 'package:flutter/material.dart';

class UniversityBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const UniversityBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/university');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/university/courses');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/university/today');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/university/week');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'المقررات',
        ),
        NavigationDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today_rounded),
          label: 'اليوم',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_view_week_outlined),
          selectedIcon: Icon(Icons.calendar_view_week_rounded),
          label: 'الأسبوع',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'الإعدادات',
        ),
      ],
    );
  }
}
