// ============================================================
// UNIVERSITY STORAGE SERVICE (V2)
// Handles local JSON persistence for university courses,
// lectures, attendance, notes, and tasks via SharedPreferences.
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/course_model.dart';

class UniversityStorageService {
  static UniversityStorageService? _instance;
  static SharedPreferences? _preferences;

  UniversityStorageService._();

  static UniversityStorageService get instance {
    _instance ??= UniversityStorageService._();
    return _instance!;
  }

  static const String keyCourses = 'v2_university_courses';
  static const String keyIsInitialized = 'v2_university_is_initialized';
  static const String keyActiveMode = 'v2_active_task_mode'; // 'normal' or 'university'

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

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
    await _preferences?.remove(keyCourses);
    await _preferences?.remove(keyIsInitialized);
    return true;
  }
}
