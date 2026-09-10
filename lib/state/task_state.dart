import '../models/task.dart';

class TaskManagerState {
  final List<Task> tasks;

  const TaskManagerState({
    this.tasks = const [],
  });

  int get totalTasks => tasks.length;

  int get completedTasks => tasks.where((task) => task.completed).length;

  int get pendingTasks => totalTasks - completedTasks;
}
