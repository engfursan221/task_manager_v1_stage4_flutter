import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/storage/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/tasks/tasks_cubit.dart';
import 'cubit/theme/theme_cubit.dart';
import 'cubit/theme/theme_state.dart';

import 'screens/archive/archive_screen.dart';
import 'screens/foundation/foundation_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tasks/tasks_screen.dart';

// ============================================================
// REQUIREMENT: ENTRY POINT (MAIN.DART)
// Responsible for:
// 1. Initializing core services (WidgetsFlutterBinding, Preferences)
// 2. MultiBlocProvider to inject ThemeCubit, AuthCubit, TasksCubit
// 3. MaterialApp with Arabic RTL, Light/Dark Themes and Named Routes
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences service
  await PreferencesService.instance.init();

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // REQUIREMENT: CUBIT PROVIDERS
    // MultiBlocProvider provides Cubits across the widget tree.
    // ============================================================
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<TasksCubit>(
          create: (context) => TasksCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          // ============================================================
          // REQUIREMENT: THEME & RTL LOCALIZATION
          // Configured with Arabic locale and Directionality RTL
          // ============================================================
          return MaterialApp(
            title: 'مدير المهام',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            locale: const Locale('ar'),

            // Wrap MaterialApp content with RTL Directionality
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },

            // Startup check flow (Splash)
            home: const SplashScreen(),

            // ============================================================
            // REQUIREMENT: NAVIGATION / ROUTES
            // Named routes configured for all project screens.
            // ============================================================
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/tasks': (context) => const TasksScreen(),
              '/archive': (context) => const ArchiveScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/foundation': (context) => const FoundationScreen(),
            },
          );
        },
      ),
    );
  }
}
