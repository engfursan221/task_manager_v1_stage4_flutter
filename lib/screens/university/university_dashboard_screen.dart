// ============================================================
// UNIVERSITY DASHBOARD SCREEN (V2)
// Main University Overview displaying:
// - Active Study Plan Selector (ربط إحصائيات الرئيسية بالخطة النشطة)
// - Aggregate Statistics for Active Plan only
// - Cancellation-aware Attendance Metrics
// - Quick navigation to Plans, Courses, Today, Week
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
import 'courses_screen.dart';
import 'plans_screen.dart';

class UniversityDashboardScreen extends StatelessWidget {
  const UniversityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم الجامعية', style: TextStyle(fontWeight: FontWeight.bold)),
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
      bottomNavigationBar: const UniversityBottomNavBar(currentIndex: 0),
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

            if (state is! UniversityLoaded) {
              return const SizedBox.shrink();
            }

            final activePlan = state.activePlan;
            final activePlans = state.activePlans;

            // Empty state if no study plans exist
            if (activePlan == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.layers_outlined, size: 64, color: Colors.blue.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد خطة دراسية حالياً',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أنشئ خطتك الدراسية الأولى لبدء إضافة المقررات ومتابعة الحضور وإنجاز المحاضرات.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PlansScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('إنشاء خطة دراسية'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final percent = (state.overallProgress * 100).toStringAsFixed(1);
            final attendancePct = state.attendanceRate.toStringAsFixed(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Plan Selector Strip
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.layers_rounded, color: Colors.blue.shade700, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الخطة الدراسية النشطة:',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activePlan.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (activePlans.length > 1) ...[
                            DropdownButton<String>(
                              value: state.activePlanId,
                              underline: const SizedBox.shrink(),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: activePlans.map((p) {
                                return DropdownMenuItem(
                                  value: p.id,
                                  child: Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  context.read<UniversityCubit>().setActivePlan(id);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PlansScreen()),
                              );
                            },
                            child: const Text('الخطط', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Progress Banner Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.surfaceContainerHighest,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'نسبة التقدم الأكاديمي للخطة',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$percent%',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: state.overallProgress,
                            minHeight: 10,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تم تسجيل ${state.recordedLectures} من ${state.totalLectures} محاضرة',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (state.totalCancelled > 0)
                              Text(
                                '(${state.totalCancelled} ملغاة مستبعدة)',
                                style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Header: Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إحصائيات الخطة النشطة',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'نسبة الحضور: $attendancePct%',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4 Primary Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'المقررات',
                          count: state.totalCourses,
                          icon: Icons.menu_book_rounded,
                          color: Colors.blue.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoursesScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'المحاضرات',
                          count: state.totalLectures,
                          icon: Icons.calendar_month_rounded,
                          color: Colors.indigo.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoursesScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'حاضر',
                          count: state.totalPresent,
                          icon: Icons.check_circle_rounded,
                          color: Colors.green.shade600,
                          onTap: () => Navigator.pushNamed(context, '/university_today'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'غياب',
                          count: state.totalAbsent,
                          icon: Icons.cancel_rounded,
                          color: Colors.red.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoursesScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tasks Breakdown Row
                  const Text(
                    'إحصائيات المهام الأكاديمية للخطة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTaskPill(
                        label: 'إجمالي المهام',
                        value: state.totalTasks,
                        color: Colors.blue,
                        context: context,
                      ),
                      const SizedBox(width: 8),
                      _buildTaskPill(
                        label: 'المكتملة',
                        value: state.completedTasks,
                        color: Colors.green,
                        context: context,
                      ),
                      const SizedBox(width: 8),
                      _buildTaskPill(
                        label: 'المعلقة',
                        value: state.pendingTasks,
                        color: Colors.orange,
                        context: context,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Quick Access Section
                  const Text(
                    'الوصول السريع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),

                  // 1. Manage Study Plans
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.layers_outlined,
                    iconColor: Colors.blue.shade600,
                    title: 'إدارة الخطط الدراسية (${state.plans.length})',
                    subtitle: 'إنشاء الخطط الأكاديمية والتبديل بين الفصول والأرشيف',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlansScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Courses
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.book_outlined,
                    iconColor: Colors.teal.shade600,
                    title: 'مقررات الخطة النشطة (${state.totalCourses})',
                    subtitle: '${state.totalCreditHours} ساعة معتمدة • تفاصيل النظري والعملي والتقييمات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursesScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Today Tasks
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.today_rounded,
                    iconColor: Colors.indigo.shade600,
                    title: 'يومية (المحاضرات التي سجلت اليوم)',
                    subtitle: 'عرض وتصنيف مهام المحاضرات المسجلة لتاريخ اليوم',
                    onTap: () => Navigator.pushNamed(context, '/university_today'),
                  ),
                  const SizedBox(height: 10),

                  // 4. Weekly Tasks
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.date_range_rounded,
                    iconColor: Colors.purple.shade600,
                    title: 'أسبوعية (محاضرات الأسبوع الحالي)',
                    subtitle: 'عرض منظم حسب اليوم -> المقرر -> المحاضرة -> المهام',
                    onTap: () => Navigator.pushNamed(context, '/university_week'),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskPill({
    required String label,
    required int value,
    required MaterialColor color,
    required BuildContext context,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.shade200),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
