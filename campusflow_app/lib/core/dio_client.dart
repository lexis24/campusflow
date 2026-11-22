import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';

/// Client HTTP Dio partagé par toute l'application (couche « core »).
///
/// Seuls les repositories l'utilisent : les écrans ne connaissent pas Dio.
/// L'intercepteur d'authentification sera ajouté ici (séance 7, connexion).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      // Délais courts : sur une connexion faible, mieux vaut afficher
      // vite une erreur avec « Réessayer » qu'attendre indéfiniment.
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: Headers.jsonContentType,
    ),
  );
  // Ferme le client quand le fournisseur est détruit.
  ref.onDispose(dio.close);
  return dio;
});
