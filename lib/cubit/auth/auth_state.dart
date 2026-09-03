// ============================================================
// REQUIREMENT: AUTH CUBIT STATES
// Authentication lifecycle states for Stage 2:
// - AuthInitial: Initial state before checking session
// - AuthLoading: State during authentication / async check
// - Authenticated: User successfully logged in
// - Unauthenticated: No active session or after logout
// - AuthError: Authentication failure (e.g. invalid credentials)
// ============================================================

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String email;
  final String? userId;

  const Authenticated({
    required this.email,
    this.userId,
  });
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});
}

class AuthError extends AuthState {
  final String errorMessage;

  const AuthError(this.errorMessage);
}
