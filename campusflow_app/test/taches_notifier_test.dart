import 'package:campusflow_app/providers/taches_provider.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests du TachesNotifier sans aucun widget : un ProviderContainer joue le
/// rôle du ProviderScope (Riverpod est « testable sans interface »).
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  List<Task> taches() => container.read(tachesProvider);
  TachesNotifier notifier() => container.read(tachesProvider.notifier);

  test('l\'état initial est trié par échéance', () {
    final dates = taches().map((t) => t.dueDate).toList();
    final triees = [...dates]..sort();
    expect(dates, triees);
  });

  test('ajouter assigne une NOUVELLE liste et laisse l\'ancienne intacte', () {
    final avant = taches();
    final nouvelle = Task(
      id: 'tx',
      title: 'Nouvelle',
      description: '',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      courseId: 'c1',
    );

    notifier().ajouter(nouvelle);
    final apres = taches();

    // Règle n° 1 : pas de modification en place.
    expect(identical(avant, apres), isFalse);
    expect(apres.length, avant.length + 1);
    expect(avant.any((t) => t.id == 'tx'), isFalse);
    expect(apres.any((t) => t.id == 'tx'), isTrue);
  });

  test('basculer remplace seulement la tâche visée, par une copie', () {
    final avant = taches();
    final cible = avant.firstWhere((t) => !t.done);

    notifier().basculer(cible.id);
    final apres = taches();

    // La tâche d'origine n'a pas changé (objet immuable, copyWith).
    expect(cible.done, isFalse);
    expect(apres.firstWhere((t) => t.id == cible.id).done, isTrue);
    // Les autres tâches sont les MÊMES objets : rien n'a été recopié inutilement.
    for (var i = 0; i < avant.length; i++) {
      if (avant[i].id != cible.id) {
        expect(identical(avant[i], apres[i]), isTrue);
      }
    }
  });

  test('chaque action prévient les écouteurs (ce que fait ref.watch)', () {
    var notifications = 0;
    container.listen(tachesProvider, (_, _) => notifications++);

    notifier().basculer('t3');
    notifier().basculer('t3');

    expect(notifications, 2);
  });

  test('tacheParIdProvider suit l\'état partagé', () {
    expect(container.read(tacheParIdProvider('t3'))!.done, isFalse);
    notifier().basculer('t3');
    expect(container.read(tacheParIdProvider('t3'))!.done, isTrue);
    expect(container.read(tacheParIdProvider('inconnu')), isNull);
  });
}
