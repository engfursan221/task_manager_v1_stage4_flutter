import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/preferences_service.dart';
import 'theme_state.dart';

// ============================================================
// REQUIREMENT: CUBIT
// ThemeCubit manages the application's theme state (Light/Dark).
// Prepared to sync with PreferencesService for persistent storage.
// ============================================================

class ThemeCubit extends Cubit<ThemeState> {
  final PreferencesService _prefs = PreferencesService.instance;

  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light)) {
    loadSavedTheme();
  }

  // Load saved theme preference if available
  void loadSavedTheme() {
    final savedMode = _prefs.getThemeMode();
    if (savedMode == 'dark') {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else if (savedMode == 'light') {
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  // Toggle between Light and Dark mode
  void toggleTheme() {
    if (state.isDarkMode) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }

  // Set Light Mode
  void setLightMode() {
    _prefs.saveThemeMode('light');
    emit(const ThemeState(themeMode: ThemeMode.light));
  }

  // Set Dark Mode
  void setDarkMode() {
    _prefs.saveThemeMode('dark');
    emit(const ThemeState(themeMode: ThemeMode.dark));
  }
}
