// ============================================================
// LECTURE DETAILS SCREEN (V2)
// Displays comprehensive lecture details:
// - Course Name, Section (نظري / عملي), Lecture Number
// - Attendance registration: حاضر / غائب / ملغي (مع سبب الإلغاء)
// - Button: «تم إنجاز جميع المهام» (يحوّل كافة مهام المحاضرة إلى مكتملة)
// - Date modification dialog
// - Lecture Notes editor
// - Lecture Tasks CRUD with category styling
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
          widget.courseId,
          widget.lectureId,
          _notesController.text.trim(),
        );
    setState(() {
      _isEditingNotes = false;
    });
  }

  void _showCancelDialog(BuildContext context) {
    String selectedReason = 'عطلة رسمية';
    final customReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.block_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('تسجيل المحاضرة كملغاة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المحاضرات الملغاة يتم استبعادها تلقائياً من مقام حساب نسبة الحضور حتى لا تؤثر سلباً على معدلك.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: const InputDecoration(labelText: 'سبب الإلغاء', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'عطلة رسمية', child: Text('عطلة رسمية')),
                  DropdownMenuItem(value: 'اعتذار الدكتور', child: Text('اعتذار الدكتور')),
                  DropdownMenuItem(value: 'إلغاء من إدارة الكلية', child: Text('إلغاء من إدارة الكلية')),
                  DropdownMenuItem(value: 'ظروف طارئة', child: Text('ظروف طارئة')),
                  DropdownMenuItem(value: 'أخرى', child: Text('سبب مخصص (أخرى)...')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedReason = val);
                },
              ),
              if (selectedReason == 'أخرى') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customReasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'اكتب سبب الإلغاء',
                    hintText: 'مثال: تأجيل إلى موعد لاحق',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
              onPressed: () {
                final finalReason = selectedReason == 'أخرى'
                    ? (customReasonController.text.trim().isNotEmpty ? customReasonController.text.trim() : 'سبب غير محدد')
                    : selectedReason;

                context.read<UniversityCubit>().recordAttendance(
                      widget.courseId,
                      widget.lectureId,
                      AttendanceStatus.cancelled,
                      cancellationReason: finalReason,
                    );
                Navigator.pop(dialogCtx);
              },
              child: const Text('تأكيد الإلغاء', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateEditDialog(BuildContext context, LectureModel lecture) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      final formatted = UniversityCubit.formatDate(picked);
      context.read<UniversityCubit>().recordAttendance(
            widget.courseId,
            widget.lectureId,
            lecture.attendanceStatus,
            customDate: formatted,
            cancellationReason: lecture.cancellationReason,
          );
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _TaskFormSheet(courseId: widget.courseId, lectureId: widget.lectureId),
    );
  }

  void _showEditTaskDialog(BuildContext context, UniversityTaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final course = state.getCourse(widget.courseId);
        final lecture = state.getLecture(widget.courseId, widget.lectureId);

        if (course == null || lecture == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل المحاضرة')),
            body: const Center(child: Text('المحاضرة المطلوبة غير موجودة')),
          );
        }

        if (!_isEditingNotes) {
          _notesController.text = lecture.notes;
        }

        final isTheory = lecture.section == LectureSection.theoretical;

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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isTheory
                                    ? Colors.blue.withValues(alpha: 0.12)
                                    : Colors.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isTheory ? 'محاضرة نظرية' : 'محاضرة عملية / مختبر',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isTheory ? Colors.blue.shade700 : Colors.teal.shade700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              course.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'المحاضر: ${isTheory ? course.instructorName : (course.practicalInstructorName ?? course.instructorName)}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Attendance Card (حاضر / غائب / ملغي)
                  _buildAttendanceCard(context, lecture),

                  const SizedBox(height: 16),

                  // Notes Card
                  _buildNotesCard(context, lecture),

                  const SizedBox(height: 20),

                  // Tasks Section with «تم إنجاز جميع المهام» button
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
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
            'حدد حالتك (حاضر / غائب / ملغي). المحاضرات الملغاة تُستبعد تلقائياً من حساب نسبة الحضور.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // 3 Buttons: حاضر / غائب / ملغي
          Row(
            children: [
              // Present
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    cubit.recordAttendance(
                      widget.courseId,
                      widget.lectureId,
                      AttendanceStatus.present,
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text('حاضر', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: lecture.isPresent ? const Color(0xFF059669) : Colors.grey.withValues(alpha: 0.15),
                    foregroundColor: lecture.isPresent ? Colors.white : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Absent
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    cubit.recordAttendance(
                      widget.courseId,
                      widget.lectureId,
                      AttendanceStatus.absent,
                    );
                  },
                  icon: const Icon(Icons.cancel_rounded, size: 16),
                  label: const Text('غائب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: lecture.isAbsent ? const Color(0xFFDC2626) : Colors.grey.withValues(alpha: 0.15),
                    foregroundColor: lecture.isAbsent ? Colors.white : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Cancelled
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showCancelDialog(context),
                  icon: const Icon(Icons.block_rounded, size: 16),
                  label: const Text('ملغي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: lecture.isCancelled ? Colors.orange.shade700 : Colors.grey.withValues(alpha: 0.15),
                    foregroundColor: lecture.isCancelled ? Colors.white : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              if (lecture.isRecorded) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'إلغاء التسجيل',
                  onPressed: () {
                    cubit.recordAttendance(
                      widget.courseId,
                      widget.lectureId,
                      AttendanceStatus.none,
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            ],
          ),

          // Status & Date bar
          if (lecture.isRecorded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lecture.isCancelled
                    ? Colors.orange.withValues(alpha: 0.12)
                    : (lecture.isPresent
                        ? const Color(0xFF059669).withValues(alpha: 0.12)
                        : const Color(0xFFDC2626).withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    lecture.isCancelled
                        ? Icons.block_rounded
                        : (lecture.isPresent ? Icons.check_circle_outline : Icons.cancel_outlined),
                    size: 16,
                    color: lecture.isCancelled
                        ? Colors.orange.shade800
                        : (lecture.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lecture.isCancelled
                          ? 'محاضرة ملغاة ${lecture.cancellationReason != null ? "(${lecture.cancellationReason})" : ""} بتاريخ ${lecture.lectureDate ?? ""}'
                          : 'تم التسجيل: ${lecture.isPresent ? "حاضر" : "غائب"} بتاريخ ${lecture.lectureDate ?? ""}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: lecture.isCancelled
                            ? Colors.orange.shade800
                            : (lecture.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showDateEditDialog(context, lecture),
                    child: const Text('تعديل التاريخ', style: TextStyle(fontSize: 11)),
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
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
                  Text('ملاحظات المحاضرة', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
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
              lecture.notes.trim().isNotEmpty
                  ? lecture.notes
                  : 'لا توجد ملاحظات مسجلة لهذه المحاضرة بعد. اضغط تعديل للتدوين.',
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

    final hasUncompletedTasks = lecture.tasks.any((t) => !t.isCompleted);

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
            Row(
              children: [
                // Button: «تم إنجاز جميع المهام»
                if (!lecture.isCancelled && lecture.tasks.isNotEmpty && hasUncompletedTasks) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () {
                      cubit.completeAllLectureTasks(widget.courseId, widget.lectureId);
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('تم إنجاز جميع المهام', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton.tonalIcon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة مهمة'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (lecture.tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'لا توجد مهام مضافة لهذه المحاضرة.',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
          )
        else
          ...lecture.tasks.map((task) {
            final catDef = taskCategoryDefinitions[task.category] ?? taskCategoryDefinitions[UniversityTaskCategory.custom]!;
            final isCompleted = task.status == UniversityTaskStatus.completed;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : (task.status == UniversityTaskStatus.inProgress
                            ? Icons.timelapse_rounded
                            : Icons.radio_button_unchecked_rounded),
                    color: isCompleted ? Colors.green : (task.status == UniversityTaskStatus.inProgress ? Colors.orange : Colors.grey),
                  ),
                  onPressed: () {
                    // Cycle status
                    UniversityTaskStatus next;
                    if (task.status == UniversityTaskStatus.notStarted) {
                      next = UniversityTaskStatus.inProgress;
                    } else if (task.status == UniversityTaskStatus.inProgress) {
                      next = UniversityTaskStatus.completed;
                    } else {
                      next = UniversityTaskStatus.notStarted;
                    }
                    cubit.updateTaskStatus(widget.courseId, widget.lectureId, task.id, next);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  catDef.name,
                  style: TextStyle(fontSize: 11, color: catDef.color),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showEditTaskDialog(context, task);
                    } else if (val == 'delete') {
                      cubit.deleteTask(widget.courseId, widget.lectureId, task.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ------------------------------------------------------------
// MODAL SHEET: ADD / EDIT TASK
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
  late UniversityTaskCategory _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _category = widget.taskToEdit?.category ?? UniversityTaskCategory.study;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<UniversityCubit>();
    final title = _titleController.text.trim();

    if (widget.taskToEdit != null) {
      cubit.updateTask(
        widget.courseId,
        widget.lectureId,
        widget.taskToEdit!.id,
        title,
        _category,
      );
    } else {
      cubit.addLectureTask(
        widget.courseId,
        widget.lectureId,
        title,
        _category,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'تعديل المهمة الأكاديمية' : 'إضافة مهمة جديدة للمحاضرة',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'عنوان المهمة *',
                hintText: 'مثال: حل مسائل الشابتر الثاني',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال عنوان المهمة' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UniversityTaskCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'تصنيف المهمة', border: OutlineInputBorder()),
              items: UniversityTaskCategory.values.map((cat) {
                final def = taskCategoryDefinitions[cat]!;
                return DropdownMenuItem(
                  value: cat,
                  child: Text(def.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المهمة'),
            ),
          ],
        ),
      ),
    );
  }
}
