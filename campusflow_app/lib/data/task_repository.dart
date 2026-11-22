import 'package:campusflow_models/campusflow_models.dart';

/// Contrat d'accès aux tâches (séance 7, couches).
///
/// Il dit QUOI faire, pas COMMENT : le Notifier et les écrans dépendent de
/// ce contrat, jamais de Dio. Deux implémentations :
/// - ApiTaskRepository  : appelle l'API json-server (l'application) ;
/// - FakeTaskRepository : liste en mémoire (les tests).
///
/// En cas d'échec, chaque méthode lève une ApiException.
abstract interface class TaskRepository {
  /// Toutes les tâches (GET /taches).
  Future<List<Task>> lister();

  /// Crée [tache] et renvoie la tâche enregistrée (POST /taches).
  Future<Task> creer(Task tache);

  /// Coche ou décoche la tâche [id] et renvoie la tâche à jour
  /// (PATCH /taches/:id avec {"done": ...}).
  Future<Task> modifierEtat(String id, {required bool done});

  /// Supprime la tâche [id] (DELETE /taches/:id).
  Future<void> supprimer(String id);
}
