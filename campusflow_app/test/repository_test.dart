import 'dart:convert';
import 'dart:typed_data';

import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/data/api_task_repository.dart';
import 'package:campusflow_app/data/fake_task_repository.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux réseau pour Dio : enregistre les requêtes et renvoie une réponse
/// préparée. Permet de tester ApiTaskRepository sans json-server.
class _FauxReseau implements HttpClientAdapter {
  _FauxReseau(this.repondre);

  /// Fabrique la réponse (corps JSON, code HTTP) pour une requête.
  final (Object?, int) Function(RequestOptions requete) repondre;

  /// Requêtes reçues, dans l'ordre.
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

final _jsonT3 = {
  'id': 't3',
  'title': 'Rapport projet réseaux',
  'description': 'Rapport de 10 pages.',
  'dueDate': '2026-11-23T18:00:00.000',
  'done': false,
  'courseId': 'c1',
};

/// Crée un ApiTaskRepository branché sur un faux réseau.
(ApiTaskRepository, _FauxReseau) _api(
  (Object?, int) Function(RequestOptions) r,
) {
  final reseau = _FauxReseau(r);
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = reseau;
  return (ApiTaskRepository(dio), reseau);
}

void main() {
  group('ApiTaskRepository (Dio)', () {
    test(
      'lister envoie GET /taches et construit les Task avec fromJson',
      () async {
        final (repo, reseau) = _api((_) => ([_jsonT3], 200));

        final taches = await repo.lister();

        expect(reseau.requetes.single.method, 'GET');
        expect(reseau.requetes.single.path, '/taches');
        expect(taches.single.title, 'Rapport projet réseaux');
      },
    );

    test('creer envoie POST /taches avec la tâche en JSON', () async {
      final (repo, reseau) = _api((r) => (r.data, 201));
      final tache = Task.fromJson(_jsonT3);

      final creee = await repo.creer(tache);

      expect(reseau.requetes.single.method, 'POST');
      expect(reseau.requetes.single.path, '/taches');
      expect(reseau.requetes.single.data, tache.toJson());
      expect(creee, tache);
    });

    test(
      'modifierEtat envoie PATCH /taches/:id avec seulement {"done"}',
      () async {
        final (repo, reseau) = _api((_) => ({..._jsonT3, 'done': true}, 200));

        final aJour = await repo.modifierEtat('t3', done: true);

        expect(reseau.requetes.single.method, 'PATCH');
        expect(reseau.requetes.single.path, '/taches/t3');
        expect(reseau.requetes.single.data, {'done': true});
        expect(aJour.done, isTrue);
      },
    );

    test('supprimer envoie DELETE /taches/:id', () async {
      final (repo, reseau) = _api((_) => (<String, dynamic>{}, 200));

      await repo.supprimer('t3');

      expect(reseau.requetes.single.method, 'DELETE');
      expect(reseau.requetes.single.path, '/taches/t3');
    });

    test(
      'une réponse d\'erreur devient une ApiException avec son code',
      () async {
        final (repo, _) = _api((_) => ({'erreur': 'introuvable'}, 404));

        expect(
          () => repo.modifierEtat('zz', done: true),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
          ),
        );
      },
    );

    test(
      'un JSON invalide devient une ApiException (fromJson échoue)',
      () async {
        final (repo, _) = _api(
          (_) => (
            [
              {'id': 't9'},
            ],
            200,
          ),
        );

        expect(repo.lister(), throwsA(isA<ApiException>()));
      },
    );
  });

  group('FakeTaskRepository (mémoire)', () {
    test('créer, cocher et supprimer modifient la liste en mémoire', () async {
      final repo = FakeTaskRepository();
      final depart = (await repo.lister()).length;

      await repo.creer(Task.fromJson({..._jsonT3, 'id': 'tx'}));
      expect((await repo.lister()).length, depart + 1);

      final cochee = await repo.modifierEtat('tx', done: true);
      expect(cochee.done, isTrue);

      await repo.supprimer('tx');
      expect((await repo.lister()).any((t) => t.id == 'tx'), isFalse);
    });

    test('en panne, chaque appel lève une ApiException', () async {
      final repo = FakeTaskRepository(enPanne: true);
      expect(repo.lister(), throwsA(isA<ApiException>()));
    });

    test('modifier une tâche inconnue lève une ApiException 404', () async {
      final repo = FakeTaskRepository();
      expect(
        repo.modifierEtat('inconnu', done: true),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });
}
