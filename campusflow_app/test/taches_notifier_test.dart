import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/data/fake_task_repository.dart';
import 'package:campusflow_app/providers/repository_provider.dart';
import 'package:campusflow_app/providers/taches_provider.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests du TachesNotifier (AsyncNotifier, séance 7) sans aucun widget.
/// Le repository API est remplacé par le FakeTaskRepository.
void main() {
  late FakeTaskRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeTaskRepository();
    container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  /// Attend la fin du chargement et renvoie la liste.
  Future<List<Task>> charger() => container.read(tachesProvider.future);
  List<Task> taches() => container.read(tachesProvider).requireValue;
  TachesNotifier notifier() => container.read(tachesProvider.notifier);

  test('l\'état passe de « chargement » à « données »', () async {
    expect(container.read(tachesProvider).isLoading, isTrue);
    final liste = await charger();
    expect(container.read(tachesProvider).hasValue, isTrue);
    // Trié par échéance.
    final dates = liste.map((t) => t.dueDate).toList();
    expect(dates, [...dates]..sort());
  });

  test('si le serveur est injoignable, l\'état passe en « erreur »', () async {
    repo.enPanne = true;
    await expectLater(charger(), throwsA(isA<ApiException>()));
    expect(container.read(tachesProvider).hasError, isTrue);
  });

  test('« Réessayer » (invalidate) relance le chargement', () async {
    repo.enPanne = true;
    await expectLater(charger(), throwsA(isA<ApiException>()));

    repo.enPanne = false;
    container.invalidate(tachesProvider);
    expect((await charger()).isNotEmpty, isTrue);
  });

  test('ajouter (POST) assigne une NOUVELLE liste', () async {
    final avant = await charger();
    final nouvelle = Task(
      id: 'tx',
      title: 'Nouvelle',
      description: '',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      courseId: 'c1',
    );

    await notifier().ajouter(nouvelle);

    // Règle n° 1 (séance 6) : pas de modification en place.
    expect(identical(avant, taches()), isFalse);
    expect(taches().length, avant.length + 1);
    // Le serveur (ici le Fake) a bien reçu la tâche.
    expect((await repo.lister()).any((t) => t.id == 'tx'), isTrue);
  });

  test(
    'basculer (PATCH) remplace la tâche par la version du serveur',
    () async {
      final avant = await charger();
      final cible = avant.firstWhere((t) => !t.done);

      await notifier().basculer(cible.id);

      expect(cible.done, isFalse); // l'ancien objet n'a pas changé
      expect(taches().firstWhere((t) => t.id == cible.id).done, isTrue);
    },
  );

  test('supprimer (DELETE) retire la tâche', () async {
    await charger();
    await notifier().supprimer('t3');
    expect(taches().any((t) => t.id == 't3'), isFalse);
    expect((await repo.lister()).any((t) => t.id == 't3'), isFalse);
  });

  test('une action qui échoue laisse la liste intacte', () async {
    final avant = await charger();
    repo.enPanne = true;

    await expectLater(notifier().basculer('t3'), throwsA(isA<ApiException>()));
    // Rien n'a changé à l'écran : on n'affiche que ce que le serveur a accepté.
    expect(taches(), avant);
  });

  test('tacheParIdProvider suit l\'état partagé', () async {
    await charger();
    expect(container.read(tacheParIdProvider('t3')).value!.done, isFalse);
    await notifier().basculer('t3');
    expect(container.read(tacheParIdProvider('t3')).value!.done, isTrue);
    expect(container.read(tacheParIdProvider('inconnu')).value, isNull);
  });
}
