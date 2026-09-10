import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'state/task_cubit.dart';
import 'state/task_state.dart';
import 'widgets/task_counters.dart';
import 'widgets/task_tile.dart';

class BodyApp extends StatefulWidget {
  const BodyApp({super.key});

  @override
  State<BodyApp> createState() => _BodyAppState();
}

class _BodyAppState extends State<BodyApp> {
  final taskController = TextEditingController();

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  void addTask() {
    context.read<TaskManagerCubit>().addTask(taskController.text);
    taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskFlow'), centerTitle: true),
      body: BlocBuilder<TaskManagerCubit, TaskManagerState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => addTask(),
                        decoration: const InputDecoration(
                          labelText: 'Nueva tarea',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: addTask,
                      tooltip: 'Agregar tarea',
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TaskCounters(state: state),
                const SizedBox(height: 16),
                Expanded(
                  child: state.tasks.isEmpty
                      ? const Center(child: Text('No hay tareas registradas'))
                      : ListView.separated(
                          itemCount: state.tasks.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final task = state.tasks[index];
                            return TaskTile(
                              key: ValueKey(task.id),
                              task: task,
                              onToggle: () => context
                                  .read<TaskManagerCubit>()
                                  .toggleTask(task.id),
                              onDelete: () => context
                                  .read<TaskManagerCubit>()
                                  .removeTask(task.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
