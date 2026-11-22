import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/dates.dart';

/// Page de détail d'une tâche (utilisée sur téléphone, ouverte par-dessus la
/// liste).
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.courseTitle,
    required this.onChanged,
  });

  final Task task;
  final String courseTitle;

  /// Prévient l'écran principal quand la tâche a été modifiée.
  final ValueChanged<Task> onChanged;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task = widget.task;

  void _toggleDone() {
    setState(() => _task = _task.copyWith(done: !_task.done));
    widget.onChanged(_task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail')),
      body: TaskDetailView(
        task: _task,
        courseTitle: widget.courseTitle,
        onToggleDone: _toggleDone,
      ),
    );
  }
}

/// Le contenu du détail, sans Scaffold, pour pouvoir aussi l'afficher à côté
/// de la liste sur tablette.
class TaskDetailView extends StatelessWidget {
  const TaskDetailView({
    super.key,
    required this.task,
    required this.courseTitle,
    required this.onToggleDone,
  });

  final Task task;
  final String courseTitle;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(icon: Icons.school_outlined, text: courseTitle),
                  _InfoRow(
                    icon: Icons.event_outlined,
                    text:
                        '${formatDate(task.dueDate)} · '
                        '${relativeDueDate(task.dueDate)}',
                  ),
                  _InfoRow(
                    icon: task.done
                        ? Icons.check_circle
                        : Icons.hourglass_empty,
                    text: task.done ? 'Terminée' : 'À faire',
                  ),
                  const Divider(height: AppSpacing.xl),
                  Text(task.description, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (task.done)
            FilledButton.tonalIcon(
              onPressed: onToggleDone,
              icon: const Icon(Icons.undo),
              label: const Text('Remettre à faire'),
            )
          else
            FilledButton.icon(
              onPressed: onToggleDone,
              icon: const Icon(Icons.check),
              label: const Text('Marquer comme fait'),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.infoIcon),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
