import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task.dart';
import '../task_repository.dart';
import 'task_state.dart';

class TaskManagerCubit extends Cubit<TaskManagerState> {
  final TaskRepository _repository;

  late final StreamSubscription<List<Task>> _subscription;

  TaskManagerCubit(TaskRepository repository)
    : _repository = repository,
      super(const TaskManagerState()) {
    _subscription = _repository.watchTasks().listen(
      (tasks) {
        emit(TaskManagerState(tasks: tasks));
      },
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
      },
    );
  }

  Future<void> addTask(String description) {
    return _repository.addTask(description);
    /*final title = description.trim();

    if (title.isEmpty) {
      return;
    }

    final nextId = state.tasks.isEmpty ? 1 : state.tasks.last.id + 1;
    final task = Task(id: nextId, title: title);

    emit(TaskManagerState(tasks: [...state.tasks, task]));*/
  }

  Future<void> toggleTask(String id) {
    return _repository.toggleTask(id);
    /*final updatedTasks = state.tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(completed: !task.completed);
      }
      return task;
    }).toList();

    emit(TaskManagerState(tasks: updatedTasks));*/
  }

  Future<void> removeTask(String id) {
    return _repository.removeTask(id);
    /*final updatedTasks = state.tasks.where((task) => task.id != id).toList();

    emit(TaskManagerState(tasks: updatedTasks));*/
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
