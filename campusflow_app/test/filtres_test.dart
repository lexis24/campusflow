import 'package:campusflow_app/providers/filtres_provider.dart';
import 'package:campusflow_app/providers/taches_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests des fournisseurs dérivés de filtrage (séance 6), sans interface.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  List<String> idsFiltres() =>
      container.read(tachesFiltreesProvider).map((t) => t.id).toList();

  test('sans filtre, toutes les tâches sont affichées', () {
    expect(container.read(filtreProvider), isNull);
    expect(idsFiltres().length, container.read(tachesProvider).length);
  });

  test('les trois filtres se partagent toutes les tâches, sans doublon', () {
    final compteurs = container.read(compteursFiltresProvider);
    final total = compteurs.values.reduce((a, b) => a + b);
    expect(total, container.read(tachesProvider).length);
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

  test('la liste dérivée se recalcule quand une tâche est cochée', () {
    container.read(filtreProvider.notifier).choisir(FiltreTaches.faites);
    expect(idsFiltres(), ['t6']);

    // On coche t3 dans l'état partagé : le filtre « Faites » la contient
    // aussitôt, sans rien recopier à la main.
    container.read(tachesProvider.notifier).basculer('t3');
    expect(idsFiltres(), containsAll(['t3', 't6']));
    expect(container.read(compteursFiltresProvider)[FiltreTaches.faites], 2);
  });
}
