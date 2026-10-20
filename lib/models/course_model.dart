// ============================================================
// COURSE MODEL (V2)
// Model representing a university course with:
// - Course Name & Credit Hours
// - Theoretical Track: Instructor Name, task configs, lectures, assessments
// - Practical Track: Instructor Name, task configs, lectures, assessments
// - General Course Final Exam
// - Associated Study Plan ID
// ============================================================

import 'assessment_model.dart';
import 'lecture_model.dart';
import 'task_type_config.dart';

class CourseModel {
  final String id;
  final String? planId; // معرف الخطة الدراسية التابع لها
  final String name;
  final int creditHours;
  final String instructorName; // دكتور النظري
  final String? practicalInstructorName; // دكتور العملي (إن وجد)
  final bool hasPractical;
  final int theoryLecturesCount;
  final int practicalLecturesCount;
  final List<TaskTypeConfig> theoryTaskConfigs;
  final List<TaskTypeConfig> practicalTaskConfigs;
  final List<AssessmentModel> assessments;
  final List<LectureModel> lectures;

  const CourseModel({
    required this.id,
    this.planId,
    required this.name,
    required this.creditHours,
    required this.instructorName,
    this.practicalInstructorName,
    required this.hasPractical,
    required this.theoryLecturesCount,
    this.practicalLecturesCount = 0,
    this.theoryTaskConfigs = const [],
    this.practicalTaskConfigs = const [],
    this.assessments = const [],
    this.lectures = const [],
  });

  List<LectureModel> get theoreticalLectures =>
      lectures.where((l) => l.section == LectureSection.theoretical).toList();

  List<LectureModel> get practicalLectures =>
      lectures.where((l) => l.section == LectureSection.practical).toList();

  int get totalLecturesCount => lectures.length;
  int get recordedLecturesCount => lectures.where((l) => l.isRecorded).length;
  int get presentCount => lectures.where((l) => l.isPresent).length;
  int get absentCount => lectures.where((l) => l.isAbsent).length;
  int get cancelledCount => lectures.where((l) => l.isCancelled).length;

  int get totalTasksCount {
    int count = 0;
    for (final l in lectures) {
      count += l.tasks.length;
    }
    return count;
  }

  int get completedTasksCount {
    int count = 0;
    for (final l in lectures) {
      count += l.completedTasksCount;
    }
    return count;
  }

  // Lecture completion: Lecture is complete if all its enabled tasks are completed
  int get completedLecturesCount {
    int count = 0;
    for (final l in lectures) {
      if (!l.isCancelled && l.tasks.isNotEmpty && l.isAllTasksCompleted) {
        count++;
      }
    }
    return count;
  }

  double get courseProgress {
    if (totalLecturesCount == 0) return 0.0;
    return recordedLecturesCount / totalLecturesCount;
  }

  // Total assessments max score allocation (must be <= 100)
  double get totalAllocatedScore =>
      assessments.fold(0.0, (sum, a) => sum + a.maxScore);

  double get remainingScore =>
      (100.0 - totalAllocatedScore).clamp(0.0, 100.0);

  CourseModel copyWith({
    String? id,
    String? planId,
    String? name,
    int? creditHours,
    String? instructorName,
    String? practicalInstructorName,
    bool? hasPractical,
    int? theoryLecturesCount,
    int? practicalLecturesCount,
    List<TaskTypeConfig>? theoryTaskConfigs,
    List<TaskTypeConfig>? practicalTaskConfigs,
    List<AssessmentModel>? assessments,
    List<LectureModel>? lectures,
  }) {
    return CourseModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      creditHours: creditHours ?? this.creditHours,
      instructorName: instructorName ?? this.instructorName,
      practicalInstructorName: practicalInstructorName ?? this.practicalInstructorName,
      hasPractical: hasPractical ?? this.hasPractical,
      theoryLecturesCount: theoryLecturesCount ?? this.theoryLecturesCount,
      practicalLecturesCount: practicalLecturesCount ?? this.practicalLecturesCount,
      theoryTaskConfigs: theoryTaskConfigs ?? this.theoryTaskConfigs,
      practicalTaskConfigs: practicalTaskConfigs ?? this.practicalTaskConfigs,
      assessments: assessments ?? this.assessments,
      lectures: lectures ?? this.lectures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'name': name,
      'creditHours': creditHours,
      'instructorName': instructorName,
      'practicalInstructorName': practicalInstructorName,
      'hasPractical': hasPractical,
      'theoryLecturesCount': theoryLecturesCount,
      'practicalLecturesCount': practicalLecturesCount,
      'theoryTaskConfigs': theoryTaskConfigs.map((c) => c.toJson()).toList(),
      'practicalTaskConfigs': practicalTaskConfigs.map((c) => c.toJson()).toList(),
      'assessments': assessments.map((a) => a.toJson()).toList(),
      'lectures': lectures.map((l) => l.toJson()).toList(),
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final lecturesList = (json['lectures'] as List<dynamic>?)
            ?.map((l) => LectureModel.fromJson(l as Map<String, dynamic>))
            .toList() ??
        [];

    final theoryConfigsList = (json['theoryTaskConfigs'] as List<dynamic>?)
            ?.map((c) => TaskTypeConfig.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final practicalConfigsList = (json['practicalTaskConfigs'] as List<dynamic>?)
            ?.map((c) => TaskTypeConfig.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final assessmentsList = (json['assessments'] as List<dynamic>?)
            ?.map((a) => AssessmentModel.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    return CourseModel(
      id: json['id'] as String,
      planId: json['planId'] as String?,
      name: json['name'] as String? ?? '',
      creditHours: json['creditHours'] as int? ?? 3,
      instructorName: json['instructorName'] as String? ?? '',
      practicalInstructorName: json['practicalInstructorName'] as String?,
      hasPractical: json['hasPractical'] as bool? ?? false,
      theoryLecturesCount: json['theoryLecturesCount'] as int? ?? 12,
      practicalLecturesCount: json['practicalLecturesCount'] as int? ?? 0,
      theoryTaskConfigs: theoryConfigsList,
      practicalTaskConfigs: practicalConfigsList,
      assessments: assessmentsList,
      lectures: lecturesList,
    );
  }
}
