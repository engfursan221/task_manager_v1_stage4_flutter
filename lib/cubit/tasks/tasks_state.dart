import '../../models/task_model.dart';

// ============================================================
// REQUIREMENT: TASKS CUBIT STATES
// Manages the state lifecycle for task CRUD operations:
// - TasksInitial: Initial uninitialized state
// - TasksLoading: State during async or transition operations
// - TasksLoaded: Holds activeTasks list and archivedTasks list
// - TasksError: State with error message if operation fails
// ============================================================

abstract class TasksState {
  const TasksState();
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  final List<TaskModel> activeTasks;
  final List<TaskModel> archivedTasks;

  const TasksLoaded({
    this.activeTasks = const [],
    this.archivedTasks = const [],
  });

  TasksLoaded copyWith({
    List<TaskModel>? activeTasks,
    List<TaskModel>? archivedTasks,
  }) {
    return TasksLoaded(
      activeTasks: activeTasks ?? this.activeTasks,
      archivedTasks: archivedTasks ?? this.archivedTasks,
    );
  }
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);
}
