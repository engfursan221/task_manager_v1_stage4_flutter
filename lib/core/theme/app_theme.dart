import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

// ============================================================
// REQUIREMENT: THEME
// This centralized AppTheme class provides access to both
// Light and Dark themes for MaterialApp and ThemeCubit.
// ============================================================

class AppTheme {
  AppTheme._();

  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
}
