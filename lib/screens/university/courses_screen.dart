// ============================================================
// COURSES SCREEN (V2)
// Displays list of university courses for the active study plan with:
// - Course metadata (Name, Credit Hours, Instructor, Practical tag)
// - Add / Edit Course with:
//     * Theoretical & Practical doctor names
//     * Configurable task types per track
//     * Custom task creation
// - Delete Course confirmation
// - Navigation to Course Details
// - Bottom Navigation: UniversityBottomNavBar (index 1)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/course_model.dart';
import '../../models/task_type_config.dart';
import '../../widgets/university_bottom_nav_bar.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  void _showAddCourseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => const _CourseFormSheet(),
    );
  }

  void _showEditCourseDialog(BuildContext context, CourseModel course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => _CourseFormSheet(courseToEdit: course),
    );
  }

  void _showDeleteCourseDialog(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('حذف المقرر الدراسي'),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف مقرر "${course.name}"؟ سيتم حذف كافة المحاضرات وسجلات الحضور والمهام المرتبطة به.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<UniversityCubit>().deleteCourse(course.id);
            },
            child: const Text('حذف المقرر'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<UniversityCubit, UniversityState>(
      builder: (context, state) {
        final planName = (state is UniversityLoaded && state.activePlan != null)
            ? state.activePlan!.name
            : 'المقررات الدراسية';

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المقررات الدراسية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  planName,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'إضافة مقرر جديد',
                onPressed: () => _showAddCourseDialog(context),
              ),
            ],
          ),
          bottomNavigationBar: const UniversityBottomNavBar(currentIndex: 1),
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

                final loaded = state is UniversityLoaded
                    ? state
                    : const UniversityLoaded(plans: []);

                if (loaded.courses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 64,
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد مقررات مضافة في هذه الخطة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ابدأ بإضافة مقررات الخطة الحالية مع تحديد الساعات والمهام والتقييمات.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => _showAddCourseDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('إضافة مقرر الآن'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: loaded.courses.length,
                  itemBuilder: (context, index) {
                    final course = loaded.courses[index];
                    return _buildCourseCard(context, course);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (course.courseProgress * 100).toStringAsFixed(0);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailsScreen(courseId: course.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Name & Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'دكتور النظري: ${course.instructorName.isNotEmpty ? course.instructorName : "غير محدد"}',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        if (course.hasPractical && course.practicalInstructorName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'دكتور العملي: ${course.practicalInstructorName}',
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showEditCourseDialog(context, course);
                      } else if (action == 'delete') {
                        _showDeleteCourseDialog(context, course);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('تعديل البيانات'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف المقرر', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course.creditHours} ساعات معتمدة',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: course.hasPractical
                          ? const Color(0xFF059669).withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.hasPractical ? 'يحتوي على عملي' : 'نظري فقط',
                      style: TextStyle(
                        fontSize: 11,
                        color: course.hasPractical ? const Color(0xFF059669) : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course.totalLecturesCount} محاضرة',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: course.courseProgress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'تم تسجيل ${course.recordedLecturesCount}/${course.totalLecturesCount} ($progress%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// MODAL SHEET: ADD / EDIT COURSE FORM WITH TASK CONFIGURATIONS
// ------------------------------------------------------------

class _CourseFormSheet extends StatefulWidget {
  final CourseModel? courseToEdit;
  const _CourseFormSheet({this.courseToEdit});

  @override
  State<_CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<_CourseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _instructorController;
  late TextEditingController _practicalInstructorController;
  late TextEditingController _creditHoursController;
  late TextEditingController _theoryLecturesController;
  late TextEditingController _practicalLecturesController;

  bool _hasPractical = false;
  bool _isAutoLectures = true;

  late List<TaskTypeConfig> _theoryConfigs;
  late List<TaskTypeConfig> _practicalConfigs;

  @override
  void initState() {
    super.initState();
    final c = widget.courseToEdit;
    _nameController = TextEditingController(text: c?.name ?? '');
    _instructorController = TextEditingController(text: c?.instructorName ?? '');
    _practicalInstructorController = TextEditingController(text: c?.practicalInstructorName ?? '');
    _creditHoursController = TextEditingController(text: c != null ? c.creditHours.toString() : '3');
    _hasPractical = c?.hasPractical ?? false;
    _theoryLecturesController = TextEditingController(text: c != null ? c.theoryLecturesCount.toString() : '12');
    _practicalLecturesController = TextEditingController(text: c != null ? c.practicalLecturesCount.toString() : '10');

    _theoryConfigs = c?.theoryTaskConfigs.isNotEmpty == true
        ? c!.theoryTaskConfigs.map((cfg) => cfg.copyWith()).toList()
        : UniversityCubit.defaultTaskConfigs();

    _practicalConfigs = c?.practicalTaskConfigs.isNotEmpty == true
        ? c!.practicalTaskConfigs.map((cfg) => cfg.copyWith()).toList()
        : UniversityCubit.defaultTaskConfigs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _practicalInstructorController.dispose();
    _creditHoursController.dispose();
    _theoryLecturesController.dispose();
    _practicalLecturesController.dispose();
    super.dispose();
  }

  void _addCustomTask(bool isTheory) {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTheory ? 'إضافة نوع مهمة نظري مخصص' : 'إضافة نوع مهمة عملي مخصص'),
        content: TextField(
          controller: customController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم المهمة المخصصة',
            hintText: 'مثال: تقرير بحثي / مشروع مصغر',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = customController.text.trim();
              if (name.isNotEmpty) {
                final newCfg = TaskTypeConfig(
                  key: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  enabled: true,
                  isCustom: true,
                );
                setState(() {
                  if (isTheory) {
                    _theoryConfigs.add(newCfg);
                  } else {
                    _practicalConfigs.add(newCfg);
                  }
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final instructor = _instructorController.text.trim();
    final practicalInstructor = _hasPractical ? _practicalInstructorController.text.trim() : null;
    final creditHours = int.tryParse(_creditHoursController.text.trim()) ?? 3;

    if (widget.courseToEdit != null) {
      context.read<UniversityCubit>().updateCourse(
            courseId: widget.courseToEdit!.id,
            name: name,
            creditHours: creditHours,
            instructorName: instructor,
            practicalInstructorName: practicalInstructor,
            theoryTaskConfigs: _theoryConfigs,
            practicalTaskConfigs: _hasPractical ? _practicalConfigs : const [],
          );
    } else {
      int theoryCount = 12;
      int practicalCount = _hasPractical ? 10 : 0;

      if (!_isAutoLectures) {
        theoryCount = int.tryParse(_theoryLecturesController.text.trim()) ?? 12;
        practicalCount = _hasPractical ? (int.tryParse(_practicalLecturesController.text.trim()) ?? 10) : 0;
      }

      context.read<UniversityCubit>().addCourse(
            name: name,
            creditHours: creditHours,
            instructorName: instructor,
            practicalInstructorName: practicalInstructor,
            hasPractical: _hasPractical,
            theoryLecturesCount: theoryCount,
            practicalLecturesCount: practicalCount,
            theoryTaskConfigs: _theoryConfigs,
            practicalTaskConfigs: _hasPractical ? _practicalConfigs : const [],
            autoTasks: true,
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.courseToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'تعديل بيانات المقرر' : 'إضافة مقرر دراسي جديد',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المقرر *',
                  hintText: 'مثال: الذكاء الاصطناعي',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال اسم المقرر' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'اسم دكتور النظري *',
                  hintText: 'د. فلان الفلاني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال اسم دكتور النظري' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _creditHoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الساعات المعتمدة *',
                  hintText: '3',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time_rounded),
                ),
                validator: (val) {
                  final n = int.tryParse(val ?? '');
                  if (n == null || n <= 0) return 'أدخل عدداً صحيحاً موجباً';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Practical switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('هل يحتوي المقرر على جانب عملي/مختبر؟', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('عند التفعيل يتم إنشاء مسار عملي مستقل للمحاضرات والمهام', style: TextStyle(fontSize: 12)),
                value: _hasPractical,
                onChanged: (val) => setState(() => _hasPractical = val),
              ),

              if (_hasPractical) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _practicalInstructorController,
                  decoration: const InputDecoration(
                    labelText: 'اسم دكتور / معيد العملي',
                    hintText: 'م. فلان الفلاني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.science_rounded),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Section: Theoretical Task Type Configurations
              const Text('إعدادات المهام الأكاديمية (النظري):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ..._theoryConfigs.map((cfg) {
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(cfg.name, style: const TextStyle(fontSize: 13)),
                  value: cfg.enabled,
                  onChanged: (val) {
                    setState(() {
                      final idx = _theoryConfigs.indexOf(cfg);
                      _theoryConfigs[idx] = cfg.copyWith(enabled: val ?? true);
                    });
                  },
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _addCustomTask(true),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('إضافة نوع مهمة نظري مخصص', style: TextStyle(fontSize: 12)),
                ),
              ),

              // Section: Practical Task Type Configurations (if practical)
              if (_hasPractical) ...[
                const SizedBox(height: 12),
                const Text('إعدادات المهام الأكاديمية (العملي):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ..._practicalConfigs.map((cfg) {
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(cfg.name, style: const TextStyle(fontSize: 13)),
                    value: cfg.enabled,
                    onChanged: (val) {
                      setState(() {
                        final idx = _practicalConfigs.indexOf(cfg);
                        _practicalConfigs[idx] = cfg.copyWith(enabled: val ?? true);
                      });
                    },
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _addCustomTask(false),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('إضافة نوع مهمة عملي مخصص', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],

              if (!isEditing) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('توليد المحاضرات تلقائياً (12 نظري / 10 عملي)', style: TextStyle(fontSize: 13)),
                  value: _isAutoLectures,
                  onChanged: (val) => setState(() => _isAutoLectures = val),
                ),
                if (!_isAutoLectures) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _theoryLecturesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'محاضرات النظري', border: OutlineInputBorder()),
                        ),
                      ),
                      if (_hasPractical) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _practicalLecturesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'محاضرات العملي', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المقرر إلى الخطة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
