// ============================================================
// WEEKLY TASKS SCREEN (V2)
// Displays tasks of lectures recorded during the selected week:
// - Organized hierarchically: اليوم (Day) -> المقرر (Course) -> المحاضرة (Lecture) -> المهام (Tasks)
// - Categorized: مذاكرة، تطبيق، واجبات
// - Bottom Navigation: UniversityBottomNavBar (index 3)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/lecture_model.dart';
import '../../models/university_task_model.dart';
import '../../widgets/university_bottom_nav_bar.dart';

class WeeklyTasksScreen extends StatefulWidget {
  const WeeklyTasksScreen({super.key});

  @override
  State<WeeklyTasksScreen> createState() => _WeeklyTasksScreenState();
}

class _WeeklyTasksScreenState extends State<WeeklyTasksScreen> {
  int _weekOffset = 0; // 0 = current week, -1 = last week, 1 = next week

  // Get list of 7 dates in the week based on offset
  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    // Start of week (Saturday as common in Arab region, or current day minus offset)
    final base = now.add(Duration(days: _weekOffset * 7));
    final weekday = base.weekday; // 1 = Monday, 7 = Sunday
    // Let's normalize so week runs from Saturday to Friday or Sunday to Thursday
    final startOfWeek = base.subtract(Duration(days: (weekday % 7)));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  String _getDayNameArabic(int weekday) {
    switch (weekday) {
      case 7:
        return 'الأحد';
      case 1:
        return 'الإثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weekDates = _getWeekDates();
    final weekDateStrings = weekDates.map((d) => UniversityCubit.formatDate(d)).toSet();

    final startDateStr = UniversityCubit.formatDate(weekDates.first);
    final endDateStr = UniversityCubit.formatDate(weekDates.last);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مهام الأسبوع'),
      ),
      body: SafeArea(
        child: BlocBuilder<UniversityCubit, UniversityState>(
          builder: (context, state) {
            if (state is! UniversityLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            // Get all recorded lectures in this week
            final weekLectures = state.getLecturesRecordedInDates(weekDateStrings);

            return Column(
              children: [
                // Week Navigator Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    border: Border(bottom: BorderSide(color: colorScheme.outline.withOpacity(0.12))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        tooltip: 'الأسبوع السابق',
                        onPressed: () => setState(() => _weekOffset--),
                      ),
                      Column(
                        children: [
                          Text(
                            _weekOffset == 0 ? 'الأسبوع الحالي' : (_weekOffset < 0 ? 'منذ ${-_weekOffset} أسبوع' : 'بعد $_weekOffset أسبوع'),
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$startDateStr  إلى  $endDateStr',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        tooltip: 'الأسبوع التالي',
                        onPressed: () => setState(() => _weekOffset++),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: weekLectures.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_note_rounded, size: 52, color: colorScheme.primary.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد محاضرات مسجلة خلال هذا الأسبوع',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'تسجيل حضورك أو غيابك للمحاضرات في الأيام الدراسية سيقوم بإظهار مهامها هنا تلقائيًا.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: weekDates.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final date = weekDates[index];
                            final dateStr = UniversityCubit.formatDate(date);
                            final lecturesForDay = weekLectures.where((l) => l.lectureDate == dateStr).toList();

                            if (lecturesForDay.isEmpty) return const SizedBox.shrink();

                            return _buildDayCard(context, date, dateStr, lecturesForDay);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const UniversityBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildDayCard(BuildContext context, DateTime date, String dateStr, List<LectureModel> lectures) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayName = _getDayNameArabic(date.weekday);

    // Group lectures by course
    final Map<String, List<LectureModel>> byCourse = {};
    for (final l in lectures) {
      byCourse.putIfAbsent(l.courseName, () => []).add(l);
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '$dayName  •  $dateStr',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${lectures.length} محاضرة',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Course -> Lecture -> Tasks
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: byCourse.entries.map((entry) {
                final courseName = entry.key;
                final courseLectures = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Label
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            courseName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Lectures in Course
                      ...courseLectures.map((lecture) => _buildLectureTasks(context, lecture)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureTasks(BuildContext context, LectureModel lecture) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<UniversityCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10, right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lecture title & Attendance badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lecture.title} (${lecture.section.displayName})',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: lecture.isPresent
                      ? const Color(0xFF059669).withOpacity(0.15)
                      : const Color(0xFFDC2626).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lecture.attendanceStatus.displayName,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: lecture.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tasks List
          if (lecture.tasks.isEmpty)
            Text(
              'لا توجد مهام محددة لهذه المحاضرة',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            )
          else
            ...lecture.tasks.map((task) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        final nextStatus = task.status == UniversityTaskStatus.notStarted
                            ? UniversityTaskStatus.inProgress
                            : (task.status == UniversityTaskStatus.inProgress
                                ? UniversityTaskStatus.completed
                                : UniversityTaskStatus.notStarted);
                        cubit.updateTaskStatus(
                          courseId: lecture.courseId,
                          lectureId: lecture.id,
                          taskId: task.id,
                          status: nextStatus,
                        );
                      },
                      child: Icon(
                        task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: task.isCompleted ? const Color(0xFF059669) : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.category.displayName,
                        style: TextStyle(fontSize: 9.5, color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
