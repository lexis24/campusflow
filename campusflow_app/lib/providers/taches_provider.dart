import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/donnees_demo.dart';
import 'auth_provider.dart';
import 'repository_provider.dart';

/// État partagé de la liste des tâches, chargé depuis l'API (séance 7).
///
/// AsyncNotifier : l'état est une AsyncValue (chargement, erreur, données).
/// Il ne connaît que le contrat TaskRepository, jamais Dio.
///
/// Règle n° 1 (séance 6) : l'état reste IMMUABLE. Après chaque réponse du
/// serveur, on assigne une NOUVELLE liste, jamais de modification en place.
class TachesNotifier extends AsyncNotifier<List<Task>> {
  /// Chargement initial : GET /taches. Tant qu'il n'a pas répondu, l'état
  /// vaut AsyncLoading ; s'il échoue, AsyncError (bouton « Réessayer »).
  @override
  Future<List<Task>> build() async {
    // ref.watch de la session : la liste se recharge à chaque connexion et
    // se vide à la déconnexion. Sans session, aucune requête (elle serait
    // refusée par un 401).
    final session = await ref.watch(authProvider.future);
    if (session == null) return const [];
    final taches = await ref.watch(taskRepositoryProvider).lister();
    return _trier(taches);
  }

  /// Liste actuelle (vide si elle n'est pas encore chargée).
  List<Task> get _actuelles => state.value ?? const [];

  /// Création : POST /taches, puis ajout de la tâche renvoyée par le serveur.
  /// En cas d'échec, l'ApiException remonte à l'écran et la liste ne change
  /// pas : l'écran n'affiche que ce qui est vraiment enregistré.
  Future<void> ajouter(Task tache) async {
    final creee = await ref.read(taskRepositoryProvider).creer(tache);
    if (!ref.mounted) return;
    state = AsyncData(_trier([..._actuelles, creee]));
  }

  /// Cocher / décocher : PATCH /taches/:id avec {"done": ...}, puis
  /// remplacement de la seule tâche concernée par la version du serveur.
  Future<void> basculer(String id) async {
    final tache = _actuelles.firstWhere((t) => t.id == id);
    final aJour = await ref
        .read(taskRepositoryProvider)
        .modifierEtat(id, done: !tache.done);
    if (!ref.mounted) return;
    state = AsyncData([for (final t in _actuelles) t.id == id ? aJour : t]);
  }

  /// Suppression : DELETE /taches/:id, puis nouvelle liste sans la tâche.
  Future<void> supprimer(String id) async {
    await ref.read(taskRepositoryProvider).supprimer(id);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final t in _actuelles)
        if (t.id != id) t,
    ]);
  }

  /// Renvoie une copie triée (la plus proche échéance d'abord), sans
  /// toucher à la liste reçue.
  static List<Task> _trier(List<Task> taches) =>
      [...taches]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
}

/// Expose l'état (`AsyncValue<List<Task>>`) et le Notifier.
///
/// retry → null : on désactive la relance automatique de Riverpod 3 en cas
/// d'échec. C'est l'utilisateur qui relance avec « Réessayer » (sujet), et
/// on évite des requêtes cachées sur un forfait de données limité.
final tachesProvider = AsyncNotifierProvider<TachesNotifier, List<Task>>(
  TachesNotifier.new,
  retry: (_, _) => null,
);

/// Fournisseur paramétré (family) : la tâche [id], dans une AsyncValue pour
/// que l'écran Détail gère lui aussi le chargement et l'erreur.
/// La donnée vaut null si la tâche n'existe pas. Route /taches/:id.
final tacheParIdProvider = Provider.family<AsyncValue<Task?>, String>(
  (ref, id) => ref
      .watch(tachesProvider)
      .whenData((taches) => taches.where((t) => t.id == id).firstOrNull),
);

/// Liste des cours. Le sujet ne demande qu'un repository des tâches : les
/// cours restent des données locales, avec les mêmes id que db.json.
final coursProvider = Provider<List<Course>>((ref) => demoCours);

/// Utilisateur connecté, renvoyé par /login (null si déconnecté).
final utilisateurProvider = Provider<User?>(
  (ref) => ref.watch(authProvider).value?.utilisateur,
);

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
