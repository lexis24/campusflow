import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Intercepteur Dio d'authentification (séance 7).
///
/// - onRequest : ajoute `Authorization: Bearer <jeton>` à CHAQUE requête,
///   sans que les repositories ni les écrans aient à s'en occuper.
/// - onError   : sur une réponse 401 (jeton absent, expiré ou refusé),
///   ferme la session ; le routeur redirige alors vers /login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Le jeton vient de la session, elle-même relue dans le stockage
    // sécurisé au démarrage.
    final jeton = _ref.read(authProvider).value?.jeton;
    if (jeton != null) {
      options.headers['Authorization'] = 'Bearer $jeton';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Sur /login, un 401 signifie « mauvais identifiants », pas « session
    // expirée » : l'écran de connexion affiche l'erreur lui-même.
    final estLogin = err.requestOptions.path == '/login';
    if (err.response?.statusCode == 401 && !estLogin) {
      await _ref.read(authProvider.notifier).sessionExpiree();
    }
    // L'erreur continue son chemin jusqu'au repository (ApiException).
    handler.next(err);
  }
}
