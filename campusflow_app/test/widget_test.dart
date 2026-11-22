import 'package:campusflow_app/main.dart';
import 'package:campusflow_app/screens/home_screen.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pas d'attente d'1 seconde dans les tests.
const _repository = CampusRepository(delay: Duration.zero);

Future<void> _openApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: HomeScreen(repository: _repository)),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Les tests n'appellent pas main() : on charge ici la locale française
  // utilisée par intl pour formater les dates.
  setUpAll(() => initializeDateFormatting('fr'));

  testWidgets("l'application démarre sur l'écran de titre", (tester) async {
    await tester.pumpWidget(const CampusFlowApp());

    expect(find.text('CampusFlow'), findsOneWidget);
    // L'asset déclaré dans pubspec.yaml est affiché.
    expect(find.bySemanticsLabel('Logo CampusFlow'), findsOneWidget);
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    // Après « Commencer », on arrive sur les échéances.
    expect(find.text('Mes échéances'), findsOneWidget);
  });

  testWidgets('affiche un chargement puis la liste des échéances', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(repository: _repository)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('TP modèles Dart'), findsOneWidget);
    expect(find.text('Projet réseau de neurones'), findsOneWidget);
  });

  testWidgets('les échéances sont groupées par période (variante B)', (
    tester,
  ) async {
    await _openApp(tester);

    // Données de démonstration : 2 tâches en retard, 1 faite.
    expect(find.text('En retard'), findsOneWidget);
    expect(find.text('Faites'), findsOneWidget);
    // Chaque ligne, en-têtes compris, est un ListTile : 2 en-têtes + 3 tâches.
    expect(find.byType(ListTile), findsNWidgets(5));
  });

  testWidgets('aucun débordement avec un texte agrandi à 200 %', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        // Simule le réglage « taille du texte » du téléphone au maximum.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const HomeScreen(repository: _repository),
      ),
    );
    await tester.pumpAndSettle();

    // Un « RenderFlex overflowed » ferait échouer le test ici.
    expect(tester.takeException(), isNull);
    expect(find.text('En retard'), findsOneWidget);
  });

  testWidgets('la NavigationBar affiche les cours', (tester) async {
    await _openApp(tester);

    await tester.tap(find.text('Cours'));
    await tester.pumpAndSettle();

    expect(find.text('Mes cours'), findsOneWidget);
    expect(find.text('Mme Diallo'), findsOneWidget);
  });

  testWidgets('le détail permet de marquer une tâche comme faite', (
    tester,
  ) async {
    await _openApp(tester);

    await tester.tap(find.text('Tests unitaires'));
    await tester.pumpAndSettle();
    expect(find.text('Détail'), findsOneWidget);
    expect(find.text('À faire'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('Terminée'), findsOneWidget);
    expect(find.text('Remettre à faire'), findsOneWidget);

    // De retour sur la liste, la tâche est cochée.
    await tester.pageBack();
    await tester.pumpAndSettle();
    final tile = find.ancestor(
      of: find.text('Tests unitaires'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: tile, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
  });

  testWidgets('le formulaire refuse un titre vide', (tester) async {
    await _openApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Le titre est obligatoire'), findsOneWidget);
    expect(find.text('Choisis un cours'), findsOneWidget);
    // On est toujours sur le formulaire.
    expect(find.text('Nouvelle tâche'), findsOneWidget);
  });

  testWidgets('le formulaire ajoute une tâche et affiche un SnackBar', (
    tester,
  ) async {
    await _openApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre'),
      'Fiche de révision',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intelligence artificielle').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('« Fiche de révision » ajoutée'), findsOneWidget);
    expect(find.text('Fiche de révision'), findsOneWidget);
  });

  testWidgets('sur tablette, liste et détail sont côte à côte', (tester) async {
    // Écran de 1280 x 800, au-dessus du seuil de 840 dp.
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _openApp(tester);
    expect(find.text('Choisis une échéance à gauche.'), findsOneWidget);

    await tester.tap(find.text('Tests unitaires'));
    await tester.pumpAndSettle();

    // Pas de nouvelle page : la liste est toujours là, le détail à côté.
    expect(find.text('Détail'), findsNothing);
    expect(find.text('Projet réseau de neurones'), findsOneWidget);
    expect(find.text('Marquer comme fait'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('Remettre à faire'), findsOneWidget);
  });
}
