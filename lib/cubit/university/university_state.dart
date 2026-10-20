// ============================================================
// UNIVERSITY STATE (V2)
// State management classes for University Tasks
// Supporting Study Plans, synchronized dashboard statistics,
// and isolated courses/lectures per plan.
// ============================================================

import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
import '../../models/study_plan_model.dart';
import '../../models/university_task_model.dart';

abstract class UniversityState {
  const UniversityState();
}

class UniversityInitial extends UniversityState {
  const UniversityInitial();
}

class UniversityLoading extends UniversityState {
  const UniversityLoading();
}

class UniversityLoaded extends UniversityState {
  final List<StudyPlanModel> plans;
  final String? activePlanId;
  final String? message;

  const UniversityLoaded({
    required this.plans,
    this.activePlanId,
    this.message,
  });

  // Get active plan
  StudyPlanModel? get activePlan {
    if (activePlanId != null) {
      try {
        return plans.firstWhere((p) => p.id == activePlanId && p.isActive);
      } catch (_) {}
    }
    // Fallback to first active plan if any
    try {
      return plans.firstWhere((p) => p.isActive);
    } catch (_) {
      return plans.isNotEmpty ? plans.first : null;
    }
  }

  List<StudyPlanModel> get activePlans =>
      plans.where((p) => p.isActive).toList();

  List<StudyPlanModel> get archivedPlans =>
      plans.where((p) => p.isArchived).toList();

  // Active plan's courses
  List<CourseModel> get courses => activePlan?.courses ?? [];

  bool get isFirstTime => plans.isEmpty;

  // Aggregate Statistics (Tied strictly to the ACTIVE PLAN)
  int get totalCourses => activePlan?.totalCourses ?? 0;

  int get totalCreditHours => activePlan?.totalCreditHours ?? 0;

  int get totalLectures => activePlan?.totalLectures ?? 0;

  int get recordedLectures => activePlan?.recordedLectures ?? 0;

  int get totalPresent => activePlan?.totalPresent ?? 0;

  int get totalAbsent => activePlan?.totalAbsent ?? 0;

  int get totalCancelled => activePlan?.totalCancelled ?? 0;

  double get attendanceRate => activePlan?.attendanceRate ?? 0.0;

  int get completedLecturesCount => activePlan?.completedLecturesCount ?? 0;

  double get lectureCompletionRate => activePlan?.lectureCompletionRate ?? 0.0;

  int get totalTasks => activePlan?.totalTasks ?? 0;

  int get completedTasks => activePlan?.completedTasks ?? 0;

  int get pendingTasks => activePlan?.pendingTasks ?? 0;

  double get overallProgress => activePlan?.overallProgress ?? 0.0;

  // Find a specific course in the active plan (or across all plans)
  CourseModel? getCourse(String courseId) {
    if (activePlan != null) {
      try {
        return activePlan!.courses.firstWhere((c) => c.id == courseId);
      } catch (_) {}
    }
    for (final plan in plans) {
      try {
        return plan.courses.firstWhere((c) => c.id == courseId);
      } catch (_) {}
    }
    return null;
  }

  // Find a specific lecture across active plan courses
  LectureModel? getLecture(String courseId, String lectureId) {
    final course = getCourse(courseId);
    if (course == null) return null;
    try {
      return course.lectures.firstWhere((l) => l.id == lectureId);
    } catch (_) {
      return null;
    }
  }

  // Get all lectures that were recorded on a specific date (for active plan)
  List<LectureModel> getLecturesRecordedOn(String dateString) {
    final List<LectureModel> list = [];
    for (final course in courses) {
      for (final lecture in course.lectures) {
        if (lecture.isRecorded && lecture.lectureDate == dateString) {
          list.add(lecture);
        }
      }
    }
    return list;
  }

  // Get all tasks for lectures recorded on a specific date
  List<UniversityTaskModel> getTasksForDate(String dateString) {
    final List<UniversityTaskModel> tasks = [];
    for (final lecture in getLecturesRecordedOn(dateString)) {
      tasks.addAll(lecture.tasks);
    }
    return tasks;
  }

  // Get all lectures recorded within a specific set of dates (week)
  List<LectureModel> getLecturesRecordedInDates(Set<String> dateStrings) {
    final List<LectureModel> list = [];
    for (final course in courses) {
      for (final lecture in course.lectures) {
        if (lecture.isRecorded &&
            lecture.lectureDate != null &&
            dateStrings.contains(lecture.lectureDate)) {
          list.add(lecture);
        }
      }
    }
    return list;
  }

  UniversityLoaded copyWith({
    List<StudyPlanModel>? plans,
    String? activePlanId,
    String? message,
  }) {
    return UniversityLoaded(
      plans: plans ?? this.plans,
      activePlanId: activePlanId ?? this.activePlanId,
      message: message,
    );
  }
}

class UniversityError extends UniversityState {
  final String errorMessage;
  const UniversityError(this.errorMessage);
}
