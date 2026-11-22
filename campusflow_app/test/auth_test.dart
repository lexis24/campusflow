import 'dart:convert';
import 'dart:typed_data';

import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/core/dio_client.dart';
import 'package:campusflow_app/core/session_storage.dart';
import 'package:campusflow_app/data/auth_repository.dart';
import 'package:campusflow_app/providers/auth_provider.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux réseau pour Dio : enregistre les requêtes, renvoie (corps, code).
class _FauxReseau implements HttpClientAdapter {
  _FauxReseau(this.repondre);

  final (Object?, int) Function(RequestOptions requete) repondre;
  final requetes = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requetes.add(options);
    final (corps, code) = repondre(options);
    return ResponseBody.fromString(
      jsonEncode(corps),
      code,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _session = Session(
  jeton: 'jeton-de-test',
  utilisateur: User(id: 'u1', name: 'Sanata', email: 's@exemple.bf'),
);

void main() {
  group('Intercepteur Dio', () {
    late MemorySessionStorage stockage;
    late ProviderContainer container;
    late Dio dio;

    /// Prépare une session ouverte et le vrai Dio de l'application (avec
    /// son intercepteur), branché sur un faux réseau.
    Future<_FauxReseau> preparer(int code) async {
      stockage = MemorySessionStorage(_session);
      container = ProviderContainer(
        overrides: [sessionStorageProvider.overrideWithValue(stockage)],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      final reseau = _FauxReseau((_) => (<Object>[], code));
      dio = container.read(dioProvider)..httpClientAdapter = reseau;
      return reseau;
    }

    test('ajoute « Authorization: Bearer <jeton> » à chaque requête', () async {
      final reseau = await preparer(200);

      await dio.get<Object>('/taches');
      await dio.patch<Object>('/taches/t3', data: {'done': true});

      for (final requete in reseau.requetes) {
        expect(requete.headers['Authorization'], 'Bearer jeton-de-test');
      }
    });

    test(
      'sur une réponse 401, la session est fermée et le jeton effacé',
      () async {
        await preparer(401);

        await expectLater(
          dio.get<Object>('/taches'),
          throwsA(isA<DioException>()),
        );

        expect(container.read(authProvider).value, isNull);
        expect(stockage.session, isNull);
        expect(container.read(sessionExpireeProvider), isTrue);
      },
    );

    test('un 401 sur /login (mauvais identifiants) ne ferme rien', () async {
      await preparer(401);

      await expectLater(
        dio.post<Object>('/login', data: <String, Object>{}),
        throwsA(isA<DioException>()),
      );

      expect(container.read(authProvider).value, isNotNull);
      expect(container.read(sessionExpireeProvider), isFalse);
    });
  });

  group('ApiAuthRepository', () {
    ApiAuthRepository repo((Object?, int) Function(RequestOptions) r) {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = _FauxReseau(r);
      return ApiAuthRepository(dio);
    }

    test(
      'connecter envoie POST /login et lit le jeton et l\'utilisateur',
      () async {
        late RequestOptions envoyee;
        final session = await repo((r) {
          envoyee = r;
          return (
            {
              'jeton': 'abc',
              'utilisateur': {'id': 'u1', 'name': 'Sanata', 'email': 's@e.bf'},
            },
            200,
          );
        }).connecter('s@e.bf', 'campus2026');

        expect(envoyee.method, 'POST');
        expect(envoyee.path, '/login');
        expect(envoyee.data, {'email': 's@e.bf', 'motDePasse': 'campus2026'});
        expect(session.jeton, 'abc');
        expect(session.utilisateur.name, 'Sanata');
      },
    );

    test('des identifiants refusés (401) donnent un message clair', () async {
      expect(
        repo((_) => ({'erreur': 'Identifiants incorrects'}, 401))
            .connecter('s@e.bf', 'faux'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'E-mail ou mot de passe incorrect.',
          ),
        ),
      );
    });
  });
}
