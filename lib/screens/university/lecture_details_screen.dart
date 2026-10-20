// ============================================================
// LECTURE DETAILS SCREEN (V2)
// Displays comprehensive lecture details:
// - Course Name, Section (نظري / عملي), Lecture Number
// - Attendance registration (حاضر / غائب) with automatic today's date stamp
// - Lecture Notes editor (الملاحظات مرتبطة بالمحاضرة وليست مهمة)
// - Lecture Tasks CRUD (Create, Read, Update status, Delete)
// - Categories: مذاكرة، تطبيق، تكاليف، ملخص، مراجعة، مهمة مخصصة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/lecture_model.dart';
import '../../models/university_task_model.dart';

class LectureDetailsScreen extends StatefulWidget {
  final String courseId;
  final String lectureId;

  const LectureDetailsScreen({
    super.key,
    required this.courseId,
    required this.lectureId,
  });

  @override
  State<LectureDetailsScreen> createState() => _LectureDetailsScreenState();
}

class _LectureDetailsScreenState extends State<LectureDetailsScreen> {
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    context.read<UniversityCubit>().updateLectureNotes(
          courseId: widget.courseId,
          lectureId: widget.lectureId,
          notes: _notesController.text.trim(),
        );
    setState(() {
      _isEditingNotes = false;
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _TaskFormSheet(
        courseId: widget.courseId,
        lectureId: widget.lectureId,
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, UniversityTaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _TaskFormSheet(
        courseId: widget.courseId,
        lectureId: widget.lectureId,
        taskToEdit: task,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<UniversityCubit, UniversityState>(
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
        if (state is! UniversityLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final course = state.getCourse(widget.courseId);
        final lecture = state.getLecture(widget.courseId, widget.lectureId);

        if (course == null || lecture == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل المحاضرة')),
            body: const Center(child: Text('المحاضرة المطلوبة غير موجودة')),
          );
        }

        // Keep notes controller in sync when not editing
        if (!_isEditingNotes && _notesController.text != lecture.notes) {
          _notesController.text = lecture.notes;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${lecture.title} - ${course.name}'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lecture Header Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lecture.section.displayName,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'المحاضر: ${course.instructorName.isNotEmpty ? course.instructorName : "غير محدد"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ============================================================
                  // ATTENDANCE & ABSENCE SECTION
                  // Rule 6: In the day student attends lecture, records حاضر or غائب.
                  // Rule 7: Attendance is NOT a task.
                  // Rule 8: Automatically sets lectureDate = today
                  // ============================================================
                  _buildAttendanceCard(context, lecture),
                  const SizedBox(height: 20),

                  // ============================================================
                  // NOTES SECTION (مرتبطة بالمحاضرة مباشرة)
                  // ============================================================
                  _buildNotesCard(context, lecture),
                  const SizedBox(height: 20),

                  // ============================================================
                  // LECTURE TASKS CRUD SECTION
                  // ============================================================
                  _buildTasksSection(context, lecture),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard(BuildContext context, LectureModel lecture) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<UniversityCubit>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_reg_rounded, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'تسجيل الحضور والغياب للمحاضرة',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'حدد حالتك عند تلقي المحاضرة، وسيتم تسجيل تاريخ اليوم تلقائيًا وربط مهامها بالعرض اليومي.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: حاضر / غائب / إعادة الضبط
          Row(
            children: [
              // Present Button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    cubit.recordAttendance(
                      courseId: widget.courseId,
                      lectureId: widget.lectureId,
                      status: AttendanceStatus.present,
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('حاضر'),
                  style: FilledButton.styleFrom(
                    backgroundColor: lecture.isPresent ? const Color(0xFF059669) : Colors.grey.withOpacity(0.2),
                    foregroundColor: lecture.isPresent ? Colors.white : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Absent Button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    cubit.recordAttendance(
                      courseId: widget.courseId,
                      lectureId: widget.lectureId,
                      status: AttendanceStatus.absent,
                    );
                  },
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  label: const Text('غائب'),
                  style: FilledButton.styleFrom(
                    backgroundColor: lecture.isAbsent ? const Color(0xFFDC2626) : Colors.grey.withOpacity(0.2),
                    foregroundColor: lecture.isAbsent ? Colors.white : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              if (lecture.isRecorded) ...[
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'إلغاء التسجيل',
                  onPressed: () {
                    cubit.recordAttendance(
                      courseId: widget.courseId,
                      lectureId: widget.lectureId,
                      status: AttendanceStatus.none,
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ],
          ),

          if (lecture.isRecorded && lecture.lectureDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lecture.isPresent
                    ? const Color(0xFF059669).withOpacity(0.12)
                    : const Color(0xFFDC2626).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 16,
                    color: lecture.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم التسجيل: ${lecture.attendanceStatus.displayName} بتاريخ ${lecture.lectureDate}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: lecture.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, LectureModel lecture) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notes_rounded, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'ملاحظات المحاضرة',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (!_isEditingNotes)
                TextButton.icon(
                  onPressed: () => setState(() => _isEditingNotes = true),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('تعديل'),
                )
              else
                FilledButton.icon(
                  onPressed: _saveNotes,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('حفظ'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_isEditingNotes)
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'اكتب ملاحظاتك وتلخيصك السريع لهذه المحاضرة هنا...',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              lecture.notes.trim().isNotEmpty ? lecture.notes : 'لا توجد ملاحظات مسجلة لهذه المحاضرة بعد. اضغط تعديل للتدوين.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: lecture.notes.trim().isNotEmpty ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, LectureModel lecture) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<UniversityCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المهام الأكاديمية (${lecture.tasks.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('إضافة مهمة'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (lecture.tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'لا توجد مهام مضافة لهذه المحاضرة. يمكنك إضافة مهمة جديدة أعلاه.',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lecture.tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = lecture.tasks[index];
              return _buildTaskItem(context, task, cubit);
            },
          ),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, UniversityTaskModel task, UniversityCubit cubit) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color categoryColor;
    switch (task.category) {
      case UniversityTaskCategory.study:
        categoryColor = const Color(0xFF2563EB);
        break;
      case UniversityTaskCategory.practice:
        categoryColor = const Color(0xFF059669);
        break;
      case UniversityTaskCategory.homework:
        categoryColor = const Color(0xFFD97706);
        break;
      case UniversityTaskCategory.summary:
        categoryColor = const Color(0xFF7C3AED);
        break;
      case UniversityTaskCategory.review:
        categoryColor = const Color(0xFF0891B2);
        break;
      case UniversityTaskCategory.custom:
        categoryColor = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? const Color(0xFF059669).withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          // Checkbox / Status cycler
          InkWell(
            onTap: () {
              // Cycle: notStarted -> inProgress -> completed -> notStarted
              final nextStatus = task.status == UniversityTaskStatus.notStarted
                  ? UniversityTaskStatus.inProgress
                  : (task.status == UniversityTaskStatus.inProgress
                      ? UniversityTaskStatus.completed
                      : UniversityTaskStatus.notStarted);
              cubit.updateTaskStatus(
                courseId: widget.courseId,
                lectureId: widget.lectureId,
                taskId: task.id,
                status: nextStatus,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
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
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title & Category
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
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.category.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.status.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit / Delete Popup Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            onSelected: (val) {
              if (val == 'edit') {
                _showEditTaskDialog(context, task);
              } else if (val == 'delete') {
                cubit.deleteTask(
                  courseId: widget.courseId,
                  lectureId: widget.lectureId,
                  taskId: task.id,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('تعديل المهمة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// MODAL SHEET: ADD / EDIT TASK FORM
// ------------------------------------------------------------

class _TaskFormSheet extends StatefulWidget {
  final String courseId;
  final String lectureId;
  final UniversityTaskModel? taskToEdit;

  const _TaskFormSheet({
    required this.courseId,
    required this.lectureId,
    this.taskToEdit,
  });

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  UniversityTaskCategory _selectedCategory = UniversityTaskCategory.study;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _selectedCategory = widget.taskToEdit?.category ?? UniversityTaskCategory.study;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final cubit = context.read<UniversityCubit>();

    if (widget.taskToEdit != null) {
      cubit.updateTask(
        courseId: widget.courseId,
        lectureId: widget.lectureId,
        taskId: widget.taskToEdit!.id,
        title: title,
        category: _selectedCategory,
      );
    } else {
      cubit.addLectureTask(
        courseId: widget.courseId,
        lectureId: widget.lectureId,
        title: title,
        category: _selectedCategory,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.taskToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'تعديل المهمة الجامعية' : 'إضافة مهمة جديدة للمحاضرة',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة *',
                  hintText: 'مثال: حل مسائل الشابتر الثاني',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال عنوان المهمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category Picker
              DropdownButtonFormField<UniversityTaskCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'تصنيف المهمة',
                ),
                items: UniversityTaskCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                label: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المهمة'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
