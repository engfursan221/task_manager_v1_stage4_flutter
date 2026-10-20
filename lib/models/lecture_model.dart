// ============================================================
// LECTURE MODEL (V2)
// Model representing a theoretical or practical lecture.
// - Section: theoretical (نظري) / practical (عملي)
// - Attendance: none (لم يسجل) / present (حاضر) / absent (غائب)
// - Attendance date is null until student registers attendance
// - Notes attached directly to the lecture
// - Tasks linked to the lecture
// ============================================================

import 'university_task_model.dart';

enum LectureSection {
  theoretical, // نظري
  practical, // عملي
}

extension LectureSectionExtension on LectureSection {
  String get displayName {
    switch (this) {
      case LectureSection.theoretical:
        return 'نظري';
      case LectureSection.practical:
        return 'عملي';
    }
  }

  static LectureSection fromString(String value) {
    if (value == 'practical' || value == 'عملي') {
      return LectureSection.practical;
    }
    return LectureSection.theoretical;
  }
}

enum AttendanceStatus {
  none, // لم يسجل
  present, // حاضر
  absent, // غائب
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.none:
        return 'لم يسجل';
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
    }
  }

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'present':
      case 'حاضر':
        return AttendanceStatus.present;
      case 'absent':
      case 'غائب':
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.none;
    }
  }
}

class LectureModel {
  final String id;
  final String courseId;
  final String courseName;
  final LectureSection section;
  final int lectureNumber;
  final String title;
  final AttendanceStatus attendanceStatus;
  final String? lectureDate; // e.g. "2026-09-03" - null until recorded
  final String notes;
  final List<UniversityTaskModel> tasks;

  const LectureModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.section,
    required this.lectureNumber,
    required this.title,
    this.attendanceStatus = AttendanceStatus.none,
    this.lectureDate,
    this.notes = '',
    this.tasks = const [],
  });

  bool get isRecorded => attendanceStatus != AttendanceStatus.none && lectureDate != null;
  bool get isPresent => attendanceStatus == AttendanceStatus.present;
  bool get isAbsent => attendanceStatus == AttendanceStatus.absent;

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  int get totalTasksCount => tasks.length;
  double get taskProgress => totalTasksCount == 0 ? 0.0 : completedTasksCount / totalTasksCount;

  LectureModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    LectureSection? section,
    int? lectureNumber,
    String? title,
    AttendanceStatus? attendanceStatus,
    String? lectureDate,
    bool clearLectureDate = false,
    String? notes,
    List<UniversityTaskModel>? tasks,
  }) {
    return LectureModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      section: section ?? this.section,
      lectureNumber: lectureNumber ?? this.lectureNumber,
      title: title ?? this.title,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      lectureDate: clearLectureDate ? null : (lectureDate ?? this.lectureDate),
      notes: notes ?? this.notes,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'section': section.name,
      'lectureNumber': lectureNumber,
      'title': title,
      'attendanceStatus': attendanceStatus.name,
      'lectureDate': lectureDate,
      'notes': notes,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    final tasksList = (json['tasks'] as List<dynamic>?)
            ?.map((t) => UniversityTaskModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    return LectureModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String? ?? '',
      section: LectureSectionExtension.fromString(json['section'] as String? ?? 'theoretical'),
      lectureNumber: json['lectureNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'المحاضرة',
      attendanceStatus:
          AttendanceStatusExtension.fromString(json['attendanceStatus'] as String? ?? 'none'),
      lectureDate: json['lectureDate'] as String?,
      notes: json['notes'] as String? ?? '',
      tasks: tasksList,
    );
  }
}
