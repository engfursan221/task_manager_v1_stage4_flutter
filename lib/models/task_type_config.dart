// ============================================================
// TASK TYPE CONFIG MODEL (V2)
// Configurable and custom academic task types per course.
// ============================================================

class TaskTypeConfig {
  final String key;
  final String name;
  final bool enabled;
  final bool isCustom;

  const TaskTypeConfig({
    required this.key,
    required this.name,
    this.enabled = true,
    this.isCustom = false,
  });

  TaskTypeConfig copyWith({
    String? key,
    String? name,
    bool? enabled,
    bool? isCustom,
  }) {
    return TaskTypeConfig(
      key: key ?? this.key,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'enabled': enabled,
      'isCustom': isCustom,
    };
  }

  factory TaskTypeConfig.fromJson(Map<String, dynamic> json) {
    return TaskTypeConfig(
      key: json['key'] as String? ?? 'custom',
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
