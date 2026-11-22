import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/session_storage.dart';
import 'repository_provider.dart';

/// Session de l'utilisateur (séance 7). null = déconnecté.
///
/// AsyncNotifier : au démarrage, la session est relue dans le stockage
/// sécurisé (opération asynchrone), pour rester connecté entre deux
/// lancements de l'application.
class AuthNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.read(sessionStorageProvider).lire();

  /// POST /login, puis jeton rangé dans le stockage sécurisé.
  /// En cas d'échec, l'ApiException remonte à l'écran de connexion.
  Future<void> connecter(String email, String motDePasse) async {
    final session = await ref
        .read(authRepositoryProvider)
        .connecter(email, motDePasse);
    await ref.read(sessionStorageProvider).ecrire(session);
    ref.read(sessionExpireeProvider.notifier).definir(false);
    if (!ref.mounted) return;
    state = AsyncData(session);
  }

  /// Déconnexion : le jeton est effacé du stockage. Le routeur, qui écoute
  /// cet état, renvoie alors vers /login.
  Future<void> deconnecter() async {
    await ref.read(sessionStorageProvider).effacer();
    if (!ref.mounted) return;
    state = const AsyncData(null);
  }

  /// Appelée par l'intercepteur Dio quand le serveur répond 401 : le jeton
  /// n'est plus valide, on ferme la session et on prévient l'utilisateur.
  Future<void> sessionExpiree() async {
    ref.read(sessionExpireeProvider.notifier).definir(true);
    await deconnecter();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Session?>(
  AuthNotifier.new,
);

/// Vrai si la dernière déconnexion vient d'un 401 (jeton refusé) : l'écran
/// de connexion affiche alors « Ta session a expiré ».
class SessionExpireeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void definir(bool valeur) => state = valeur;
}

final sessionExpireeProvider = NotifierProvider<SessionExpireeNotifier, bool>(
  SessionExpireeNotifier.new,
);
