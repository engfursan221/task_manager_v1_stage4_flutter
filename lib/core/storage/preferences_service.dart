import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// REQUIREMENT: SHARED PREFERENCES
// Persists the user's login state locally.
// ============================================================

class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  PreferencesService._();

  // Singleton pattern for centralized access
  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  // Storage keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserEmail = 'user_email';

  // Initialize SharedPreferences instance
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // ------------------------------------------------------------
  // Authentication & Session Persistence
  // ------------------------------------------------------------

  /// Saves user login state and email upon successful authentication.
  Future<bool> saveLoginState({required bool isLoggedIn, String? email}) async {
    if (_preferences == null) await init();
    if (email != null && email.isNotEmpty) {
      await _preferences?.setString(keyUserEmail, email);
    }
    return await _preferences?.setBool(keyIsLoggedIn, isLoggedIn) ?? false;
  }

  /// Checks if the user is currently logged in.
  bool isUserLoggedIn() {
    return _preferences?.getBool(keyIsLoggedIn) ?? false;
  }

  /// Returns the saved user email or username.
  String? getUserEmail() {
    return _preferences?.getString(keyUserEmail);
  }

  /// Clears the login session on logout.
  Future<bool> clearLoginSession() async {
    if (_preferences == null) await init();
    await _preferences?.remove(keyUserEmail);
    return await _preferences?.setBool(keyIsLoggedIn, false) ?? false;
  }

  // ------------------------------------------------------------
  // Theme Preferences
  // ------------------------------------------------------------

  Future<bool> saveThemeMode(String mode) async {
    if (_preferences == null) await init();
    return await _preferences?.setString(keyThemeMode, mode) ?? false;
  }

  String? getThemeMode() {
    return _preferences?.getString(keyThemeMode);
  }

  // Clear all cached preferences
  Future<bool> clearAll() async {
    if (_preferences == null) await init();
    return await _preferences?.clear() ?? false;
  }
}

