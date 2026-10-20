// ============================================================
// UNIVERSITY TASK MODEL (V2)
// Model representing a task linked to a university lecture.
// Categories: مذاكرة، تطبيق، واجبات، ملخص، مراجعة، مهمة مخصصة
// Statuses: لم تبدأ، قيد التنفيذ، مكتملة
// ============================================================

enum UniversityTaskCategory {
  study, // مذاكرة
  practice, // تطبيق
  homework, // واجبات
  summary, // ملخص
  review, // مراجعة
  custom, // مهمة مخصصة
}

extension UniversityTaskCategoryExtension on UniversityTaskCategory {
  String get displayName {
    switch (this) {
      case UniversityTaskCategory.study:
        return 'مذاكرة';
      case UniversityTaskCategory.practice:
        return 'تطبيق';
      case UniversityTaskCategory.homework:
        return 'تكاليف';
      case UniversityTaskCategory.summary:
        return 'ملخص';
      case UniversityTaskCategory.review:
        return 'مراجعة';
      case UniversityTaskCategory.custom:
        return 'مهمة مخصصة';
    }
  }

  static UniversityTaskCategory fromString(String value) {
    switch (value) {
      case 'study':
      case 'مذاكرة':
        return UniversityTaskCategory.study;
      case 'practice':
      case 'تطبيق':
        return UniversityTaskCategory.practice;
      case 'homework':
      case 'تكاليف':
      case 'تكليف':
        return UniversityTaskCategory.homework;
      case 'summary':
      case 'ملخص':
        return UniversityTaskCategory.summary;
      case 'review':
      case 'مراجعة':
        return UniversityTaskCategory.review;
      default:
        return UniversityTaskCategory.custom;
    }
  }
}

enum UniversityTaskStatus {
  notStarted, // لم تبدأ
  inProgress, // قيد التنفيذ
  completed, // مكتملة
}

extension UniversityTaskStatusExtension on UniversityTaskStatus {
  String get displayName {
    switch (this) {
      case UniversityTaskStatus.notStarted:
        return 'لم تبدأ';
      case UniversityTaskStatus.inProgress:
        return 'قيد التنفيذ';
      case UniversityTaskStatus.completed:
        return 'مكتملة';
    }
  }

  static UniversityTaskStatus fromString(String value) {
    switch (value) {
      case 'completed':
      case 'مكتملة':
        return UniversityTaskStatus.completed;
      case 'inProgress':
      case 'قيد التنفيذ':
        return UniversityTaskStatus.inProgress;
      default:
        return UniversityTaskStatus.notStarted;
    }
  }
}

class UniversityTaskModel {
  final String id;
  final String lectureId;
  final String courseId;
  final String title;
  final UniversityTaskCategory category;
  final UniversityTaskStatus status;
  final DateTime createdAt;

  const UniversityTaskModel({
    required this.id,
    required this.lectureId,
    required this.courseId,
    required this.title,
    required this.category,
    this.status = UniversityTaskStatus.notStarted,
    required this.createdAt,
  });

  bool get isCompleted => status == UniversityTaskStatus.completed;

  UniversityTaskModel copyWith({
    String? id,
    String? lectureId,
    String? courseId,
    String? title,
    UniversityTaskCategory? category,
    UniversityTaskStatus? status,
    DateTime? createdAt,
  }) {
    return UniversityTaskModel(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectureId': lectureId,
      'courseId': courseId,
      'title': title,
      'category': category.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UniversityTaskModel.fromJson(Map<String, dynamic> json) {
    return UniversityTaskModel(
      id: json['id'] as String,
      lectureId: json['lectureId'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      category: UniversityTaskCategoryExtension.fromString(json['category'] as String? ?? 'custom'),
      status: UniversityTaskStatusExtension.fromString(json['status'] as String? ?? 'notStarted'),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
