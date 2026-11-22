import 'package:campusflow_app/core/session_storage.dart';
import 'package:campusflow_app/data/fake_task_repository.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:campusflow_app/providers/filtres_provider.dart';
import 'package:campusflow_app/providers/repository_provider.dart';
import 'package:campusflow_app/providers/taches_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests des fournisseurs dérivés de filtrage (séance 6), sans interface.
/// Depuis la séance 7, les tâches sont chargées (FakeTaskRepository).
void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
        // Utilisateur connecté : sans session, la liste n'est pas chargée.
        sessionStorageProvider.overrideWithValue(
          MemorySessionStorage(
            const Session(
              jeton: 'jeton-de-test',
              utilisateur: User(
                id: 'u1',
                name: 'Sanata',
                email: 's@exemple.bf',
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Attend la fin du chargement asynchrone.
    await container.read(tachesProvider.future);
  });

  int nombreTaches() => container.read(tachesProvider).requireValue.length;
  List<String> idsFiltres() => container
      .read(tachesFiltreesProvider)
      .requireValue
      .map((t) => t.id)
      .toList();

  test('sans filtre, toutes les tâches sont affichées', () {
    expect(container.read(filtreProvider), isNull);
    expect(idsFiltres().length, nombreTaches());
  });

  test('les trois filtres se partagent toutes les tâches, sans doublon', () {
    final compteurs = container.read(compteursFiltresProvider);
    final total = compteurs.values.reduce((a, b) => a + b);
    expect(total, nombreTaches());
    // Données de démonstration : t1 en retard, t6 faite, 4 à faire.
    expect(compteurs[FiltreTaches.enRetard], 1);
    expect(compteurs[FiltreTaches.faites], 1);
    expect(compteurs[FiltreTaches.aFaire], 4);
  });

  test('choisir un filtre ne garde que ses tâches', () {
    container.read(filtreProvider.notifier).choisir(FiltreTaches.enRetard);
    expect(idsFiltres(), ['t1']);

    container.read(filtreProvider.notifier).choisir(FiltreTaches.faites);
    expect(idsFiltres(), ['t6']);
  });

  test('choisir deux fois le même filtre le désactive', () {
    final notifier = container.read(filtreProvider.notifier);
    notifier.choisir(FiltreTaches.aFaire);
    notifier.choisir(FiltreTaches.aFaire);
    expect(container.read(filtreProvider), isNull);
  });

  test('la liste dérivée se recalcule quand une tâche est cochée', () async {
    container.read(filtreProvider.notifier).choisir(FiltreTaches.faites);
    expect(idsFiltres(), ['t6']);

    // On coche t3 dans l'état partagé : le filtre « Faites » la contient
    // aussitôt, sans rien recopier à la main.
    await container.read(tachesProvider.notifier).basculer('t3');
    expect(idsFiltres(), containsAll(['t3', 't6']));
    expect(container.read(compteursFiltresProvider)[FiltreTaches.faites], 2);
  });
}
