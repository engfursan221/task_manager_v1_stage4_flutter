// ============================================================
// UNIVERSITY STATE (V2)
// State management classes for University Tasks
// ============================================================

import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
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
  final List<CourseModel> courses;
  final String? message;

  const UniversityLoaded({
    required this.courses,
    this.message,
  });

  bool get isFirstTime => courses.isEmpty;

  // Aggregate Statistics
  int get totalCourses => courses.length;

  int get totalLectures {
    int total = 0;
    for (final c in courses) {
      total += c.totalLecturesCount;
    }
    return total;
  }

  int get recordedLectures {
    int count = 0;
    for (final c in courses) {
      count += c.recordedLecturesCount;
    }
    return count;
  }

  int get totalPresent {
    int count = 0;
    for (final c in courses) {
      count += c.presentCount;
    }
    return count;
  }

  int get totalAbsent {
    int count = 0;
    for (final c in courses) {
      count += c.absentCount;
    }
    return count;
  }

  int get totalTasks {
    int count = 0;
    for (final c in courses) {
      count += c.totalTasksCount;
    }
    return count;
  }

  int get completedTasks {
    int count = 0;
    for (final c in courses) {
      count += c.completedTasksCount;
    }
    return count;
  }

  int get pendingTasks => totalTasks - completedTasks;

  double get overallProgress {
    if (totalLectures == 0) return 0.0;
    return recordedLectures / totalLectures;
  }

  // Find a specific course
  CourseModel? getCourse(String courseId) {
    try {
      return courses.firstWhere((c) => c.id == courseId);
    } catch (_) {
      return null;
    }
  }

  // Find a specific lecture across all courses
  LectureModel? getLecture(String courseId, String lectureId) {
    final course = getCourse(courseId);
    if (course == null) return null;
    try {
      return course.lectures.firstWhere((l) => l.id == lectureId);
    } catch (_) {
      return null;
    }
  }

  // Get all lectures that were recorded on a specific date (e.g. today: "YYYY-MM-DD")
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

  // Get all lectures recorded within a specific list of dates (week)
  List<LectureModel> getLecturesRecordedInDates(Set<String> dateStrings) {
    final List<LectureModel> list = [];
    for (final course in courses) {
      for (final lecture in course.lectures) {
        if (lecture.isRecorded && lecture.lectureDate != null && dateStrings.contains(lecture.lectureDate)) {
          list.add(lecture);
        }
      }
    }
    return list;
  }

  UniversityLoaded copyWith({
    List<CourseModel>? courses,
    String? message,
  }) {
    return UniversityLoaded(
      courses: courses ?? this.courses,
      message: message,
    );
  }
}

class UniversityError extends UniversityState {
  final String errorMessage;
  const UniversityError(this.errorMessage);
}
