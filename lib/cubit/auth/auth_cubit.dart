import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/preferences_service.dart';
import 'auth_state.dart';

// ============================================================
// REQUIREMENT: AUTH CUBIT
// Manages authentication lifecycle:
// - Initial check on startup
// - Login validation & state persistence
// - Logout state cleanup & redirection
// ============================================================

class AuthCubit extends Cubit<AuthState> {
  final PreferencesService _prefs = PreferencesService.instance;

  // Demo credentials for Task Manager V1
  static const String demoEmail = 'student@university.edu';
  static const String demoPassword = 'password123';

  AuthCubit() : super(const AuthInitial());

  // ============================================================
  // REQUIREMENT: SHARED PREFERENCES
  // Persists the user's login state locally.
  // ============================================================
  /// Checks local SharedPreferences on application startup or Splash screen.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    
    // Simulate brief startup check
    await Future.delayed(const Duration(milliseconds: 800));

    final isLoggedIn = _prefs.isUserLoggedIn();
    if (isLoggedIn) {
      final email = _prefs.getUserEmail() ?? demoEmail;
      emit(Authenticated(email: email));
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handles user login with validation and local persistence.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      emit(const AuthError('يرجى إدخال اسم المستخدم/البريد الإلكتروني وكلمة المرور'));
      return false;
    }

    emit(const AuthLoading());

    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Simple demo validation: accepts demo credentials or any valid non-empty login
    final isValidDemo = (cleanEmail == demoEmail && cleanPassword == demoPassword) ||
        (cleanEmail.isNotEmpty && cleanPassword.length >= 4);

    if (isValidDemo) {
      // Persist login state
      await _prefs.saveLoginState(
        isLoggedIn: true,
        email: cleanEmail,
      );

      emit(Authenticated(email: cleanEmail));
      return true;
    } else {
      emit(const AuthError('بيانات الدخول غير صحيحة. يجب أن تتكون كلمة المرور من 4 أحرف على الأقل.'));
      return false;
    }
  }

  // ============================================================
  // REQUIREMENT: LOGOUT
  // Clears the saved login state and returns the user to Login.
  // ============================================================
  Future<void> logout() async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Clear login state in SharedPreferences
    await _prefs.clearLoginSession();

    emit(const Unauthenticated(message: 'تم تسجيل الخروج بنجاح'));
  }

  /// Helper to clear errors and reset to unauthenticated
  void clearError() {
    if (state is AuthError) {
      emit(const Unauthenticated());
    }
  }
}
