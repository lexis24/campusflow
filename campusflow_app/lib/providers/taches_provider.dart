import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/donnees_demo.dart';

/// État partagé de la liste des tâches (séance 6).
///
/// Règle n° 1 du cours : l'état est IMMUABLE. On ne modifie jamais la liste
/// en place (pas de state.add) : on assigne une NOUVELLE liste à state, ce
/// qui prévient Riverpod et reconstruit les écrans qui l'écoutent.
class TachesNotifier extends Notifier<List<Task>> {
  /// État initial : les tâches de démonstration, triées par échéance.
  @override
  List<Task> build() => _trier(demoTaches(DateTime.now()));

  /// Ajoute une tâche : nouvelle liste = ancienne liste + la tâche.
  void ajouter(Task tache) => state = _trier([...state, tache]);

  /// Coche ou décoche la tâche [id] : nouvelle liste où seule cette tâche
  /// est remplacée par une copie modifiée (copyWith, séance 3).
  void basculer(String id) {
    state = [
      for (final tache in state)
        tache.id == id ? tache.copyWith(done: !tache.done) : tache,
    ];
  }

  /// Renvoie une copie triée (la plus proche échéance d'abord), sans
  /// toucher à la liste reçue.
  static List<Task> _trier(List<Task> taches) =>
      [...taches]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
}

/// Expose l'état (`List<Task>`) et le Notifier au reste de l'application.
final tachesProvider = NotifierProvider<TachesNotifier, List<Task>>(
  TachesNotifier.new,
);

/// Fournisseur paramétré (family) : la tâche dont l'identifiant est [id],
/// ou null si elle n'existe pas. Utilisé par la route /taches/:id.
final tacheParIdProvider = Provider.family<Task?, String>(
  (ref, id) => ref.watch(tachesProvider).where((t) => t.id == id).firstOrNull,
);

/// Liste des cours (données de démonstration en séance 6).
final coursProvider = Provider<List<Course>>((ref) => demoCours);

/// Utilisateur connecté (données de démonstration en séance 6).
final utilisateurProvider = Provider<User>((ref) => demoUtilisateur);

/// Titre du cours [courseId], pour l'affichage d'une tâche.
final titreCoursProvider = Provider.family<String, String>(
  (ref, courseId) =>
      ref
          .watch(coursProvider)
          .where((c) => c.id == courseId)
          .firstOrNull
          ?.title ??
      'Cours inconnu',
);
