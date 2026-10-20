// ============================================================
// ASSESSMENT MODEL (V2)
// Model for course grading and academic assessment events.
// Maximum score total across all course assessments must be <= 100.
// ============================================================

enum AssessmentSection {
  theoretical, // نظري
  practical,   // عملي
  finalExam,   // اختبار نهائي عام للمقرر
}

extension AssessmentSectionExtension on AssessmentSection {
  String get displayName {
    switch (this) {
      case AssessmentSection.theoretical:
        return 'نظري';
      case AssessmentSection.practical:
        return 'عملي';
      case AssessmentSection.finalExam:
        return 'اختبار نهائي';
    }
  }

  static AssessmentSection fromString(String value) {
    switch (value) {
      case 'practical':
      case 'عملي':
        return AssessmentSection.practical;
      case 'finalExam':
      case 'final':
      case 'نهائي':
        return AssessmentSection.finalExam;
      default:
        return AssessmentSection.theoretical;
    }
  }
}

class AssessmentModel {
  final String id;
  final String name;
  final AssessmentSection section;
  final double maxScore;
  final bool isCompleted;
  final double? actualScore; // الدرجة الفعلية للطالب
  final String notes;

  const AssessmentModel({
    required this.id,
    required this.name,
    required this.section,
    required this.maxScore,
    this.isCompleted = false,
    this.actualScore,
    this.notes = '',
  });

  AssessmentModel copyWith({
    String? id,
    String? name,
    AssessmentSection? section,
    double? maxScore,
    bool? isCompleted,
    double? actualScore,
    bool clearActualScore = false,
    String? notes,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      maxScore: maxScore ?? this.maxScore,
      isCompleted: isCompleted ?? this.isCompleted,
      actualScore: clearActualScore ? null : (actualScore ?? this.actualScore),
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'section': section.name,
      'maxScore': maxScore,
      'isCompleted': isCompleted,
      'actualScore': actualScore,
      'notes': notes,
    };
  }

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      section: AssessmentSectionExtension.fromString(json['section'] as String? ?? 'theoretical'),
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 10.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      actualScore: (json['actualScore'] as num?)?.toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
