import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';

import '../core/api_exception.dart';
import '../core/session_storage.dart';

/// Contrat de connexion (séance 7). Lève une ApiException en cas d'échec.
abstract interface class AuthRepository {
  /// POST /login : renvoie la session (jeton + utilisateur).
  Future<Session> connecter(String email, String motDePasse);
}

/// Implémentation qui appelle le /login simulé de json-server (auth.js).
class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<Session> connecter(String email, String motDePasse) async {
    try {
      final reponse = await _dio.post<Map<String, dynamic>>(
        '/login',
        data: {'email': email, 'motDePasse': motDePasse},
      );
      final data = reponse.data!;
      return Session(
        jeton: data['jeton'] as String,
        utilisateur: User.fromJson(data['utilisateur'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // Sur /login, un 401 veut dire « mauvais identifiants ».
      if (e.response?.statusCode == 401) {
        throw const ApiException(
          'E-mail ou mot de passe incorrect.',
          statusCode: 401,
        );
      }
      throw ApiException.fromDio(e);
    }
  }
}

/// Implémentation EN MÉMOIRE pour les tests : un seul compte valide.
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository({
    this.email = 'sanata.ouedraogo@exemple.bf',
    this.motDePasse = 'campus2026',
  });

  final String email;
  final String motDePasse;

  @override
  Future<Session> connecter(String email, String motDePasse) async {
    if (email != this.email || motDePasse != this.motDePasse) {
      throw const ApiException(
        'E-mail ou mot de passe incorrect.',
        statusCode: 401,
      );
    }
    return Session(
      jeton: 'jeton-de-test',
      utilisateur: User(id: 'u1', name: 'Sanata Ouédraogo', email: email),
    );
  }
}
