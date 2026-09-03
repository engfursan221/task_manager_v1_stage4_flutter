import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/tasks/tasks_cubit.dart';
import '../../cubit/tasks/tasks_state.dart';
import '../../cubit/theme/theme_cubit.dart';
import '../../cubit/theme/theme_state.dart';
import '../../models/task_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/task_card.dart';

// ============================================================
// REQUIREMENT: CRUD - READ, CREATE, UPDATE, DELETE/ARCHIVE
// Arabic Tasks list screen with:
// - Bottom Navigation Bar
// - Create / Edit modal dialog with RTL inputs
// - Archive confirmation dialog
// - Complete / Uncomplete toggle
// ============================================================

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المهام'),
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
          // Navigate to Archive Screen
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'عرض الأرشيف',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/archive');
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

            final tasks = state is TasksLoaded ? state.activeTasks : <TaskModel>[];

            // ============================================================
            // REQUIREMENT: CRUD - READ (EMPTY STATE)
            // ============================================================
            if (tasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.task_alt_rounded,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'لا توجد مهام حالياً',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'اضغط على زر (+) بالأسفل لإضافة أول مهمة لك.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditTaskModal(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('إضافة مهمة جديدة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ============================================================
            // REQUIREMENT: CRUD - READ (TASK LIST)
            // Displays list of active tasks using TaskCard widget.
            // ============================================================
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return TaskCard(
                  task: task,
                  onToggleCompleted: (value) {
                    context.read<TasksCubit>().toggleTaskCompletion(task.id);
                  },
                  onEdit: () {
                    _showAddEditTaskModal(context, taskToEdit: task);
                  },
                  onDelete: () {
                    _confirmDeleteTask(context, task);
                  },
                );
              },
            );
          },
        ),
      ),
      // ============================================================
      // REQUIREMENT: CRUD - CREATE FLOATING BUTTON
      // ============================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditTaskModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('مهمة جديدة'),
      ),
      // Shared Bottom Navigation Bar (Tasks is index 1)
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  // ============================================================
  // REQUIREMENT: CRUD - CREATE & UPDATE MODAL (ARABIC / RTL)
  // ============================================================
  void _showAddEditTaskModal(BuildContext context, {TaskModel? taskToEdit}) {
    final isEditing = taskToEdit != null;
    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final descriptionController = TextEditingController(text: taskToEdit?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        final theme = Theme.of(modalContext);
        final colorScheme = theme.colorScheme;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'تعديل المهمة' : 'إنشاء مهمة جديدة',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Task Title Field
                  CustomTextField(
                    label: 'عنوان المهمة',
                    hint: 'مثال: مراجعة الفصل الثالث للامتحان',
                    controller: titleController,
                    prefixIcon: Icon(Icons.title_rounded, color: colorScheme.primary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال عنوان المهمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Task Description Field
                  CustomTextField(
                    label: 'الوصف (اختياري)',
                    hint: 'أضف ملاحظات أو تفاصيل حول المهمة...',
                    controller: descriptionController,
                    maxLines: 3,
                    prefixIcon: Icon(Icons.notes_rounded, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 24),

                  // Action Button (Create / Save)
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        if (isEditing) {
                          context.read<TasksCubit>().updateTask(
                                id: taskToEdit.id,
                                title: titleController.text,
                                description: descriptionController.text,
                              );
                        } else {
                          context.read<TasksCubit>().createTask(
                                title: titleController.text,
                                description: descriptionController.text,
                              );
                        }
                        Navigator.pop(modalContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isEditing ? 'حفظ التعديلات' : 'إضافة المهمة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // REQUIREMENT: ARCHIVE CONFIRMATION (ARABIC / RTL)
  // ============================================================
  void _confirmDeleteTask(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('نقل إلى الأرشيف؟'),
            content: Text(
              'سيتم نقل المهمة "${task.title}" إلى شاشة الأرشيف وحفظها بأمان.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<TasksCubit>().deleteTask(task.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نقل المهمة إلى الأرشيف بنجاح'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'عرض',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/archive');
                        },
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('أرشفة المهمة'),
              ),
            ],
          ),
        );
      },
    );
  }
}
