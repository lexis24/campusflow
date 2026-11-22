import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/filtres_provider.dart';
import '../providers/taches_provider.dart';
import '../theme/app_theme.dart';
import '../utils/actions.dart';
import '../utils/dates.dart';
import '../utils/periodes.dart';
import 'erreur_reessayer.dart';
import 'task_detail_screen.dart';

/// Écran Échéances, adresse /taches (destination 1 de la NavigationBar).
///
/// La liste des tâches vient de tachesProvider (état partagé) ; seule la
/// tâche sélectionnée sur tablette reste un état local (éphémère).
class EcheancesScreen extends ConsumerStatefulWidget {
  const EcheancesScreen({super.key});

  @override
  ConsumerState<EcheancesScreen> createState() => _EcheancesScreenState();
}

class _EcheancesScreenState extends ConsumerState<EcheancesScreen> {
  /// Tâche affichée à droite de la liste en mode tablette (état éphémère :
  /// il n'intéresse que cet écran, setState suffit).
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    // ref.watch dans build : l'écran se reconstruit à chaque changement.
    // On affiche la liste DÉRIVÉE (filtrée), pas la liste brute.
    final etat = ref.watch(tachesFiltreesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes échéances')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFiltres(),
          // Expanded : la liste prend la hauteur restante. Sans lui, un
          // ListView dans une Column a une hauteur non bornée (séance 5).
          Expanded(
            // Les trois états de l'AsyncValue (séance 7) : when oblige à
            // traiter chacun, on ne peut pas oublier l'erreur.
            child: etat.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erreur, _) => ErreurReessayer(
                message: '$erreur',
                // Réessayer : on jette l'état et build() relance GET /taches.
                onReessayer: () => ref.invalidate(tachesProvider),
              ),
              data: _buildTaskList,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // push : le formulaire s'empile, le retour (×) ramène ici.
        onPressed: () => context.push('/taches/nouvelle'),
        tooltip: 'Nouvelle tâche',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Les trois filtres (à faire, en retard, faites) avec leur compteur.
  /// Wrap : les puces passent à la ligne si la place manque.
  Widget _buildFiltres() {
    final filtreActif = ref.watch(filtreProvider);
    final compteurs = ref.watch(compteursFiltresProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [
          for (final filtre in FiltreTaches.values)
            FilterChip(
              label: Text('${filtre.libelle} · ${compteurs[filtre]}'),
              selected: filtreActif == filtre,
              // ref.read dans une action : on change le filtre actif.
              onSelected: (_) =>
                  ref.read(filtreProvider.notifier).choisir(filtre),
            ),
        ],
      ),
    );
  }

  /// Sur téléphone : juste la liste. À partir de 840 dp (tablette, grand
  /// écran) : la liste à gauche et le détail de la tâche choisie à droite.
  Widget _buildTaskList(List<Task> taches) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppSizes.tabletBreakpoint;
        if (!wide) return _buildTaskListView(taches, wide: false);

        // On cherche la tâche sélectionnée dans la liste complète : elle
        // reste affichée à droite même si le filtre la masque à gauche.
        final selected = (ref.watch(tachesProvider).value ?? const <Task>[])
            .where((t) => t.id == _selectedTaskId)
            .firstOrNull;
        return Row(
          children: [
            SizedBox(
              width: AppSizes.masterPaneWidth,
              child: _buildTaskListView(taches, wide: true),
            ),
            const VerticalDivider(width: AppSizes.hairline),
            Expanded(
              child: selected == null
                  ? const Center(child: Text('Choisis une échéance à gauche.'))
                  : TaskDetailView(
                      task: selected,
                      courseTitle: ref.watch(
                        titreCoursProvider(selected.courseId),
                      ),
                      // ref.read dans une action : on appelle le Notifier
                      // sans écouter. PATCH, avec SnackBar en cas d'échec.
                      onToggleDone: () => executerAction(
                        context,
                        () => ref
                            .read(tachesProvider.notifier)
                            .basculer(selected.id),
                      ),
                      onDelete: () => _supprimer(selected),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Suppression depuis le panneau de détail (tablette) : confirmation,
  /// DELETE /taches/:id, puis le panneau revient à « Choisis une échéance ».
  Future<void> _supprimer(Task tache) async {
    if (!await confirmerSuppression(context, tache.title)) return;
    if (!mounted) return;
    final ok = await executerAction(
      context,
      () => ref.read(tachesProvider.notifier).supprimer(tache.id),
      succes: '« ${tache.title} » supprimée',
    );
    if (ok && mounted) setState(() => _selectedTaskId = null);
  }

  /// Liste des échéances groupée par période (variante B, séance 2).
  Widget _buildTaskListView(List<Task> taches, {required bool wide}) {
    if (taches.isEmpty) {
      final filtrage = ref.watch(filtreProvider) != null;
      return Center(
        child: Text(
          filtrage
              ? 'Aucune tâche dans ce filtre.'
              : 'Rien à rendre pour le moment.',
        ),
      );
    }

    // Liste « plate » : chaque section donne une ligne d'en-tête suivie de
    // ses tâches. Un seul ListView.builder construit ensuite toutes les
    // lignes, et seulement celles visibles à l'écran.
    final lignes = <_Ligne>[
      for (final MapEntry(key: periode, value: groupe) in grouperParPeriode(
        taches,
      ).entries) ...[
        _EnTete(periode, groupe.length),
        for (final tache in groupe) _LigneTache(tache),
      ],
    ];

    return ListView.builder(
      itemCount: lignes.length,
      // Le switch sur une sealed class oblige à traiter les deux cas.
      itemBuilder: (context, index) => switch (lignes[index]) {
        _EnTete(:final periode, :final nombre) => _buildEnTete(periode, nombre),
        _LigneTache(:final task) => _buildTaskTile(task, wide: wide),
      },
    );
  }

  /// En-tête de section, lui aussi un ListTile (« chaque ligne est un
  /// ListTile »). « En retard » prend les couleurs d'erreur du thème,
  /// les autres le fond surfaceContainerHighest (design system § 4.2).
  Widget _buildEnTete(Periode periode, int nombre) {
    final colors = Theme.of(context).colorScheme;
    final enRetard = periode == Periode.enRetard;
    final fond = enRetard ? colors.error : colors.surfaceContainerHighest;
    final texte = enRetard ? colors.onError : colors.onSurface;
    final style = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: texte);

    // header: true : le lecteur d'écran annonce un titre de section.
    return Semantics(
      header: true,
      child: ListTile(
        dense: true,
        tileColor: fond,
        iconColor: texte,
        leading: enRetard ? const Icon(Icons.error_outline) : null,
        title: Text(periode.libelle, style: style),
        trailing: Text('$nombre', style: style),
      ),
    );
  }

  /// Ligne de tâche (design system § 4.2) : titre, cours en sous-titre,
  /// date courte à droite, en couleur d'erreur si la tâche est en retard.
  Widget _buildTaskTile(Task task, {required bool wide}) {
    final colors = Theme.of(context).colorScheme;
    final late = !task.done && daysLeft(task.dueDate) < 0;

    return ListTile(
      leading: Icon(
        task.done ? Icons.check_circle : Icons.radio_button_unchecked,
        // Couleur du thème (contraste 6,12:1) au lieu de Colors.green
        // en dur (2,64:1, insuffisant) : voir le design system § 1.
        color: task.done ? colors.primary : null,
      ),
      title: Text(
        task.title,
        style: task.done
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(ref.watch(titreCoursProvider(task.courseId))),
      trailing: Row(
        // min : la Row prend juste la place de la date et du chevron,
        // sinon elle voudrait toute la largeur du trailing.
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shortDueDate(task.dueDate),
            style: late ? TextStyle(color: colors.error) : null,
          ),
          // Sur tablette, pas de chevron : le détail s'affiche à côté.
          if (!wide) const Icon(Icons.chevron_right),
        ],
      ),
      // Sur tablette, la ligne choisie est surlignée et on reste sur
      // l'écran ; sur téléphone, on ouvre l'adresse du détail.
      selected: wide && task.id == _selectedTaskId,
      onTap: wide
          ? () => setState(() => _selectedTaskId = task.id)
          : () => context.push('/taches/${task.id}'),
    );
  }
}

/// Une ligne de la liste des échéances : soit un en-tête de section,
/// soit une tâche. « sealed » : il n'existe que ces deux sortes de lignes.
sealed class _Ligne {
  const _Ligne();
}

/// En-tête de section : la période et le nombre de tâches qu'elle contient.
class _EnTete extends _Ligne {
  const _EnTete(this.periode, this.nombre);

  final Periode periode;
  final int nombre;
}

/// Ligne de tâche.
class _LigneTache extends _Ligne {
  const _LigneTache(this.task);

  final Task task;
}
