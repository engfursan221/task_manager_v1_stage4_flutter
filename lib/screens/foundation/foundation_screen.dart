import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/theme/theme_cubit.dart';
import '../../cubit/theme/theme_state.dart';

// ============================================================
// REQUIREMENT: FOUNDATION SCREEN
// Arabic verification screen to validate:
// 1. Flutter app execution
// 2. Theme switching (Light / Dark Mode via ThemeCubit)
// 3. Components readiness
// ============================================================

class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدير المهام V1'),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                tooltip: state.isDarkMode ? 'التبديل للوضع الفاتح' : 'التبديل للوضع الداكن',
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: colorScheme.primary,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Badge Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 44,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title & Version
                  Text(
                    'مدير المهام',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الإصدار 1.0 (عربي)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المرحلة التأسيسية المتكاملة',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Foundation Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'حالة المكونات الجاهزة',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildStatusItem(context, 'إدارة الحالة باستخدام Cubit', 'ThemeCubit, AuthCubit, TasksCubit'),
                          _buildStatusItem(context, 'ثيمات Material 3', 'الوضع الفاتح والداكن مهيأ بالكامل'),
                          _buildStatusItem(context, 'التخزين المحلي', 'PreferencesService لحفظ الجلسة'),
                          _buildStatusItem(context, 'نموذج البيانات', 'TaskModel (العنوان، الوصف، حالة الإكمال)'),
                          _buildStatusItem(context, 'مسارات التنقل', '/login, /home, /tasks, /archive, /settings'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Theme Switcher Interactive Controller
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        icon: Icon(
                          state.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        ),
                        label: Text(
                          state.isDarkMode ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن',
                        ),
                        onPressed: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
