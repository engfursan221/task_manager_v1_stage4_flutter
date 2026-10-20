// ============================================================
// UNIVERSITY CUBIT (V2)
// State management for University Tasks:
// - Courses, Lectures, Attendance, Notes, Tasks
// - Local persistence using UniversityStorageService (SharedPreferences)
// - Compliant with Flutter Bloc Architecture
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/university_storage_service.dart';
import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
import '../../models/university_task_model.dart';
import 'university_state.dart';

class UniversityCubit extends Cubit<UniversityState> {
  final UniversityStorageService _storageService;

  UniversityCubit({UniversityStorageService? storageService})
      : _storageService = storageService ?? UniversityStorageService.instance,
        super(const UniversityInitial()) {
    loadUniversityData();
  }

  static String getTodayString() {
    final now = DateTime.now();
    return formatDate(now);
  }

  static String formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // Load courses from storage
  Future<void> loadUniversityData() async {
    emit(const UniversityLoading());
    try {
      final courses = _storageService.loadCourses();
      if (courses.isEmpty && !_storageService.isUniversityInitialized()) {
        // Seed default representative demo courses so user can test immediately
        final defaultCourses = _generateSampleCourses();
        await _storageService.saveCourses(defaultCourses);
        emit(UniversityLoaded(courses: defaultCourses));
      } else {
        emit(UniversityLoaded(courses: courses));
      }
    } catch (e) {
      emit(UniversityError('حدث خطأ أثناء تحميل بيانات المقررات: $e'));
    }
  }

  // Helper to generate default lectures and tasks for a course
  static List<LectureModel> generateLecturesForCourse({
    required String courseId,
    required String courseName,
    required bool hasPractical,
    required int theoryCount,
    required int practicalCount,
    bool autoTasks = true,
  }) {
    final List<LectureModel> lectures = [];

    // Theoretical lectures
    for (int i = 1; i <= theoryCount; i++) {
      final lectureId = '${courseId}_theory_$i';
      final tasks = autoTasks ? _generateDefaultTheoryTasks(lectureId, courseId) : <UniversityTaskModel>[];

      lectures.add(
        LectureModel(
          id: lectureId,
          courseId: courseId,
          courseName: courseName,
          section: LectureSection.theoretical,
          lectureNumber: i,
          title: 'المحاضرة $i',
          attendanceStatus: AttendanceStatus.none,
          lectureDate: null,
          notes: '',
          tasks: tasks,
        ),
      );
    }

    // Practical lectures (if applicable)
    if (hasPractical) {
      for (int i = 1; i <= practicalCount; i++) {
        final lectureId = '${courseId}_practical_$i';
        final tasks = autoTasks ? _generateDefaultPracticalTasks(lectureId, courseId) : <UniversityTaskModel>[];

        lectures.add(
          LectureModel(
            id: lectureId,
            courseId: courseId,
            courseName: courseName,
            section: LectureSection.practical,
            lectureNumber: i,
            title: 'المحاضرة العملية $i',
            attendanceStatus: AttendanceStatus.none,
            lectureDate: null,
            notes: '',
            tasks: tasks,
          ),
        );
      }
    }

    return lectures;
  }

  static List<UniversityTaskModel> _generateDefaultTheoryTasks(String lectureId, String courseId) {
    final now = DateTime.now();
    return [
      UniversityTaskModel(
        id: '${lectureId}_task_study',
        lectureId: lectureId,
        courseId: courseId,
        title: 'مذاكرة محتوى المحاضرة',
        category: UniversityTaskCategory.study,
        createdAt: now,
      ),
      UniversityTaskModel(
        id: '${lectureId}_task_summary',
        lectureId: lectureId,
        courseId: courseId,
        title: 'إعداد ملخص المحاضرة',
        category: UniversityTaskCategory.summary,
        createdAt: now,
      ),
      UniversityTaskModel(
        id: '${lectureId}_task_review',
        lectureId: lectureId,
        courseId: courseId,
        title: 'مراجعة المفاهيم والأسئلة',
        category: UniversityTaskCategory.review,
        createdAt: now,
      ),
      UniversityTaskModel(
        id: '${lectureId}_task_hw',
        lectureId: lectureId,
        courseId: courseId,
        title: 'حل واجبات المحاضرة',
        category: UniversityTaskCategory.homework,
        createdAt: now,
      ),
    ];
  }

  static List<UniversityTaskModel> _generateDefaultPracticalTasks(String lectureId, String courseId) {
    final now = DateTime.now();
    return [
      UniversityTaskModel(
        id: '${lectureId}_task_practice',
        lectureId: lectureId,
        courseId: courseId,
        title: 'التطبيق العملي وتجربة الكود',
        category: UniversityTaskCategory.practice,
        createdAt: now,
      ),
      UniversityTaskModel(
        id: '${lectureId}_task_study',
        lectureId: lectureId,
        courseId: courseId,
        title: 'مذاكرة تعليمات وتجارب المختبر',
        category: UniversityTaskCategory.study,
        createdAt: now,
      ),
      UniversityTaskModel(
        id: '${lectureId}_task_hw',
        lectureId: lectureId,
        courseId: courseId,
        title: 'تسليم تقرير/واجب العملي',
        category: UniversityTaskCategory.homework,
        createdAt: now,
      ),
    ];
  }

  // Create a new course
  Future<void> addCourse({
    required String name,
    required int creditHours,
    required String instructorName,
    required bool hasPractical,
    required int theoryLecturesCount,
    required int practicalLecturesCount,
    bool autoTasks = true,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final courseId = 'course_${DateTime.now().millisecondsSinceEpoch}';
    final lectures = generateLecturesForCourse(
      courseId: courseId,
      courseName: name,
      hasPractical: hasPractical,
      theoryCount: theoryLecturesCount,
      practicalCount: practicalLecturesCount,
      autoTasks: autoTasks,
    );

    final newCourse = CourseModel(
      id: courseId,
      name: name,
      creditHours: creditHours,
      instructorName: instructorName,
      hasPractical: hasPractical,
      theoryLecturesCount: theoryLecturesCount,
      practicalLecturesCount: practicalLecturesCount,
      lectures: lectures,
    );

    final updated = List<CourseModel>.from(currentState.courses)..add(newCourse);
    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تمت إضافة مقرر $name بنجاح'));
  }

  // Update existing course metadata
  Future<void> updateCourse({
    required String courseId,
    required String name,
    required int creditHours,
    required String instructorName,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        // Also update courseName on all lectures
        final updatedLectures = course.lectures
            .map((l) => l.copyWith(courseName: name))
            .toList();
        return course.copyWith(
          name: name,
          creditHours: creditHours,
          instructorName: instructorName,
          lectures: updatedLectures,
        );
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تم تحديث بيانات مقرر $name بنجاح'));
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updated = currentState.courses.where((c) => c.id != courseId).toList();
    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تم حذف المقرر بنجاح'));
  }

  // Record Attendance for a lecture
  // Rule 6: In the day student takes the lecture, they set حاضر or غائب.
  // Rule 8: Automatically sets lectureDate = today
  // If reset: clears lectureDate
  Future<void> recordAttendance({
    required String courseId,
    required String lectureId,
    required AttendanceStatus status,
    String? customDate,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final targetDate = (status == AttendanceStatus.none)
        ? null
        : (customDate ?? getTodayString());

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        final updatedLectures = course.lectures.map((lecture) {
          if (lecture.id == lectureId) {
            return lecture.copyWith(
              attendanceStatus: status,
              lectureDate: targetDate,
              clearLectureDate: status == AttendanceStatus.none,
            );
          }
          return lecture;
        }).toList();
        return course.copyWith(lectures: updatedLectures);
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    final statusText = status == AttendanceStatus.present
        ? 'حاضر'
        : (status == AttendanceStatus.absent ? 'غائب' : 'إلغاء التسجيل');
    emit(currentState.copyWith(
      courses: updated,
      message: 'تم تسجيل حالة المحاضرة: $statusText في تاريخ $targetDate',
    ));
  }

  // Update Lecture Notes
  Future<void> updateLectureNotes({
    required String courseId,
    required String lectureId,
    required String notes,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        final updatedLectures = course.lectures.map((lecture) {
          if (lecture.id == lectureId) {
            return lecture.copyWith(notes: notes);
          }
          return lecture;
        }).toList();
        return course.copyWith(lectures: updatedLectures);
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تم حفظ ملاحظات المحاضرة'));
  }

  // Add a task to a lecture
  Future<void> addLectureTask({
    required String courseId,
    required String lectureId,
    required String title,
    required UniversityTaskCategory category,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final newTask = UniversityTaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      lectureId: lectureId,
      courseId: courseId,
      title: title,
      category: category,
      status: UniversityTaskStatus.notStarted,
      createdAt: DateTime.now(),
    );

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        final updatedLectures = course.lectures.map((lecture) {
          if (lecture.id == lectureId) {
            final tasks = List<UniversityTaskModel>.from(lecture.tasks)..add(newTask);
            return lecture.copyWith(tasks: tasks);
          }
          return lecture;
        }).toList();
        return course.copyWith(lectures: updatedLectures);
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تمت إضافة المهمة بنجاح'));
  }

  // Update task status (لم تبدأ / قيد التنفيذ / مكتملة)
  Future<void> updateTaskStatus({
    required String courseId,
    required String lectureId,
    required String taskId,
    required UniversityTaskStatus status,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        final updatedLectures = course.lectures.map((lecture) {
          if (lecture.id == lectureId) {
            final tasks = lecture.tasks.map((task) {
              if (task.id == taskId) {
                return task.copyWith(status: status);
              }
              return task;
            }).toList();
            return lecture.copyWith(tasks: tasks);
          }
          return lecture;
        }).toList();
        return course.copyWith(lectures: updatedLectures);
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated));
  }

  // Edit task title and category
  Future<void> updateTask({
    required String courseId,
    required String lectureId,
    required String taskId,
    required String title,
    required UniversityTaskCategory category,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        final updatedLectures = course.lectures.map((lecture) {
          if (lecture.id == lectureId) {
            final tasks = lecture.tasks.map((task) {
              if (task.id == taskId) {
                return task.copyWith(title: title, category: category);
              }
              return task;
            }).toList();
            return lecture.copyWith(tasks: tasks);
          }
          return lecture;
        }).toList();
        return course.copyWith(lectures: updatedLectures);
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تم تحديث المهمة بنجاح'));
  }

  // Delete task from lecture
  Future<void> deleteTask({
    required String courseId,
    required String lectureId,
    required String taskId,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updated = currentState.courses.map((course) {
      if (course.id == courseId) {
        final updatedLectures = course.lectures.map((lecture) {
          if (lecture.id == lectureId) {
            final tasks = lecture.tasks.where((t) => t.id != taskId).toList();
            return lecture.copyWith(tasks: tasks);
          }
          return lecture;
        }).toList();
        return course.copyWith(lectures: updatedLectures);
      }
      return course;
    }).toList();

    await _storageService.saveCourses(updated);
    emit(currentState.copyWith(courses: updated, message: 'تم حذف المهمة بنجاح'));
  }

  // Reset to initial sample state
  Future<void> resetAllUniversityData() async {
    emit(const UniversityLoading());
    final sample = _generateSampleCourses();
    await _storageService.saveCourses(sample);
    emit(UniversityLoaded(courses: sample, message: 'تمت إعادة تعيين بيانات المقررات'));
  }

  // Sample data generation for instant testing on phone
  static List<CourseModel> _generateSampleCourses() {
    final today = getTodayString();

    // 1. Data Structures (with Practical)
    final cs101Id = 'course_cs101';
    final cs101Lectures = generateLecturesForCourse(
      courseId: cs101Id,
      courseName: 'تراكيب البيانات والخوارزميات',
      hasPractical: true,
      theoryCount: 12,
      practicalCount: 10,
    );

    // Mark lecture 1 as present with today's date
    final cs101Updated = cs101Lectures.map((l) {
      if (l.lectureNumber == 1 && l.section == LectureSection.theoretical) {
        return l.copyWith(
          attendanceStatus: AttendanceStatus.present,
          lectureDate: today,
          notes: 'شرح مقدمة في تعقيد الخوارزميات (Big O Notation) ومصفوفات الذاكرة.',
        );
      }
      return l;
    }).toList();

    final course1 = CourseModel(
      id: cs101Id,
      name: 'تراكيب البيانات والخوارزميات',
      creditHours: 3,
      instructorName: 'د. أحمد المهدي',
      hasPractical: true,
      theoryLecturesCount: 12,
      practicalLecturesCount: 10,
      lectures: cs101Updated,
    );

    // 2. Database Systems (without Practical)
    final db201Id = 'course_db201';
    final db201Lectures = generateLecturesForCourse(
      courseId: db201Id,
      courseName: 'نظم قواعد البيانات',
      hasPractical: false,
      theoryCount: 12,
      practicalCount: 0,
    );

    final course2 = CourseModel(
      id: db201Id,
      name: 'نظم قواعد البيانات',
      creditHours: 3,
      instructorName: 'د. منى الشريف',
      hasPractical: false,
      theoryLecturesCount: 12,
      practicalLecturesCount: 0,
      lectures: db201Lectures,
    );

    return [course1, course2];
  }
}
