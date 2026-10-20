// ============================================================
// STUDY PLAN MODEL (V2)
// Model representing an independent academic study plan / semester.
// Contains its own isolated list of courses, lectures, tasks, and assessments.
// ============================================================

import 'course_model.dart';

enum PlanStatus {
  active,   // نشطة
  archived, // مؤرشفة
}

extension PlanStatusExtension on PlanStatus {
  String get displayName {
    switch (this) {
      case PlanStatus.active:
        return 'نشطة';
      case PlanStatus.archived:
        return 'مؤرشفة';
    }
  }

  static PlanStatus fromString(String value) {
    if (value == 'archived' || value == 'مؤرشفة') {
      return PlanStatus.archived;
    }
    return PlanStatus.active;
  }
}

class StudyPlanModel {
  final String id;
  final String name;
  final String? academicYear;
  final String? semester;
  final PlanStatus status;
  final DateTime createdAt;
  final List<CourseModel> courses;

  const StudyPlanModel({
    required this.id,
    required this.name,
    this.academicYear,
    this.semester,
    this.status = PlanStatus.active,
    required this.createdAt,
    this.courses = const [],
  });

  bool get isActive => status == PlanStatus.active;
  bool get isArchived => status == PlanStatus.archived;

  int get totalCourses => courses.length;

  int get totalCreditHours =>
      courses.fold(0, (sum, c) => sum + c.creditHours);

  int get totalLectures =>
      courses.fold(0, (sum, c) => sum + c.totalLecturesCount);

  int get recordedLectures =>
      courses.fold(0, (sum, c) => sum + c.recordedLecturesCount);

  int get totalPresent =>
      courses.fold(0, (sum, c) => sum + c.presentCount);

  int get totalAbsent =>
      courses.fold(0, (sum, c) => sum + c.absentCount);

  int get totalCancelled =>
      courses.fold(0, (sum, c) => sum + c.cancelledCount);

  // Attendance rate excluding cancelled lectures: present / (present + absent)
  double get attendanceRate {
    final eligible = totalPresent + totalAbsent;
    if (eligible == 0) return 0.0;
    return (totalPresent / eligible) * 100.0;
  }

  int get completedLecturesCount =>
      courses.fold(0, (sum, c) => sum + c.completedLecturesCount);

  // Lecture completion rate
  double get lectureCompletionRate {
    final eligible = totalLectures - totalCancelled;
    if (eligible <= 0) return 0.0;
    return (completedLecturesCount / eligible) * 100.0;
  }

  int get totalTasks =>
      courses.fold(0, (sum, c) => sum + c.totalTasksCount);

  int get completedTasks =>
      courses.fold(0, (sum, c) => sum + c.completedTasksCount);

  int get pendingTasks => totalTasks - completedTasks;

  double get overallProgress {
    if (totalLectures == 0) return 0.0;
    return recordedLectures / totalLectures;
  }

  StudyPlanModel copyWith({
    String? id,
    String? name,
    String? academicYear,
    String? semester,
    PlanStatus? status,
    DateTime? createdAt,
    List<CourseModel>? courses,
  }) {
    return StudyPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      semester: semester ?? this.semester,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      courses: courses ?? this.courses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'academicYear': academicYear,
      'semester': semester,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    final coursesList = (json['courses'] as List<dynamic>?)
            ?.map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final createdAtStr = json['createdAt'] as String?;
    final dt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return StudyPlanModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'خطة دراسية',
      academicYear: json['academicYear'] as String?,
      semester: json['semester'] as String?,
      status: PlanStatusExtension.fromString(json['status'] as String? ?? 'active'),
      createdAt: dt ?? DateTime.now(),
      courses: coursesList,
    );
  }
}
