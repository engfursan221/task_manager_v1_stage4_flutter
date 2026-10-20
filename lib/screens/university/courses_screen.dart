// ============================================================
// COURSES SCREEN (V2)
// Displays list of university courses with:
// - Course metadata (Name, Credit Hours, Instructor, Practical tag)
// - Add Course dialog (Automatic vs Manual lectures count)
// - Edit Course dialog
// - Delete Course confirmation
// - Navigation to Course Details
// - Bottom Navigation: UniversityBottomNavBar (index 1)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/course_model.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('المقررات الدراسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة مقرر جديد',
            onPressed: () => _showAddCourseDialog(context),
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

            final loaded = state is UniversityLoaded
                ? state
                : const UniversityLoaded(courses: []);

            if (loaded.courses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.school_outlined, size: 52, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'لا توجد مقررات دراسية حاليًا',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابدأ الآن بإضافة مقرراتك الدراسية وتحديد الساعات والمعامل والمحاضرات.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _showAddCourseDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('إضافة أول مقرر دراسي'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: loaded.courses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final course = loaded.courses[index];
                return _buildCourseCard(context, course);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('مقرر جديد'),
      ),
      bottomNavigationBar: const UniversityBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (course.courseProgress * 100).toStringAsFixed(0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CourseDetailsScreen(courseId: course.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outline.withOpacity(0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Actions Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الدكتور: ${course.instructorName.isNotEmpty ? course.instructorName : "غير محدد"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditCourseDialog(context, course);
                      } else if (value == 'delete') {
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
              const SizedBox(height: 14),

              // Tags Row: Credit Hours & Practical
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
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
                          ? const Color(0xFF059669).withOpacity(0.12)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.hasPractical ? 'يحتوي على عملي/مختبر' : 'نظري فقط',
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
                      color: colorScheme.secondaryContainer.withOpacity(0.5),
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
              const SizedBox(height: 14),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: course.courseProgress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: colorScheme.outline.withOpacity(0.15),
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
// MODAL SHEET: ADD / EDIT COURSE FORM
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
  late TextEditingController _creditHoursController;
  late TextEditingController _theoryLecturesController;
  late TextEditingController _practicalLecturesController;

  bool _hasPractical = false;
  bool _isAutoLectures = true;

  @override
  void initState() {
    super.initState();
    final c = widget.courseToEdit;
    _nameController = TextEditingController(text: c?.name ?? '');
    _instructorController = TextEditingController(text: c?.instructorName ?? '');
    _creditHoursController = TextEditingController(text: c != null ? c.creditHours.toString() : '3');
    _hasPractical = c?.hasPractical ?? false;
    _theoryLecturesController = TextEditingController(text: c != null ? c.theoryLecturesCount.toString() : '12');
    _practicalLecturesController = TextEditingController(text: c != null ? c.practicalLecturesCount.toString() : '10');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _creditHoursController.dispose();
    _theoryLecturesController.dispose();
    _practicalLecturesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final instructor = _instructorController.text.trim();
    final creditHours = int.tryParse(_creditHoursController.text.trim()) ?? 3;

    if (widget.courseToEdit != null) {
      // Edit existing
      context.read<UniversityCubit>().updateCourse(
            courseId: widget.courseToEdit!.id,
            name: name,
            creditHours: creditHours,
            instructorName: instructor,
          );
    } else {
      // Add new course
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
            hasPractical: _hasPractical,
            theoryLecturesCount: theoryCount,
            practicalLecturesCount: practicalCount,
            autoTasks: true,
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.courseToEdit != null;

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
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'تعديل بيانات المقرر' : 'إضافة مقرر دراسي جديد',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              // Course Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المقرر *',
                  hintText: 'مثال: هندسة البرمجيات',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال اسم المقرر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Instructor Name
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'اسم الدكتور / المحاضر',
                  hintText: 'مثال: د. عبدالله السعيد',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),

              // Credit Hours
              TextFormField(
                controller: _creditHoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الساعات المعتمدة',
                  hintText: 'مثال: 3',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (val) {
                  final n = int.tryParse(val ?? '');
                  if (n == null || n <= 0) {
                    return 'أدخل رقمًا صحيحًا (مثال: 3)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Has Practical Switch (Only for new courses)
              if (!isEditing) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('هل يحتوي المقرر على عملي/مختبر؟'),
                  subtitle: Text(
                    _hasPractical ? 'نعم (سيتم إنشاء قسم العملي)' : 'لا (نظري فقط)',
                    style: TextStyle(
                      color: _hasPractical ? const Color(0xFF059669) : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _hasPractical,
                  onChanged: (val) => setState(() => _hasPractical = val),
                ),
                const Divider(),

                // Lectures Mode: Automatic vs Manual
                Text(
                  'عدد المحاضرات الافتراضي:',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('تلقائي (12 نظري)'),
                        subtitle: Text(_hasPractical ? '+ 10 عملي' : 'نظري فقط'),
                        value: true,
                        groupValue: _isAutoLectures,
                        onChanged: (val) => setState(() => _isAutoLectures = val ?? true),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('يدوي'),
                        subtitle: const Text('تحديد العدد بنفسك'),
                        value: false,
                        groupValue: _isAutoLectures,
                        onChanged: (val) => setState(() => _isAutoLectures = val ?? false),
                      ),
                    ),
                  ],
                ),

                if (!_isAutoLectures) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _theoryLecturesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'محاضرات النظري',
                            hintText: '12',
                          ),
                        ),
                      ),
                      if (_hasPractical) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _practicalLecturesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'محاضرات العملي',
                              hintText: '10',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                label: Text(isEditing ? 'حفظ التعديلات' : 'إنشاء المقرر والمحاضرات'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
