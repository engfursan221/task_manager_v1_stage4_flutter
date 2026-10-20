// ============================================================
// COURSE MODEL (V2)
// Model representing a university course.
// - Course Name (اسم المقرر)
// - Credit Hours (عدد الساعات المعتمدة)
// - Instructor Name (اسم الدكتور/المحاضر)
// - Has Practical/Lab (هل يحتوي على عملي/مختبر)
// - Theoretical Lectures & Practical Lectures
// ============================================================

import 'lecture_model.dart';

class CourseModel {
  final String id;
  final String name;
  final int creditHours;
  final String instructorName;
  final bool hasPractical;
  final int theoryLecturesCount;
  final int practicalLecturesCount;
  final List<LectureModel> lectures;

  const CourseModel({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.instructorName,
    required this.hasPractical,
    required this.theoryLecturesCount,
    this.practicalLecturesCount = 0,
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

  double get courseProgress {
    if (totalLecturesCount == 0) return 0.0;
    return recordedLecturesCount / totalLecturesCount;
  }

  CourseModel copyWith({
    String? id,
    String? name,
    int? creditHours,
    String? instructorName,
    bool? hasPractical,
    int? theoryLecturesCount,
    int? practicalLecturesCount,
    List<LectureModel>? lectures,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creditHours: creditHours ?? this.creditHours,
      instructorName: instructorName ?? this.instructorName,
      hasPractical: hasPractical ?? this.hasPractical,
      theoryLecturesCount: theoryLecturesCount ?? this.theoryLecturesCount,
      practicalLecturesCount: practicalLecturesCount ?? this.practicalLecturesCount,
      lectures: lectures ?? this.lectures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creditHours': creditHours,
      'instructorName': instructorName,
      'hasPractical': hasPractical,
      'theoryLecturesCount': theoryLecturesCount,
      'practicalLecturesCount': practicalLecturesCount,
      'lectures': lectures.map((l) => l.toJson()).toList(),
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final lecturesList = (json['lectures'] as List<dynamic>?)
            ?.map((l) => LectureModel.fromJson(l as Map<String, dynamic>))
            .toList() ??
        [];

    return CourseModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      creditHours: json['creditHours'] as int? ?? 3,
      instructorName: json['instructorName'] as String? ?? '',
      hasPractical: json['hasPractical'] as bool? ?? false,
      theoryLecturesCount: json['theoryLecturesCount'] as int? ?? 12,
      practicalLecturesCount: json['practicalLecturesCount'] as int? ?? 0,
      lectures: lecturesList,
    );
  }
}
