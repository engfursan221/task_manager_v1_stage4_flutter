import 'package:flutter/material.dart';

// ============================================================
// REQUIREMENT: CUBIT (THEME STATE)
// Defines the state holding the current ThemeMode.
// ============================================================

class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({
    this.themeMode = ThemeMode.light,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
