import 'package:flutter_bloc/flutter_bloc.dart';

import 'task_state.dart';

class TaskManagerCubit extends Cubit<TaskManagerState> {
  TaskManagerCubit() : super(TaskManagerState());

  void addTask(String description) {
    final task = description.trim();

    if (task.isEmpty) {
      return;
    }

    emit(TaskManagerState(tasks: [...state.tasks, task]));
  }

  void removeTask(int index) {
    final updateTask = [...state.tasks];
    updateTask.removeAt(index);

    emit(TaskManagerState(tasks: updateTask));
  }
}
