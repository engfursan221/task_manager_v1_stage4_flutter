// ============================================================
// UNIVERSITY DASHBOARD SCREEN (V2)
// Main University Overview displaying:
// - Aggregate Statistics (Courses, Lectures, Recorded, Present, Absent, Completed, Pending, Progress)
// - Quick navigation to Courses, Today, Week
// - Bottom Navigation: UniversityBottomNavBar (index 0)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/theme/theme_cubit.dart';
import '../../cubit/theme/theme_state.dart';
import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/university_bottom_nav_bar.dart';

class UniversityDashboardScreen extends StatelessWidget {
  const UniversityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم الجامعية'),
        actions: [
          // Switch to Normal Tasks Mode
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('المهام العادية'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          // Theme Switcher
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
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<UniversityCubit, UniversityState>(
          listener: (context, state) {
            if (state is UniversityLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is UniversityLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UniversityError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                      const SizedBox(height: 12),
                      Text(state.errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.read<UniversityCubit>().loadUniversityData(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state is UniversityLoaded
                ? state
                : const UniversityLoaded(courses: []);

            final percent = (loaded.overallProgress * 100).toStringAsFixed(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Banner Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.surfaceVariant,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'نسبة التقدم في مهام هذا الترم  ',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$percent%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: loaded.overallProgress.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'تم تسجيل حضور/غياب ${loaded.recordedLectures} من إجمالي ${loaded.totalLectures} محاضرة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header: Core Statistics
                  Text(
                    'إحصائيات المقررات والحضور',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4 Primary Stats: Courses, Total Lectures, Present, Absent
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        title: 'عدد المقررات',
                        count: loaded.totalCourses,
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF2563EB),
                        onTap: () => Navigator.pushReplacementNamed(context, '/university/courses'),
                      ),
                      StatCard(
                        title: 'إجمالي المحاضرات',
                        count: loaded.totalLectures,
                        icon: Icons.play_lesson_outlined,
                        color: const Color(0xFF4F46E5),
                        onTap: () => Navigator.pushReplacementNamed(context, '/university/courses'),
                      ),
                      StatCard(
                        title: 'عدد مرات الحضور',
                        count: loaded.totalPresent,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF059669),
                        onTap: () => Navigator.pushReplacementNamed(context, '/university/today'),
                      ),
                      StatCard(
                        title: 'عدد مرات الغياب',
                        count: loaded.totalAbsent,
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFDC2626),
                        onTap: () => Navigator.pushReplacementNamed(context, '/university/courses'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Header: Tasks Statistics
                  Text(
                    'إحصائيات مهام المحاضرات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3 Tasks Stats: Total Tasks, Completed, Pending
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallStat(
                          context,
                          label: 'إجمالي المهام',
                          value: loaded.totalTasks,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallStat(
                          context,
                          label: 'المهام المكتملة',
                          value: loaded.completedTasks,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallStat(
                          context,
                          label: 'المهام غير المكتملة',
                          value: loaded.pendingTasks,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Access Cards
                  _buildQuickCard(
                    context,
                    title: 'إدارة المقررات الدراسية',
                    subtitle: '${loaded.totalCourses} مقرر مسجل مع تفاصيل المهام للنظري والعملي',
                    icon: Icons.book_outlined,
                    color: colorScheme.primary,
                    route: '/university/courses',
                  ),
                  const SizedBox(height: 10),
                  _buildQuickCard(
                    context,
                    title: 'يومية (المحاضرات التي سجلت اليوم)',
                    subtitle: 'عرض المهام الخاصة بالمحاضرات المسجلة لتاريخ اليوم',
                    icon: Icons.today_rounded,
                    color: const Color(0xFF059669),
                    route: '/university/today',
                  ),
                  const SizedBox(height: 10),
                  _buildQuickCard(
                    context,
                    title: 'اسبوعية (محاضرات الاسبوع الحالي )',
                    subtitle: 'عرض منظم حسب اليوم -> المقرر -> المحاضرة -> المهام',
                    icon: Icons.calendar_view_week_rounded,
                    color: const Color(0xFF7C3AED),
                    route: '/university/week',
                  ),
                  const SizedBox(height: 18),


                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const UniversityBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildSmallStat(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
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
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
