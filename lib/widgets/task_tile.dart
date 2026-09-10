import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toggleLabel = task.completed
        ? 'Marcar como pendiente: ${task.title}'
        : 'Completar tarea: ${task.title}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: task.completed,
        semanticLabel: toggleLabel,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.completed
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: task.completed ? colors.onSurfaceVariant : colors.onSurface,
        ),
      ),
      subtitle: Text(task.completed ? 'Completada' : 'Pendiente'),
      trailing: IconButton(
        onPressed: onDelete,
        tooltip: 'Eliminar tarea: ${task.title}',
        color: colors.error,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}
