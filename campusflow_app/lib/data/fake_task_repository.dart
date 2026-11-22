import 'package:campusflow_models/campusflow_models.dart';

import '../core/api_exception.dart';
import 'donnees_demo.dart';
import 'task_repository.dart';

/// Implémentation du contrat EN MÉMOIRE, pour les tests (séance 7).
///
/// Aucun réseau : réponses immédiates et reproductibles. [enPanne] permet de
/// simuler un serveur injoignable pour tester l'état « erreur ».
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    List<Task>? taches,
    this.delai = Duration.zero,
    this.enPanne = false,
  }) : _taches = taches ?? demoTaches(DateTime.now());

  /// Attente simulée avant chaque réponse (Future.delayed, comme en séance 3).
  final Duration delai;

  /// Si vrai, chaque appel échoue comme un serveur injoignable.
  bool enPanne;

  /// « Base de données » en mémoire. Remplacée (jamais modifiée en place).
  List<Task> _taches;

  /// Nombre d'appels reçus : permet aux tests de vérifier un rechargement.
  int appels = 0;

  @override
  Future<List<Task>> lister() async {
    await _attendre();
    return List.unmodifiable(_taches);
  }

  @override
  Future<Task> creer(Task tache) async {
    await _attendre();
    _taches = [..._taches, tache];
    return tache;
  }

  @override
  Future<Task> modifierEtat(String id, {required bool done}) async {
    await _attendre();
    final tache = _trouver(id).copyWith(done: done);
    _taches = [
      for (final t in _taches)
        if (t.id == id) tache else t,
    ];
    return tache;
  }

  @override
  Future<void> supprimer(String id) async {
    await _attendre();
    _trouver(id);
    _taches = [
      for (final t in _taches)
        if (t.id != id) t,
    ];
  }

  Task _trouver(String id) {
    final tache = _taches.where((t) => t.id == id).firstOrNull;
    if (tache == null) {
      throw const ApiException(
        'Erreur du serveur (code 404).',
        statusCode: 404,
      );
    }
    return tache;
  }

  Future<void> _attendre() async {
    appels++;
    await Future<void>.delayed(delai);
    if (enPanne) {
      throw const ApiException(
        'Serveur injoignable. Vérifie que json-server est lancé.',
      );
    }
  }
}
