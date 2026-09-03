import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/tasks/tasks_cubit.dart';
import '../../cubit/tasks/tasks_state.dart';
import '../../cubit/theme/theme_cubit.dart';
import '../../cubit/theme/theme_state.dart';
import '../../models/task_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/task_card.dart';

// ============================================================
// REQUIREMENT: ARCHIVE SCREEN
// Arabic Archive screen displaying preserved deleted tasks with:
// - Restore action back to active tasks
// - Theme switcher
// - Shared Bottom Navigation Bar (Archive / index 2)
// ============================================================

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرشيف'),
        actions: [
          // Theme switcher
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                tooltip: isDark ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final archivedTasks =
                state is TasksLoaded ? state.archivedTasks : <TaskModel>[];

            // Empty Archive State
            if (archivedTasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.archive_outlined,
                          size: 48,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'الأرشيف فارغ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'عند حذف أي مهمة من قائمة المهام، ستظهر هنا بأمان دون فقدانها.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Archived Tasks List
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 18, color: colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'المهام المحفوظة (${archivedTasks.length})',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: archivedTasks.length,
                    itemBuilder: (context, index) {
                      final task = archivedTasks[index];

                      return TaskCard(
                        task: task,
                        isArchived: true,
                        // Restore task back to active tasks
                        onRestore: () {
                          context.read<TasksCubit>().restoreTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت استعادة "${task.title}" إلى المهام النشطة'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Shared Bottom Navigation Bar (Archive is index 2)
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
