// ============================================================
// UNIVERSITY STORAGE SERVICE (V2)
// Handles local JSON persistence for study plans, courses,
// lectures, attendance, notes, tasks, and assessments via SharedPreferences.
// Includes safe legacy data migration.
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/course_model.dart';
import '../../models/study_plan_model.dart';

class UniversityStorageService {
  static UniversityStorageService? _instance;
  static SharedPreferences? _preferences;

  UniversityStorageService._();

  static UniversityStorageService get instance {
    _instance ??= UniversityStorageService._();
    return _instance!;
  }

  static const String keyPlans = 'v2_university_study_plans';
  static const String keyActivePlanId = 'v2_active_study_plan_id';
  static const String keyCourses = 'v2_university_courses'; // Legacy key for backward compat
  static const String keyIsInitialized = 'v2_university_is_initialized';
  static const String keyActiveMode = 'v2_active_task_mode'; // 'normal' or 'university'

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // --- STUDY PLANS PERSISTENCE ---

  Future<bool> savePlans(List<StudyPlanModel> plans) async {
    if (_preferences == null) await init();
    final jsonList = plans.map((p) => p.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    await _preferences?.setBool(keyIsInitialized, true);
    return await _preferences?.setString(keyPlans, encoded) ?? false;
  }

  List<StudyPlanModel> loadPlans() {
    final raw = _preferences?.getString(keyPlans);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => StudyPlanModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveActivePlanId(String planId) async {
    if (_preferences == null) await init();
    return await _preferences?.setString(keyActivePlanId, planId) ?? false;
  }

  String? getActivePlanId() {
    return _preferences?.getString(keyActivePlanId);
  }

  // --- LEGACY COURSES (Backward Compatibility) ---

  Future<bool> saveCourses(List<CourseModel> courses) async {
    if (_preferences == null) await init();
    final jsonList = courses.map((c) => c.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    await _preferences?.setBool(keyIsInitialized, true);
    return await _preferences?.setString(keyCourses, encoded) ?? false;
  }

  List<CourseModel> loadCourses() {
    final raw = _preferences?.getString(keyCourses);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => CourseModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  bool isUniversityInitialized() {
    return _preferences?.getBool(keyIsInitialized) ?? false;
  }

  Future<bool> saveActiveMode(String mode) async {
    if (_preferences == null) await init();
    return await _preferences?.setString(keyActiveMode, mode) ?? false;
  }

  String getActiveMode() {
    return _preferences?.getString(keyActiveMode) ?? 'normal';
  }

  Future<bool> clearUniversityData() async {
    if (_preferences == null) await init();
    await _preferences?.remove(keyPlans);
    await _preferences?.remove(keyActivePlanId);
    await _preferences?.remove(keyCourses);
    await _preferences?.remove(keyIsInitialized);
    return true;
  }
}
