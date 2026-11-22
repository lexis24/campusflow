import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/dates.dart';
import 'taches_provider.dart';

/// Les trois filtres de l'écran Échéances (séance 6).
/// Ils ne se chevauchent pas : chaque tâche est dans un seul filtre.
enum FiltreTaches {
  aFaire('À faire'),
  enRetard('En retard'),
  faites('Faites');

  const FiltreTaches(this.libelle);

  /// Texte affiché sur la puce.
  final String libelle;

  /// La tâche [tache] fait-elle partie de ce filtre ?
  bool accepte(Task tache, {DateTime? now}) {
    final enRetardPasse = daysLeft(tache.dueDate, now: now) < 0;
    return switch (this) {
      FiltreTaches.faites => tache.done,
      FiltreTaches.enRetard => !tache.done && enRetardPasse,
      FiltreTaches.aFaire => !tache.done && !enRetardPasse,
    };
  }
}

/// Filtre actif (état d'application, cours diapo 8). null = aucun filtre :
/// toutes les tâches, groupées par période (variante B).
class FiltreNotifier extends Notifier<FiltreTaches?> {
  @override
  FiltreTaches? build() => null;

  /// Choisit [filtre] ; le choisir une seconde fois le désactive.
  void choisir(FiltreTaches filtre) => state = state == filtre ? null : filtre;
}

final filtreProvider = NotifierProvider<FiltreNotifier, FiltreTaches?>(
  FiltreNotifier.new,
);

/// Fournisseur DÉRIVÉ : la liste affichée, calculée à partir de la liste
/// partagée et du filtre actif. Il ne stocke rien : il se recalcule seul
/// quand l'un des deux change (ref.watch).
final tachesFiltreesProvider = Provider<List<Task>>((ref) {
  final taches = ref.watch(tachesProvider);
  final filtre = ref.watch(filtreProvider);
  if (filtre == null) return taches;
  return taches.where(filtre.accepte).toList();
});

/// Fournisseur DÉRIVÉ : le nombre de tâches de chaque filtre, pour les
/// compteurs affichés sur les puces (« À faire · 4 »).
final compteursFiltresProvider = Provider<Map<FiltreTaches, int>>((ref) {
  final taches = ref.watch(tachesProvider);
  return {
    for (final filtre in FiltreTaches.values)
      filtre: taches.where(filtre.accepte).length,
  };
});
