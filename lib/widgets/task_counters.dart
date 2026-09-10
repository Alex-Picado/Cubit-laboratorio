import 'package:flutter/material.dart';

import '../state/task_state.dart';

class TaskCounters extends StatelessWidget {
  const TaskCounters({super.key, required this.state});

  final TaskManagerState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TaskCounter(
          label: 'Total',
          count: state.totalTasks,
          icon: Icons.list_alt,
        ),
        _TaskCounter(
          label: 'Completadas',
          count: state.completedTasks,
          icon: Icons.check_circle_outline,
        ),
        _TaskCounter(
          label: 'Pendientes',
          count: state.pendingTasks,
          icon: Icons.schedule,
        ),
      ],
    );
  }
}

class _TaskCounter extends StatelessWidget {
  const _TaskCounter({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(child: Text('$label: $count')),
          ],
        ),
      ),
    );
  }
}
