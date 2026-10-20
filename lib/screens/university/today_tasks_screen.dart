// ============================================================
// TODAY TASKS SCREEN (V2)
// Displays tasks of lectures where attendance (حاضر / غائب)
// was recorded for the selected day (defaults to today):
// - Categorized clearly into: مذاكرة، تطبيق، واجبات (and others)
// - Attendance and absence do NOT appear as tasks (Rule 7, 13)
// - Lectures without recorded attendance do NOT show their tasks
// - Bottom Navigation: UniversityBottomNavBar (index 2)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/lecture_model.dart';
import '../../models/university_task_model.dart';
import '../../widgets/university_bottom_nav_bar.dart';
import 'lecture_details_screen.dart';

class TodayTasksScreen extends StatefulWidget {
  const TodayTasksScreen({super.key});

  @override
  State<TodayTasksScreen> createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends State<TodayTasksScreen> {
  late String _selectedDateString;

  @override
  void initState() {
    super.initState();
    _selectedDateString = UniversityCubit.getTodayString();
  }

  void _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_selectedDateString) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _selectedDateString = UniversityCubit.formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = _selectedDateString == UniversityCubit.getTodayString();

    return Scaffold(
      appBar: AppBar(
        title: Text(isToday ? 'مهام اليوم' : 'مهام تاريخ: $_selectedDateString'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'تغيير التاريخ',
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<UniversityCubit, UniversityState>(
          builder: (context, state) {
            if (state is! UniversityLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            // Get recorded lectures for this date
            final recordedLectures = state.getLecturesRecordedOn(_selectedDateString);

            // If no recorded lectures on this day
            if (recordedLectures.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_busy_rounded, size: 52, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'لا توجد محاضرات مسجلة لتاريخ $_selectedDateString',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تظهر المهام اليومية فقط للمحاضرات التي قمت بتسجيل حضورك أو غيابك فيها لهذا اليوم.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/university/courses'),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('الانتقال إلى المقررات لتسجيل الحضور'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Extract all tasks with their parent lecture info
            final List<_TaskItemContext> allTasksWithContext = [];
            for (final lecture in recordedLectures) {
              for (final task in lecture.tasks) {
                allTasksWithContext.add(_TaskItemContext(lecture: lecture, task: task));
              }
            }

            // Group tasks by category
            // Priority Categories according to Rule 13:
            // 1. مذاكرة (Study)
            // 2. تطبيق (Practice)
            // 3. واجبات (Homework)
            // 4. أخرى (ملخص ومراجعة ومخصصة)
            final studyTasks = allTasksWithContext
                .where((item) => item.task.category == UniversityTaskCategory.study)
                .toList();

            final practiceTasks = allTasksWithContext
                .where((item) => item.task.category == UniversityTaskCategory.practice)
                .toList();

            final homeworkTasks = allTasksWithContext
                .where((item) => item.task.category == UniversityTaskCategory.homework)
                .toList();

            final otherTasks = allTasksWithContext
                .where((item) =>
                    item.task.category != UniversityTaskCategory.study &&
                    item.task.category != UniversityTaskCategory.practice &&
                    item.task.category != UniversityTaskCategory.homework)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lectures Recorded Header Strip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المحاضرات المسجلة في هذا اليوم (${recordedLectures.length}):',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: recordedLectures.map((l) {
                            return ActionChip(
                              avatar: Icon(
                                l.isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 16,
                                color: l.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                              label: Text('${l.courseName} - ${l.title}'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => LectureDetailsScreen(
                                      courseId: l.courseId,
                                      lectureId: l.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category 1: مذاكرة
                  if (studyTasks.isNotEmpty) ...[
                    _buildCategorySection(
                      context,
                      title: 'مذاكرة',
                      tasks: studyTasks,
                      icon: Icons.auto_stories_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Category 2: تطبيق
                  if (practiceTasks.isNotEmpty) ...[
                    _buildCategorySection(
                      context,
                      title: 'تطبيق عملي',
                      tasks: practiceTasks,
                      icon: Icons.terminal_rounded,
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Category 3: واجبات
                  if (homeworkTasks.isNotEmpty) ...[
                    _buildCategorySection(
                      context,
                      title: 'واجبات',
                      tasks: homeworkTasks,
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Category 4: ملخصات ومراجعات أخرى
                  if (otherTasks.isNotEmpty) ...[
                    _buildCategorySection(
                      context,
                      title: 'ملخصات ومراجعات',
                      tasks: otherTasks,
                      icon: Icons.note_alt_rounded,
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const UniversityBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required List<_TaskItemContext> tasks,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<UniversityCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              '$title (${tasks.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = tasks[index];
            final task = item.task;
            final lecture = item.lecture;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: task.isCompleted
                      ? const Color(0xFF059669).withOpacity(0.3)
                      : colorScheme.outline.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  // Status Cycler Checkbox
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
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        task.status == UniversityTaskStatus.completed
                            ? Icons.check_circle_rounded
                            : (task.status == UniversityTaskStatus.inProgress
                                ? Icons.timelapse_rounded
                                : Icons.radio_button_unchecked_rounded),
                        color: task.status == UniversityTaskStatus.completed
                            ? const Color(0xFF059669)
                            : (task.status == UniversityTaskStatus.inProgress
                                ? const Color(0xFFD97706)
                                : colorScheme.onSurfaceVariant),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title & Course/Lecture reference
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lecture.courseName} • ${lecture.title}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.status.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TaskItemContext {
  final LectureModel lecture;
  final UniversityTaskModel task;

  const _TaskItemContext({required this.lecture, required this.task});
}
