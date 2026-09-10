import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task.dart';
import 'task_state.dart';

class TaskManagerCubit extends Cubit<TaskManagerState> {
  TaskManagerCubit() : super(TaskManagerState());

  void addTask(String description) {
    final title = description.trim();

    if (title.isEmpty) {
      return;
    }

    final nextId = state.tasks.isEmpty ? 1 : state.tasks.last.id + 1;
    final task = Task(id: nextId, title: title);

    emit(TaskManagerState(tasks: [...state.tasks, task]));
  }

  void toggleTask(int id) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(completed: !task.completed);
      }
      return task;
    }).toList();

    emit(TaskManagerState(tasks: updatedTasks));
  }

  void removeTask(int id) {
    final updatedTasks = state.tasks
        .where((task) => task.id != id)
        .toList();

    emit(TaskManagerState(tasks: updatedTasks));
  }
}
