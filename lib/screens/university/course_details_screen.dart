// ============================================================
// COURSE DETAILS SCREEN (V2)
// Displays detailed view of a course:
// - Header with course metadata (Credit hours, Instructor)
// - Separate sections for Theoretical (النظري) and Practical (العملي)
// - Numbered lectures list (المحاضرة 1، 2، ...)
// - Lecture attendance badge, date, tasks progress, notes indicator
// - Navigation to LectureDetailsScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
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
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<UniversityCubit, UniversityState>(
      builder: (context, state) {
        if (state is! UniversityLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final course = state.getCourse(widget.courseId);
        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل المقرر')),
            body: const Center(child: Text('المقرر المطلوب غير موجود')),
          );
        }

        final hasPractical = course.hasPractical;
        if (hasPractical && (_tabController == null || _tabController!.length != 2)) {
          _tabController?.dispose();
          _tabController = TabController(length: 2, vsync: this);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(course.name),
            bottom: hasPractical
                ? TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        text: 'النظري (${course.theoreticalLectures.length})',
                        icon: const Icon(Icons.menu_book_rounded, size: 20),
                      ),
                      Tab(
                        text: 'العملي / اللاب (${course.practicalLectures.length})',
                        icon: const Icon(Icons.science_outlined, size: 20),
                      ),
                    ],
                  )
                : null,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Info Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.4),
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outline.withOpacity(0.15)),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.instructorName.isNotEmpty ? course.instructorName : 'اسم الدكتور غير محدد',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${course.creditHours} ساعات معتمدة • ${course.totalLecturesCount} محاضرة إجمالاً',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'مسجل ${course.recordedLecturesCount}/${course.totalLecturesCount}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lectures Content
                Expanded(
                  child: hasPractical
                      ? TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLecturesList(context, course, course.theoreticalLectures, 'محاضرات النظري'),
                            _buildLecturesList(context, course, course.practicalLectures, 'محاضرات العملي'),
                          ],
                        )
                      : _buildLecturesList(context, course, course.theoreticalLectures, 'محاضرات النظري'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLecturesList(
    BuildContext context,
    CourseModel course,
    List<LectureModel> lectures,
    String sectionTitle,
  ) {
    if (lectures.isEmpty) {
      return Center(
        child: Text('لا توجد محاضرات في هذا القسم'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lectures.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
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
    Color badgeTextColor;
    String badgeText;

    if (lecture.isPresent) {
      badgeColor = const Color(0xFF059669).withOpacity(0.15);
      badgeTextColor = const Color(0xFF059669);
      badgeText = 'حاضر (${lecture.lectureDate ?? ""})';
    } else if (lecture.isAbsent) {
      badgeColor = const Color(0xFFDC2626).withOpacity(0.15);
      badgeTextColor = const Color(0xFFDC2626);
      badgeText = 'غائب (${lecture.lectureDate ?? ""})';
    } else {
      badgeColor = colorScheme.outline.withOpacity(0.15);
      badgeTextColor = colorScheme.onSurfaceVariant;
      badgeText = 'لم يسجل بعد';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => LectureDetailsScreen(
                courseId: course.id,
                lectureId: lecture.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: lecture.isRecorded
                  ? (lecture.isPresent ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFFDC2626).withOpacity(0.4))
                  : colorScheme.outline.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              // Lecture Number Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: lecture.isPresent
                    ? const Color(0xFF059669)
                    : (lecture.isAbsent ? const Color(0xFFDC2626) : colorScheme.primaryContainer),
                child: Text(
                  '${lecture.lectureNumber}',
                  style: TextStyle(
                    color: lecture.isRecorded ? Colors.white : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lecture.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lecture.notes.trim().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.notes_rounded, size: 16, color: colorScheme.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeTextColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${lecture.completedTasksCount}/${lecture.totalTasksCount} مهام',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
