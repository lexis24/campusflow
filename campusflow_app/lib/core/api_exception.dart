import 'package:dio/dio.dart';

/// Erreur d'accès aux données, avec un message prêt à afficher.
///
/// Les écrans ne voient jamais de DioException : le repository traduit
/// les erreurs réseau en ApiException (séance 7, couches).
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Message en français, affichable tel quel à l'utilisateur.
  final String message;

  /// Code HTTP renvoyé par le serveur, s'il y en a un (404, 401...).
  final int? statusCode;

  /// Traduit une erreur Dio en message compréhensible.
  factory ApiException.fromDio(DioException e) {
    final code = e.response?.statusCode;
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const ApiException(
        'Le serveur met trop de temps à répondre.',
      ),
      DioExceptionType.connectionError => const ApiException(
        'Serveur injoignable. Vérifie que json-server est lancé.',
      ),
      DioExceptionType.badResponse => ApiException(
        'Erreur du serveur (code $code).',
        statusCode: code,
      ),
      _ => ApiException('Erreur réseau : ${e.message}', statusCode: code),
    };
  }

  @override
  String toString() => message;
}
