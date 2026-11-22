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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final late = !task.done && daysLeft(task.dueDate) < 0;

    // Structure reprise du wireframe 03-detail (séance 2) :
    // badge de date, titre, carte d'informations, description, bouton.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge de date relative, en couleur d'erreur si en retard.
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: Icon(
                Icons.schedule,
                color: late ? colors.onErrorContainer : null,
              ),
              label: Text(task.done ? 'Rendue' : relativeDueDate(task.dueDate)),
              backgroundColor: late ? colors.errorContainer : null,
              labelStyle: late
                  ? TextStyle(color: colors.onErrorContainer)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(task.title, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.m),
          // La Card regroupe les informations, chacune avec son libellé.
          Card(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Cours',
                  value: courseTitle,
                ),
                const Divider(height: AppSizes.hairline),
                _InfoRow(
                  icon: Icons.event_outlined,
                  label: "Date d'échéance",
                  value: formatDate(task.dueDate),
                ),
                const Divider(height: AppSizes.hairline),
                _InfoRow(
                  icon: task.done ? Icons.check_circle : Icons.hourglass_empty,
                  label: 'Statut',
                  value: task.done ? 'Terminée' : 'À faire',
                ),
              ],
            ),
          ),
          // La description est facultative : pas de bloc vide.
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text(
              'Description',
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Text(task.description, style: textTheme.bodyLarge),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
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

/// Une ligne d'information de la carte : icône, libellé et valeur.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.infoIcon, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.m),
          // Expanded : la valeur prend la place restante et passe à la
          // ligne si elle est longue, au lieu de faire déborder la Row.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(value, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
