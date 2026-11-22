import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/taches_provider.dart';
import '../theme/app_theme.dart';
import '../utils/actions.dart';
import '../utils/dates.dart';
import 'erreur_reessayer.dart';

/// Écran Détail, adresse /taches/:id (écran secondaire, sur téléphone).
///
/// Il ne reçoit que l'identifiant lu dans l'adresse, et retrouve la tâche
/// dans l'état partagé : plus de paramètres ni de callbacks à transmettre.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  /// Valeur du paramètre :id de l'adresse.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch : si la tâche change (cochée), l'écran se reconstruit.
    final etat = ref.watch(tacheParIdProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail')),
      // Les trois états de l'AsyncValue (séance 7).
      body: etat.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => ErreurReessayer(
          message: '$erreur',
          onReessayer: () => ref.invalidate(tachesProvider),
        ),
        data: (task) => task == null
            // Adresse saisie à la main avec un id qui n'existe pas.
            ? Center(child: Text('Tâche introuvable ($id).'))
            : TaskDetailView(
                task: task,
                courseTitle: ref.watch(titreCoursProvider(task.courseId)),
                // ref.read dans les actions (règle n° 2 du cours).
                onToggleDone: () => executerAction(
                  context,
                  () => ref.read(tachesProvider.notifier).basculer(task.id),
                ),
                onDelete: () => _supprimer(context, ref, task),
              ),
      ),
    );
  }

  /// Confirmation, DELETE /taches/:id, puis retour à la liste.
  Future<void> _supprimer(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    if (!await confirmerSuppression(context, task.title)) return;
    if (!context.mounted) return;
    final ok = await executerAction(
      context,
      () => ref.read(tachesProvider.notifier).supprimer(task.id),
      succes: '« ${task.title} » supprimée',
    );
    if (ok && context.mounted) context.pop();
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
    this.onDelete,
  });

  final Task task;
  final String courseTitle;
  final VoidCallback onToggleDone;

  /// Suppression (DELETE) ; pas de bouton si null.
  final VoidCallback? onDelete;

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
          // Action destructrice : bouton texte en couleur d'erreur, discret,
          // jamais à la place de l'action principale.
          if (onDelete != null) ...[
            const SizedBox(height: AppSpacing.s),
            TextButton.icon(
              onPressed: onDelete,
              style: TextButton.styleFrom(foregroundColor: colors.error),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer la tâche'),
            ),
          ],
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
