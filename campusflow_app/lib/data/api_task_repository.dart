import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';

import '../core/api_exception.dart';
import 'task_repository.dart';

/// Implémentation du contrat qui appelle l'API REST json-server avec Dio.
class ApiTaskRepository implements TaskRepository {
  const ApiTaskRepository(this._dio);

  final Dio _dio;

  /// Chemin de la ressource dans db.json.
  static const _chemin = '/taches';

  @override
  Future<List<Task>> lister() => _appel(() async {
    final reponse = await _dio.get<List<dynamic>>(_chemin);
    // fromJson (séance 3) construit chaque Task à partir du JSON reçu.
    return reponse.data!
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<Task> creer(Task tache) => _appel(() async {
    final reponse = await _dio.post<Map<String, dynamic>>(
      _chemin,
      data: tache.toJson(),
    );
    return Task.fromJson(reponse.data!);
  });

  @override
  Future<Task> modifierEtat(String id, {required bool done}) =>
      _appel(() async {
        // PATCH : on n'envoie que le champ modifié.
        final reponse = await _dio.patch<Map<String, dynamic>>(
          '$_chemin/$id',
          data: {'done': done},
        );
        return Task.fromJson(reponse.data!);
      });

  @override
  Future<void> supprimer(String id) =>
      _appel(() => _dio.delete<void>('$_chemin/$id'));

  /// Exécute [requete] et traduit les erreurs Dio en ApiException, pour que
  /// les couches supérieures n'aient jamais affaire à Dio.
  Future<T> _appel<T>(Future<T> Function() requete) async {
    try {
      return await requete();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on FormatException catch (e) {
      // JSON reçu mais invalide pour fromJson (champ manquant, mauvais type).
      throw ApiException('Données reçues invalides : ${e.message}');
    }
  }
}
