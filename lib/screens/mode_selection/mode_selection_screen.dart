// ============================================================
// MODE SELECTION SCREEN (V2)
// Allows user to choose between:
// 1. المهام العادية (Normal Tasks from V1) -> /home
// 2. المهام الجامعية (University Tasks from V2) -> /university
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/university_storage_service.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../cubit/theme/theme_cubit.dart';
import '../../cubit/theme/theme_state.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  void _chooseNormalTasks(BuildContext context) {
    UniversityStorageService.instance.saveActiveMode('normal');
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _chooseUniversityTasks(BuildContext context) {
    UniversityStorageService.instance.saveActiveMode('university');
    Navigator.pushReplacementNamed(context, '/university/plans');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل ترغب في تسجيل الخروج من الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار نوع المهام'),
        centerTitle: true,
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting Header
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final email = authState is Authenticated ? authState.email : 'عزيزي الطالب';
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer.withOpacity(0.7),
                          colorScheme.surfaceVariant.withOpacity(0.5),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primary,
                              radius: 20,
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مرحبًا بك في تطبيق الطالب',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'يرجى تحديد نظام إدارة المهام الذي ترغب في استخدامه الآن:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Option 1: Normal Tasks (V1)
              _buildOptionCard(
                context,
                title: 'المهام العادية',
                subtitle: 'إدارة المهام اليومية والشخصية بمرونة للمهام العادية (الغير مرتبطة بوقت محدد).',
                icon: Icons.checklist_rounded,
                accentColor: const Color(0xFF2563EB),
                features: const [
                  'قائمة المهام اليومية والشخصية',
                  'عمليات الإضافة والتعديل والحذف',
                  'نظام الأرشفة للمهام المكتملة',
                  'إحصائيات الإنجاز الشخصي',
                ],
                onTap: () => _chooseNormalTasks(context),
              ),
              const SizedBox(height: 20),

              // Option 2: University Tasks (V2)
              _buildOptionCard(
                context,
                title: 'المهام الجامعية',
                subtitle: 'إدارة المقررات، ومهام المحاضرات النظرية والعملية من حضور ومذاكرة وتكاليف.',
                icon: Icons.account_balance_rounded,
                accentColor: const Color(0xFF059669),
                isHighlight: true,
                features: const [
                  'المقررات الأكاديمية (نظري / عملي)',
                  'سجل المحاضرات وتسجيل الحضور الفعلي',
                  'تصنيف المهام (مذاكرة، تطبيق، واجبات)',
                  'احصاىيات شاملة لحالة جميع المهام',
                ],
                onTap: () => _chooseUniversityTasks(context),
              ),

              const SizedBox(height: 24),
              Text(
                'يمكنك التبديل بين النظامين في أي وقت عبر قائمة الإعدادات أو الشاشة الرئيسية.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<String> features,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isHighlight
                ? colorScheme.primaryContainer.withOpacity(0.35)
                : colorScheme.surfaceVariant.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlight ? colorScheme.primary : colorScheme.outline.withOpacity(0.2),
              width: isHighlight ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text('الدخول إلى $title'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isHighlight ? colorScheme.primary : accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
