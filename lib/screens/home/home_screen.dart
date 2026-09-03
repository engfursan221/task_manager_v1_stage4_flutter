import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../cubit/tasks/tasks_cubit.dart';
import '../../cubit/tasks/tasks_state.dart';
import '../../cubit/theme/theme_cubit.dart';
import '../../cubit/theme/theme_state.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/stat_card.dart';

// ============================================================
// REQUIREMENT: HOME DASHBOARD SCREEN
// Fully Arabic Real-time Dashboard connected to TasksCubit:
// - Statistics: Total, Completed, Pending, Archived
// - Quick navigation cards to Tasks and Archive
// - User profile status card
// - System deliverables overview
// - Bottom Navigation Bar (Home, Tasks, Archive, Settings)
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مدير المهام'),
          actions: [
            // Theme toggle action
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                final isDark = themeState.themeMode == ThemeMode.dark;
                return IconButton(
                  icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                  tooltip: isDark ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن',
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                );
              },
            ),
            // Logout action
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'تسجيل الخروج',
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final userEmail = authState is Authenticated
                    ? authState.email
                    : 'student@university.edu';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person_rounded,
                              size: 26,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تم تسجيل الدخول كـ',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'نشط',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ============================================================
                    // REQUIREMENT: REAL-TIME DASHBOARD STATISTICS
                    // Displays total, completed, pending, and archived task counts
                    // dynamically updating with TasksCubit state.
                    // ============================================================
                    BlocBuilder<TasksCubit, TasksState>(
                      builder: (context, tasksState) {
                        final activeTasks = tasksState is TasksLoaded
                            ? tasksState.activeTasks
                            : [];
                        final totalActive = activeTasks.length;
                        final completedCount =
                            activeTasks.where((t) => t.isCompleted).length;
                        final pendingCount = totalActive - completedCount;
                        final archivedCount = tasksState is TasksLoaded
                            ? tasksState.archivedTasks.length
                            : 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'لوحة البيانات والإحصائيات',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'إجمالي: ${totalActive + archivedCount}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Grid of 4 Real-time Statistics Cards
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                              children: [
                                StatCard(
                                  title: 'إجمالي المهام',
                                  count: totalActive,
                                  icon: Icons.assignment_outlined,
                                  color: const Color(0xFF2563EB),
                                  onTap: () => Navigator.pushReplacementNamed(context, '/tasks'),
                                ),
                                StatCard(
                                  title: 'المهام المكتملة',
                                  count: completedCount,
                                  icon: Icons.check_circle_outline_rounded,
                                  color: const Color(0xFF059669),
                                  onTap: () => Navigator.pushReplacementNamed(context, '/tasks'),
                                ),
                                StatCard(
                                  title: 'المهام المعلقة',
                                  count: pendingCount,
                                  icon: Icons.schedule_rounded,
                                  color: const Color(0xFFD97706),
                                  onTap: () => Navigator.pushReplacementNamed(context, '/tasks'),
                                ),
                                StatCard(
                                  title: 'المهام المؤرشفة',
                                  count: archivedCount,
                                  icon: Icons.archive_outlined,
                                  color: const Color(0xFF7C3AED),
                                  onTap: () => Navigator.pushReplacementNamed(context, '/archive'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Quick Navigation Card 1: Active Tasks (CRUD Entry)
                            InkWell(
                              onTap: () => Navigator.pushReplacementNamed(context, '/tasks'),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.checklist_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'إدارة المهام (CRUD)',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$totalActive مهمة نشطة ($completedCount مكتملة)',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Quick Navigation Card 2: Archive Entry
                            InkWell(
                              onTap: () => Navigator.pushReplacementNamed(context, '/archive'),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.archive_outlined,
                                        color: colorScheme.secondary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'أرشيف المهام المحذوفة',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$archivedCount مهمة في الأرشيف',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Deliverables & System Status Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الميزات المكتملة في التطبيق',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCheckRow(context, 'إضافة المهام: إنشاء مهمة جديدة بالعنوان والوصف'),
                            _buildCheckRow(context, 'عرض المهام: استعراض المهام عبر بطاقات TaskCard'),
                            _buildCheckRow(context, 'تعديل المهام: تعديل البيانات وتبديل حالة الإكمال'),
                            _buildCheckRow(context, 'الحذف والأرشفة: حفظ المهام المحذوفة في الأرشيف بأمان'),
                            _buildCheckRow(context, 'إدارة الحالة: تفاعل سلس وتحديث فوري عبر TasksCubit'),
                            _buildCheckRow(context, 'دعم العربية والـ RTL: واجهة عربية متكاملة وشريط تنقل موحد'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logout Action Button
                    OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('تسجيل الخروج من الجلسة'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // Shared Bottom Navigation Bar
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildCheckRow(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            size: 15,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟ سيتم مسح جلسة الدخول الحالية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
