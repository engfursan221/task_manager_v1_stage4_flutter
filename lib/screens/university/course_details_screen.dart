// ============================================================
// COURSE DETAILS SCREEN (V2)
// Displays detailed view of a course:
// - Header with course metadata (Credit hours, Instructors)
// - Independent sections for Theoretical (النظري) and Practical (العملي)
// - Academic Assessments & Grading tab (سقف 100 درجة)
// - Numbered lectures list with status, tasks progress, and notes
// - Navigation to LectureDetailsScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/assessment_model.dart';
import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
import 'lecture_details_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasPractical = false;

  @override
  void initState() {
    super.initState();
    // Default 2 tabs (Theory, Assessments) or 3 (Theory, Practical, Assessments)
    _tabController = TabController(length: 2, vsync: this);
  }

  void _syncTabController(bool hasPractical) {
    final targetLength = hasPractical ? 3 : 2;
    if (_hasPractical != hasPractical || _tabController.length != targetLength) {
      _hasPractical = hasPractical;
      _tabController.dispose();
      _tabController = TabController(length: targetLength, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddAssessmentDialog(BuildContext context, CourseModel course, {AssessmentModel? assessmentToEdit}) {
    final isEditing = assessmentToEdit != null;
    final nameController = TextEditingController(text: assessmentToEdit?.name ?? '');
    final maxScoreController = TextEditingController(
      text: assessmentToEdit != null ? assessmentToEdit.maxScore.toString() : '15',
    );
    final actualScoreController = TextEditingController(
      text: assessmentToEdit?.actualScore != null ? assessmentToEdit!.actualScore.toString() : '',
    );
    final notesController = TextEditingController(text: assessmentToEdit?.notes ?? '');

    AssessmentSection section = assessmentToEdit?.section ?? AssessmentSection.theoretical;
    bool isCompleted = assessmentToEdit?.isCompleted ?? false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final otherScores = isEditing
              ? course.assessments.where((a) => a.id != assessmentToEdit.id).fold(0.0, (s, a) => s + a.maxScore)
              : course.totalAllocatedScore;
          final availableForThis = (100.0 - otherScores).clamp(0.0, 100.0);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isEditing ? 'تعديل عنصر التقييم' : 'إضافة عنصر تقييم أكاديمي',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'الدرجات المتاحة من أصل 100: ${availableForThis.toStringAsFixed(1)} درجة',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'اسم التقييم *',
                      hintText: 'مثال: اختبار نصفي / مشروع',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AssessmentSection>(
                    value: section,
                    decoration: const InputDecoration(labelText: 'القسم التابع له', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: AssessmentSection.theoretical, child: Text('نظري')),
                      if (course.hasPractical)
                        const DropdownMenuItem(value: AssessmentSection.practical, child: Text('عملي')),
                      const DropdownMenuItem(value: AssessmentSection.finalExam, child: Text('اختبار نهائي عام للمقرر')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => section = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الدرجة القصوى المخصصة (سقف 100) *',
                      hintText: 'مثال: 20',
                      helperText: 'الحد الأقصى المتبقي المسموح به: $availableForThis',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: actualScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الدرجة الفعلية التي حصلت عليها (اختياري)',
                      hintText: 'اتركها فارغة إذا لم تُعلن بعد',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('تم إنجاز هذا التقييم', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('حالة الإنجاز منفصلة عن الدرجة المستحقة', style: TextStyle(fontSize: 11)),
                    value: isCompleted,
                    onChanged: (val) => setDialogState(() => isCompleted = val ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final maxScore = double.tryParse(maxScoreController.text.trim()) ?? 0.0;
                  if (maxScore <= 0 || maxScore > availableForThis) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الدرجة القصوى غير صالحة أو تتجاوز المتاح ($availableForThis)')),
                    );
                    return;
                  }

                  final actualStr = actualScoreController.text.trim();
                  final actualScore = actualStr.isNotEmpty ? double.tryParse(actualStr) : null;
                  if (actualScore != null && (actualScore < 0 || actualScore > maxScore)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الدرجة الفعلية يجب أن تكون بين 0 و $maxScore')),
                    );
                    return;
                  }

                  final cubit = context.read<UniversityCubit>();
                  final assessment = AssessmentModel(
                    id: isEditing ? assessmentToEdit.id : 'asm_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    section: section,
                    maxScore: maxScore,
                    isCompleted: isCompleted,
                    actualScore: actualScore,
                    notes: notesController.text.trim(),
                  );

                  if (isEditing) {
                    cubit.updateAssessment(course.id, assessment);
                  } else {
                    cubit.addAssessment(course.id, assessment);
                  }

                  Navigator.pop(dialogCtx);
                },
                child: Text(isEditing ? 'حفظ' : 'إضافة'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<UniversityCubit, UniversityState>(
      builder: (context, state) {
        if (state is! UniversityLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final course = state.getCourse(widget.courseId);
        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل المقرر')),
            body: const Center(child: Text('المقرر المطلوب غير موجود')),
          );
        }

        _syncTabController(course.hasPractical);

        return Scaffold(
          appBar: AppBar(
            title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'النظري (${course.theoreticalLectures.length})',
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                ),
                if (course.hasPractical)
                  Tab(
                    text: 'العملي (${course.practicalLectures.length})',
                    icon: const Icon(Icons.science_rounded, size: 18),
                  ),
                Tab(
                  text: 'التقييمات (${course.assessments.length})',
                  icon: const Icon(Icons.grade_rounded, size: 18),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Info Bar with Doctor details
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.school_rounded, color: colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دكتور النظري: ${course.instructorName.isNotEmpty ? course.instructorName : "غير محدد"}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${course.creditHours} ساعات',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Theoretical
                      _buildLecturesList(context, course, course.theoreticalLectures),

                      // Tab 2: Practical (if applicable)
                      if (course.hasPractical)
                        _buildLecturesList(context, course, course.practicalLectures),

                      // Tab 3: Assessments & Grading
                      _buildAssessmentsTab(context, course),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLecturesList(BuildContext context, CourseModel course, List<LectureModel> lectures) {
    if (lectures.isEmpty) {
      return const Center(child: Text('لا توجد محاضرات في هذا القسم'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final lecture = lectures[index];
        return _buildLectureCard(context, course, lecture);
      },
    );
  }

  Widget _buildLectureCard(BuildContext context, CourseModel course, LectureModel lecture) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color badgeColor;
    String badgeText;

    if (lecture.isCancelled) {
      badgeColor = Colors.orange.shade700;
      badgeText = 'ملغية ${lecture.cancellationReason != null ? "(${lecture.cancellationReason})" : ""}';
    } else if (lecture.isPresent) {
      badgeColor = Colors.green.shade700;
      badgeText = 'حاضر';
    } else if (lecture.isAbsent) {
      badgeColor = Colors.red.shade700;
      badgeText = 'غائب';
    } else {
      badgeColor = Colors.grey.shade600;
      badgeText = 'لم يسجل';
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LectureDetailsScreen(
                courseId: course.id,
                lectureId: lecture.id,
              ),
            ),
          );
        },
        title: Text(lecture.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
                if (lecture.lectureDate != null) ...[
                  const SizedBox(width: 8),
                  Text(lecture.lectureDate!, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'المهام: ${lecture.completedTasksCount}/${lecture.totalTasksCount} مكتملة',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
      ),
    );
  }

  Widget _buildAssessmentsTab(BuildContext context, CourseModel course) {
    final allocated = course.totalAllocatedScore;
    final remaining = course.remainingScore;
    final completedCount = course.assessments.where((a) => a.isCompleted).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score Allocation Summary Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مجموع الدرجات المخصصة:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${allocated.toStringAsFixed(1)} / 100',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: allocated == 100 ? Colors.green.shade700 : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (allocated / 100.0).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(allocated > 100 ? Colors.red : Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المتبقي غير الموزع: ${remaining.toStringAsFixed(1)} درجة',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      Text(
                        'المكتمل: $completedCount من ${course.assessments.length}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Add Assessment Button
          ElevatedButton.icon(
            onPressed: () => _openAddAssessmentDialog(context, course),
            icon: const Icon(Icons.add),
            label: const Text('إضافة عنصر تقييم أكاديمي (اختبار / تكليف / عملي)'),
          ),

          const SizedBox(height: 16),

          if (course.assessments.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'لم تتم إضافة عناصر تقييم بعد. أضف الاختبارات النصفية والنهائية والتكاليف بسقف 100 درجة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ),
          ] else ...[
            // Assessments List
            ...course.assessments.map((asm) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(asm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    'القسم: ${asm.section.displayName} • الدرجة القصوى: ${asm.maxScore} ${asm.actualScore != null ? "• الدرجة الفعلية: ${asm.actualScore}" : ""}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  leading: Icon(
                    asm.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: asm.isCompleted ? Colors.green : Colors.grey,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _openAddAssessmentDialog(context, course, assessmentToEdit: asm),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () {
                          context.read<UniversityCubit>().deleteAssessment(course.id, asm.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
