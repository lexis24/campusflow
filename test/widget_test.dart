import 'package:campusflow_app/screens/home_screen.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pas d'attente d'1 seconde dans les tests.
const _repository = CampusRepository(delay: Duration.zero);

Future<void> _openApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: HomeScreen(repository: _repository)),
  );
  await tester.pumpAndSettle();
}

void main() {
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
}
