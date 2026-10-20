// ============================================================
// UNIVERSITY CUBIT (V2)
// State management for University Tasks:
// - Study Plans CRUD & Archiving
// - Active Plan Synchronized Metrics
// - Configurable Academic Tasks & Custom Task Types
// - "Complete All Tasks" Atomic Action
// - "Cancelled" Lecture Status with Reason Handling
// - Theoretical & Practical Separation
// - Course Academic Assessments & 100-Point Grading Validation
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/university_storage_service.dart';
import '../../models/assessment_model.dart';
import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
import '../../models/study_plan_model.dart';
import '../../models/task_type_config.dart';
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

  // Load plans & courses from storage with safe backward-compatibility
  Future<void> loadUniversityData() async {
    emit(const UniversityLoading());
    try {
      var plans = _storageService.loadPlans();
      var activePlanId = _storageService.getActivePlanId();

      if (plans.isEmpty) {
        // Check for legacy courses to migrate safely
        final legacyCourses = _storageService.loadCourses();
        if (legacyCourses.isNotEmpty) {
          final defaultPlan = StudyPlanModel(
            id: 'plan_migrated_${DateTime.now().millisecondsSinceEpoch}',
            name: 'الخطة الحالية (بيانات سابقة)',
            academicYear: '2026-2027',
            semester: 'الفصل الأول',
            status: PlanStatus.active,
            createdAt: DateTime.now(),
            courses: legacyCourses,
          );
          plans = [defaultPlan];
          activePlanId = defaultPlan.id;
          await _storageService.savePlans(plans);
          await _storageService.saveActivePlanId(activePlanId);
        } else if (!_storageService.isUniversityInitialized()) {
          // Seed default sample plan with demo courses for instant testing
          final seedPlan = _generateSamplePlan();
          plans = [seedPlan];
          activePlanId = seedPlan.id;
          await _storageService.savePlans(plans);
          await _storageService.saveActivePlanId(activePlanId);
        }
      }

      if (activePlanId == null && plans.isNotEmpty) {
        activePlanId = plans.first.id;
      }

      emit(UniversityLoaded(plans: plans, activePlanId: activePlanId));
    } catch (e) {
      emit(UniversityError('حدث خطأ أثناء تحميل بيانات الخطط الدراسية: $e'));
    }
  }

  // --- STUDY PLANS CRUD ---

  Future<void> addPlan({
    required String name,
    String? academicYear,
    String? semester,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final newPlan = StudyPlanModel(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      academicYear: academicYear,
      semester: semester,
      status: PlanStatus.active,
      createdAt: DateTime.now(),
      courses: const [],
    );

    final updatedPlans = [...currentState.plans, newPlan];
    // If it's the only plan or user requested, set as active
    final newActiveId = currentState.plans.isEmpty ? newPlan.id : currentState.activePlanId;

    await _storageService.savePlans(updatedPlans);
    if (newActiveId != currentState.activePlanId && newActiveId != null) {
      await _storageService.saveActivePlanId(newActiveId);
    }

    emit(currentState.copyWith(
      plans: updatedPlans,
      activePlanId: newActiveId,
      message: 'تم إنشاء الخطة الدراسية بنجاح',
    ));
  }

  Future<void> updatePlan({
    required String planId,
    required String name,
    String? academicYear,
    String? semester,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((p) {
      if (p.id == planId) {
        return p.copyWith(
          name: name,
          academicYear: academicYear,
          semester: semester,
        );
      }
      return p;
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تم تحديث بيانات الخطة'));
  }

  Future<void> setActivePlan(String planId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    await _storageService.saveActivePlanId(planId);
    emit(currentState.copyWith(
      activePlanId: planId,
      message: 'تم تفعيل الخطة الدراسية',
    ));
  }

  Future<void> archivePlan(String planId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((p) {
      if (p.id == planId) {
        return p.copyWith(status: PlanStatus.archived);
      }
      return p;
    }).toList();

    // If active plan was archived, pick next active plan
    String? newActiveId = currentState.activePlanId;
    if (currentState.activePlanId == planId) {
      final nextActive = updatedPlans.where((p) => p.isActive).firstOrNull;
      newActiveId = nextActive?.id;
      if (newActiveId != null) {
        await _storageService.saveActivePlanId(newActiveId);
      }
    }

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(
      plans: updatedPlans,
      activePlanId: newActiveId,
      message: 'تمت أرشفة الخطة الدراسية',
    ));
  }

  Future<void> restorePlan(String planId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((p) {
      if (p.id == planId) {
        return p.copyWith(status: PlanStatus.active);
      }
      return p;
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(
      plans: updatedPlans,
      message: 'تمت استعادة الخطة بنجاح',
    ));
  }

  Future<void> deletePlan(String planId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.where((p) => p.id != planId).toList();
    String? newActiveId = currentState.activePlanId;
    if (currentState.activePlanId == planId) {
      final nextActive = updatedPlans.where((p) => p.isActive).firstOrNull;
      newActiveId = nextActive?.id;
      if (newActiveId != null) {
        await _storageService.saveActivePlanId(newActiveId);
      }
    }

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(
      plans: updatedPlans,
      activePlanId: newActiveId,
      message: 'تم حذف الخطة ومقرراتها نهائياً',
    ));
  }

  // --- COURSE CRUD (Tied to Active Plan) ---

  Future<void> addCourse({
    required String name,
    required int creditHours,
    required String instructorName,
    String? practicalInstructorName,
    required bool hasPractical,
    required int theoryLecturesCount,
    required int practicalLecturesCount,
    List<TaskTypeConfig>? theoryTaskConfigs,
    List<TaskTypeConfig>? practicalTaskConfigs,
    bool autoTasks = true,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;
    final activePlan = currentState.activePlan;
    if (activePlan == null) return;

    final courseId = 'course_${DateTime.now().millisecondsSinceEpoch}';

    final effectiveTheoryConfigs = theoryTaskConfigs ?? defaultTaskConfigs();
    final effectivePracticalConfigs = practicalTaskConfigs ?? defaultTaskConfigs();

    final lectures = generateLecturesForCourse(
      courseId: courseId,
      courseName: name,
      hasPractical: hasPractical,
      theoryCount: theoryLecturesCount,
      practicalCount: practicalLecturesCount,
      theoryConfigs: effectiveTheoryConfigs,
      practicalConfigs: effectivePracticalConfigs,
      autoTasks: autoTasks,
    );

    final newCourse = CourseModel(
      id: courseId,
      planId: activePlan.id,
      name: name,
      creditHours: creditHours,
      instructorName: instructorName,
      practicalInstructorName: hasPractical ? practicalInstructorName : null,
      hasPractical: hasPractical,
      theoryLecturesCount: theoryLecturesCount,
      practicalLecturesCount: hasPractical ? practicalLecturesCount : 0,
      theoryTaskConfigs: effectiveTheoryConfigs,
      practicalTaskConfigs: effectivePracticalConfigs,
      assessments: const [],
      lectures: lectures,
    );

    final updatedCourses = [...activePlan.courses, newCourse];
    final updatedPlan = activePlan.copyWith(courses: updatedCourses);
    final updatedPlans = currentState.plans.map((p) => p.id == activePlan.id ? updatedPlan : p).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تمت إضافة المقرر بنجاح'));
  }

  Future<void> updateCourse({
    required String courseId,
    required String name,
    required int creditHours,
    required String instructorName,
    String? practicalInstructorName,
    List<TaskTypeConfig>? theoryTaskConfigs,
    List<TaskTypeConfig>? practicalTaskConfigs,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final oldCourse = plan.courses[courseIndex];
      final updatedCourse = oldCourse.copyWith(
        name: name,
        creditHours: creditHours,
        instructorName: instructorName,
        practicalInstructorName: oldCourse.hasPractical ? practicalInstructorName : null,
        theoryTaskConfigs: theoryTaskConfigs ?? oldCourse.theoryTaskConfigs,
        practicalTaskConfigs: practicalTaskConfigs ?? oldCourse.practicalTaskConfigs,
      );

      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;
      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تم تعديل المقرر بنجاح'));
  }

  Future<void> deleteCourse(String courseId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      if (!plan.courses.any((c) => c.id == courseId)) return plan;
      final newCourses = plan.courses.where((c) => c.id != courseId).toList();
      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تم حذف المقرر'));
  }

  // --- LECTURE OPERATIONS ---

  Future<void> recordAttendance(
    String courseId,
    String lectureId,
    AttendanceStatus status, {
    String? customDate,
    String? cancellationReason,
  }) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final recordedDate = (status == AttendanceStatus.none)
        ? null
        : (customDate ?? getTodayString());

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      final updatedLecture = oldLecture.copyWith(
        attendanceStatus: status,
        lectureDate: recordedDate,
        clearLectureDate: status == AttendanceStatus.none,
        cancellationReason: status == AttendanceStatus.cancelled ? cancellationReason : null,
        clearCancellationReason: status != AttendanceStatus.cancelled,
      );

      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans));
  }

  // Atomic "Complete All Tasks" for a lecture
  Future<void> completeAllLectureTasks(String courseId, String lectureId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      if (oldLecture.isCancelled) return plan; // Do not complete if cancelled

      final updatedTasks = oldLecture.tasks.map((t) => t.copyWith(status: UniversityTaskStatus.completed)).toList();
      final updatedLecture = oldLecture.copyWith(tasks: updatedTasks);

      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تم إنجاز جميع مهام المحاضرة'));
  }

  Future<void> updateLectureNotes(String courseId, String lectureId, String notes) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      final updatedLecture = oldLecture.copyWith(notes: notes);

      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans));
  }

  // --- LECTURE TASKS CRUD ---

  Future<void> addLectureTask(
    String courseId,
    String lectureId,
    String title,
    UniversityTaskCategory category,
  ) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final taskId = 'task_${DateTime.now().millisecondsSinceEpoch}';
    final newTask = UniversityTaskModel(
      id: taskId,
      lectureId: lectureId,
      courseId: courseId,
      title: title,
      category: category,
      status: UniversityTaskStatus.notStarted,
      createdAt: DateTime.now(),
    );

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      final updatedLecture = oldLecture.copyWith(tasks: [...oldLecture.tasks, newTask]);

      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans));
  }

  Future<void> updateTaskStatus(
    String courseId,
    String lectureId,
    String taskId,
    UniversityTaskStatus status,
  ) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      final updatedTasks = oldLecture.tasks.map((t) {
        if (t.id == taskId) return t.copyWith(status: status);
        return t;
      }).toList();

      final updatedLecture = oldLecture.copyWith(tasks: updatedTasks);
      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans));
  }

  Future<void> updateTask(
    String courseId,
    String lectureId,
    String taskId,
    String title,
    UniversityTaskCategory category,
  ) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      final updatedTasks = oldLecture.tasks.map((t) {
        if (t.id == taskId) return t.copyWith(title: title, category: category);
        return t;
      }).toList();

      final updatedLecture = oldLecture.copyWith(tasks: updatedTasks);
      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans));
  }

  Future<void> deleteTask(String courseId, String lectureId, String taskId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final course = plan.courses[courseIndex];
      final lectureIndex = course.lectures.indexWhere((l) => l.id == lectureId);
      if (lectureIndex == -1) return plan;

      final oldLecture = course.lectures[lectureIndex];
      final updatedTasks = oldLecture.tasks.where((t) => t.id != taskId).toList();

      final updatedLecture = oldLecture.copyWith(tasks: updatedTasks);
      final newLectures = List<LectureModel>.from(course.lectures);
      newLectures[lectureIndex] = updatedLecture;

      final updatedCourse = course.copyWith(lectures: newLectures);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;

      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans));
  }

  // --- ACADEMIC ASSESSMENTS & GRADING (Max Score <= 100 validation) ---

  Future<bool> addAssessment(String courseId, AssessmentModel assessment) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return false;

    final course = currentState.getCourse(courseId);
    if (course == null) return false;

    // Validation: Total allocated score must not exceed 100
    if (course.totalAllocatedScore + assessment.maxScore > 100.0) {
      emit(currentState.copyWith(message: 'مجموع درجات المقرر لا يمكن أن يتجاوز 100 درجة'));
      return false;
    }

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final c = plan.courses[courseIndex];
      final updatedAssessments = [...c.assessments, assessment];
      final updatedCourse = c.copyWith(assessments: updatedAssessments);

      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;
      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تمت إضافة عنصر التقييم'));
    return true;
  }

  Future<bool> updateAssessment(String courseId, AssessmentModel updatedAssessment) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return false;

    final course = currentState.getCourse(courseId);
    if (course == null) return false;

    // Check sum without current element
    final otherScores = course.assessments
        .where((a) => a.id != updatedAssessment.id)
        .fold(0.0, (sum, a) => sum + a.maxScore);

    if (otherScores + updatedAssessment.maxScore > 100.0) {
      emit(currentState.copyWith(message: 'مجموع درجات المقرر لا يمكن أن يتجاوز 100 درجة'));
      return false;
    }

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final c = plan.courses[courseIndex];
      final updatedAssessments = c.assessments.map((a) {
        if (a.id == updatedAssessment.id) return updatedAssessment;
        return a;
      }).toList();

      final updatedCourse = c.copyWith(assessments: updatedAssessments);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;
      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تم تحديث التقييم بنجاح'));
    return true;
  }

  Future<void> deleteAssessment(String courseId, String assessmentId) async {
    final currentState = state;
    if (currentState is! UniversityLoaded) return;

    final updatedPlans = currentState.plans.map((plan) {
      final courseIndex = plan.courses.indexWhere((c) => c.id == courseId);
      if (courseIndex == -1) return plan;

      final c = plan.courses[courseIndex];
      final updatedAssessments = c.assessments.where((a) => a.id != assessmentId).toList();

      final updatedCourse = c.copyWith(assessments: updatedAssessments);
      final newCourses = List<CourseModel>.from(plan.courses);
      newCourses[courseIndex] = updatedCourse;
      return plan.copyWith(courses: newCourses);
    }).toList();

    await _storageService.savePlans(updatedPlans);
    emit(currentState.copyWith(plans: updatedPlans, message: 'تم حذف عنصر التقييم'));
  }

  // --- DEFAULTS & GENERATORS ---

  static List<TaskTypeConfig> defaultTaskConfigs() {
    return const [
      TaskTypeConfig(key: 'attendance', name: 'الحضور والغياب', enabled: true),
      TaskTypeConfig(key: 'study', name: 'المذاكرة', enabled: true),
      TaskTypeConfig(key: 'homework', name: 'التكاليف والواجبات', enabled: true),
      TaskTypeConfig(key: 'notes', name: 'الملاحظات', enabled: true),
    ];
  }

  static List<LectureModel> generateLecturesForCourse({
    required String courseId,
    required String courseName,
    required bool hasPractical,
    required int theoryCount,
    required int practicalCount,
    required List<TaskTypeConfig> theoryConfigs,
    required List<TaskTypeConfig> practicalConfigs,
    bool autoTasks = true,
  }) {
    final List<LectureModel> lectures = [];

    // Theoretical lectures
    for (int i = 1; i <= theoryCount; i++) {
      final lectureId = '${courseId}_theory_$i';
      final tasks = autoTasks ? _generateTasksFromConfigs(lectureId, courseId, theoryConfigs, LectureSection.theoretical) : <UniversityTaskModel>[];

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

    // Practical lectures
    if (hasPractical) {
      for (int i = 1; i <= practicalCount; i++) {
        final lectureId = '${courseId}_practical_$i';
        final tasks = autoTasks ? _generateTasksFromConfigs(lectureId, courseId, practicalConfigs, LectureSection.practical) : <UniversityTaskModel>[];

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

  static List<UniversityTaskModel> _generateTasksFromConfigs(
    String lectureId,
    String courseId,
    List<TaskTypeConfig> configs,
    LectureSection section,
  ) {
    final now = DateTime.now();
    final List<UniversityTaskModel> tasks = [];

    final studyCfg = configs.where((c) => c.key == 'study' && c.enabled).firstOrNull;
    if (studyCfg != null) {
      tasks.add(
        UniversityTaskModel(
          id: '${lectureId}_task_study',
          lectureId: lectureId,
          courseId: courseId,
          title: section == LectureSection.theoretical
              ? 'مذاكرة وتلخيص موضوع المحاضرة'
              : 'مراجعة وتطبيق الأكواد المعملية',
          category: section == LectureSection.theoretical
              ? UniversityTaskCategory.study
              : UniversityTaskCategory.practice,
          status: UniversityTaskStatus.notStarted,
          createdAt: now,
          isRequired: true,
        ),
      );
    }

    final homeworkCfg = configs.where((c) => c.key == 'homework' && c.enabled).firstOrNull;
    if (homeworkCfg != null) {
      tasks.add(
        UniversityTaskModel(
          id: '${lectureId}_task_homework',
          lectureId: lectureId,
          courseId: courseId,
          title: section == LectureSection.theoretical
              ? 'حل تكليف وتمارين المحاضرة'
              : 'تسليم التقرير العملي للمعمل',
          category: UniversityTaskCategory.homework,
          status: UniversityTaskStatus.notStarted,
          createdAt: now,
          isRequired: false,
        ),
      );
    }

    // Custom enabled tasks
    for (final cfg in configs.where((c) => c.isCustom && c.enabled)) {
      tasks.add(
        UniversityTaskModel(
          id: '${lectureId}_${cfg.key}',
          lectureId: lectureId,
          courseId: courseId,
          title: cfg.name,
          category: UniversityTaskCategory.custom,
          status: UniversityTaskStatus.notStarted,
          createdAt: now,
          isRequired: false,
        ),
      );
    }

    return tasks;
  }

  static StudyPlanModel _generateSamplePlan() {
    final planId = 'plan_demo_2026';
    final courseId1 = 'course_demo_dsa';
    final courseId2 = 'course_demo_db';

    final defaultConfigs = defaultTaskConfigs();

    final course1 = CourseModel(
      id: courseId1,
      planId: planId,
      name: 'تراكيب البيانات والخوارزميات',
      creditHours: 3,
      instructorName: 'د. أحمد السعيد',
      practicalInstructorName: 'م. مروان خالد',
      hasPractical: true,
      theoryLecturesCount: 12,
      practicalLecturesCount: 10,
      theoryTaskConfigs: defaultConfigs,
      practicalTaskConfigs: defaultConfigs,
      assessments: [
        const AssessmentModel(
          id: 'asm_dsa_mid',
          name: 'اختبار نصفي نظري',
          section: AssessmentSection.theoretical,
          maxScore: 20,
          isCompleted: false,
        ),
        const AssessmentModel(
          id: 'asm_dsa_prac_mid',
          name: 'اختبار نصفي عملي',
          section: AssessmentSection.practical,
          maxScore: 15,
          isCompleted: false,
        ),
        const AssessmentModel(
          id: 'asm_dsa_final',
          name: 'الاختبار النهائي العام',
          section: AssessmentSection.finalExam,
          maxScore: 40,
          isCompleted: false,
        ),
      ],
      lectures: generateLecturesForCourse(
        courseId: courseId1,
        courseName: 'تراكيب البيانات والخوارزميات',
        hasPractical: true,
        theoryCount: 12,
        practicalCount: 10,
        theoryConfigs: defaultConfigs,
        practicalConfigs: defaultConfigs,
      ),
    );

    final course2 = CourseModel(
      id: courseId2,
      planId: planId,
      name: 'نظم إدارة قواعد البيانات',
      creditHours: 3,
      instructorName: 'د. سارة المنصور',
      hasPractical: false,
      theoryLecturesCount: 12,
      practicalLecturesCount: 0,
      theoryTaskConfigs: defaultConfigs,
      assessments: [
        const AssessmentModel(
          id: 'asm_db_mid',
          name: 'اختبار فصلي',
          section: AssessmentSection.theoretical,
          maxScore: 30,
          isCompleted: false,
        ),
        const AssessmentModel(
          id: 'asm_db_final',
          name: 'الاختبار النهائي',
          section: AssessmentSection.finalExam,
          maxScore: 50,
          isCompleted: false,
        ),
      ],
      lectures: generateLecturesForCourse(
        courseId: courseId2,
        courseName: 'نظم إدارة قواعد البيانات',
        hasPractical: false,
        theoryCount: 12,
        practicalCount: 0,
        theoryConfigs: defaultConfigs,
        practicalConfigs: defaultConfigs,
      ),
    );

    return StudyPlanModel(
      id: planId,
      name: 'الفصل الدراسي الأول 2026-2027',
      academicYear: '2026-2027',
      semester: 'الفصل الأول',
      status: PlanStatus.active,
      createdAt: DateTime.now(),
      courses: [course1, course2],
    );
  }
}
