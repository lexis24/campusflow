import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import '../data/api_task_repository.dart';
import '../data/task_repository.dart';

/// Fournit le repository des tâches (injection de dépendances, séance 6).
///
/// Dans l'application : l'implémentation API (Dio → json-server).
/// Dans les tests : remplacé par FakeTaskRepository avec
/// `taskRepositoryProvider.overrideWithValue(FakeTaskRepository())`.
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ApiTaskRepository(ref.watch(dioProvider)),
);
