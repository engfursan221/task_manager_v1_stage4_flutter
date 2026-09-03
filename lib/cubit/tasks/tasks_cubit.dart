import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/task_model.dart';
import 'tasks_state.dart';

// ============================================================
// REQUIREMENT: TASKS CUBIT (STAGE 3 CRUD & ARCHIVE)
// Manages the state and business logic for:
// - CREATE: Adding new tasks
// - READ: Fetching and observing task lists
// - UPDATE: Modifying title, description, or completion state
// - DELETE -> ARCHIVE: Moving deleted tasks to Archive
// ============================================================

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(const TasksInitial()) {
    _loadInitialTasks();
  }

  // Pre-seed some default demo tasks for testing Stage 3
  void _loadInitialTasks() {
    final initialActive = [
      TaskModel(
        id: 'task_1',
        title: 'مراجعة إدارة الحالة باستخدام Cubit',
        description: 'فهم كيفية إطلاق الحالات في Cubit وتحديث BlocBuilder تلقائياً.',
        isCompleted: false,
      ),
      TaskModel(
        id: 'task_2',
        title: 'إعداد مشروع برمجة تطبيقات الهاتف',
        description: 'إكمال عمليات CRUD وإضافة ميزة الأرشفة ودعم اللغة العربية.',
        isCompleted: true,
      ),
    ];

    final initialArchived = [
      TaskModel(
        id: 'archived_1',
        title: 'تثبيت Flutter SDK وإعداد بيئة العمل',
        description: 'إعداد ومزامنة أدوات التطوير ومحاكي الأندرويد.',
        isCompleted: true,
      ),
    ];

    emit(TasksLoaded(
      activeTasks: initialActive,
      archivedTasks: initialArchived,
    ));
  }

  // ============================================================
  // REQUIREMENT: CRUD - READ
  // Displays the current list of tasks.
  // ============================================================
  /// Returns the current list of active tasks from state.
  List<TaskModel> get activeTasks {
    if (state is TasksLoaded) {
      return (state as TasksLoaded).activeTasks;
    }
    return [];
  }

  /// Returns the current list of archived tasks from state.
  List<TaskModel> get archivedTasks {
    if (state is TasksLoaded) {
      return (state as TasksLoaded).archivedTasks;
    }
    return [];
  }

  // ============================================================
  // REQUIREMENT: CRUD - CREATE
  // Creates and adds a new task to the task list.
  // ============================================================
  void createTask({
    required String title,
    required String description,
  }) {
    final cleanTitle = title.trim();
    final cleanDescription = description.trim();

    if (cleanTitle.isEmpty) return;

    final currentState = state;
    final currentActive = currentState is TasksLoaded
        ? List<TaskModel>.from(currentState.activeTasks)
        : <TaskModel>[];
    final currentArchived = currentState is TasksLoaded
        ? List<TaskModel>.from(currentState.archivedTasks)
        : <TaskModel>[];

    final newTask = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: cleanTitle,
      description: cleanDescription,
      isCompleted: false,
    );

    // Insert new task at the beginning of active tasks
    currentActive.insert(0, newTask);

    emit(TasksLoaded(
      activeTasks: currentActive,
      archivedTasks: currentArchived,
    ));
  }

  // ============================================================
  // REQUIREMENT: CRUD - UPDATE
  // Updates an existing task.
  // ============================================================
  void updateTask({
    required String id,
    required String title,
    required String description,
  }) {
    final currentState = state;
    if (currentState is! TasksLoaded) return;

    final updatedList = currentState.activeTasks.map((task) {
      if (task.id == id) {
        return task.copyWith(
          title: title.trim(),
          description: description.trim(),
        );
      }
      return task;
    }).toList();

    emit(currentState.copyWith(activeTasks: updatedList));
  }

  // ============================================================
  // REQUIREMENT: CRUD - UPDATE (TOGGLE COMPLETION)
  // Toggles completion status of a task using TasksCubit.
  // ============================================================
  void toggleTaskCompletion(String id) {
    final currentState = state;
    if (currentState is! TasksLoaded) return;

    final updatedList = currentState.activeTasks.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(currentState.copyWith(activeTasks: updatedList));
  }

  // ============================================================
  // REQUIREMENT: ARCHIVE
  // Deleted tasks are moved to the Archive instead of being
  // permanently removed.
  // ============================================================
  void deleteTask(String id) {
    final currentState = state;
    if (currentState is! TasksLoaded) return;

    // Find the task to delete/archive
    final taskIndex = currentState.activeTasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final taskToArchive = currentState.activeTasks[taskIndex];

    // Remove from active list
    final newActiveList = List<TaskModel>.from(currentState.activeTasks)
      ..removeAt(taskIndex);

    // Add to archive list (Task -> Delete -> Archive)
    final newArchivedList = List<TaskModel>.from(currentState.archivedTasks)
      ..insert(0, taskToArchive);

    emit(TasksLoaded(
      activeTasks: newActiveList,
      archivedTasks: newArchivedList,
    ));
  }

  /// Restores an archived task back to active tasks list
  void restoreTask(String id) {
    final currentState = state;
    if (currentState is! TasksLoaded) return;

    final taskIndex = currentState.archivedTasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final taskToRestore = currentState.archivedTasks[taskIndex];

    final newArchivedList = List<TaskModel>.from(currentState.archivedTasks)
      ..removeAt(taskIndex);

    final newActiveList = List<TaskModel>.from(currentState.activeTasks)
      ..insert(0, taskToRestore);

    emit(TasksLoaded(
      activeTasks: newActiveList,
      archivedTasks: newArchivedList,
    ));
  }
}
