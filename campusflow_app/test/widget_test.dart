import 'package:campusflow_app/main.dart';
import 'package:campusflow_app/screens/task_detail_screen.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Ouvre l'application complète (ProviderScope + routeur) à l'adresse
/// [adresse], comme si l'utilisateur l'avait saisie.
Future<void> _ouvrir(WidgetTester tester, [String adresse = '/taches']) async {
  await tester.pumpWidget(
    ProviderScope(child: CampusFlowApp(initialLocation: adresse)),
  );
  await tester.pumpAndSettle();
}

/// Ouvre le formulaire depuis le bouton flottant de la liste.
Future<void> _ouvrirFormulaire(WidgetTester tester) async {
  await _ouvrir(tester);
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

void main() {
  // Les tests n'appellent pas main() : on charge ici la locale française
  // utilisée par intl pour formater les dates.
  setUpAll(() => initializeDateFormatting('fr'));

  group('Navigation (go_router)', () {
    testWidgets("l'application démarre sur /login", (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CampusFlowApp()));
      await tester.pumpAndSettle();

      expect(find.text('CampusFlow'), findsOneWidget);
      // L'asset déclaré dans pubspec.yaml est affiché (séance 4).
      expect(find.bySemanticsLabel('Logo CampusFlow'), findsOneWidget);

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('Mes échéances'), findsOneWidget);
    });

    // Chaque écran est atteignable par son adresse (sujet, p. 4).
    const ecrans = {
      '/login': 'Se connecter',
      '/taches': 'Mes échéances',
      '/taches/nouvelle': 'Nouvelle tâche',
      '/taches/t3': 'Rapport projet réseaux',
      '/cours': 'Mes cours',
      '/profil': 'Mon profil',
    };
    for (final MapEntry(key: adresse, value: texte) in ecrans.entries) {
      testWidgets('l\'adresse $adresse ouvre son écran', (tester) async {
        await _ouvrir(tester, adresse);
        expect(find.text(texte), findsWidgets);
      });
    }

    testWidgets('un :id inconnu affiche « Tâche introuvable »', (tester) async {
      await _ouvrir(tester, '/taches/inconnu');
      expect(find.text('Tâche introuvable (inconnu).'), findsOneWidget);
    });

    testWidgets('la NavigationBar (ShellRoute) change de destination', (
      tester,
    ) async {
      await _ouvrir(tester);
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.text('Cours'));
      await tester.pumpAndSettle();
      expect(find.text('Mes cours'), findsOneWidget);
      expect(find.text('M. Kaboré'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Mon profil'), findsOneWidget);
    });

    testWidgets('le détail et le formulaire s\'ouvrent sans la barre', (
      tester,
    ) async {
      await _ouvrir(tester, '/taches/t3');
      // Écran secondaire : affiché par-dessus la coquille.
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('Échéances (variante B)', () {
    testWidgets('les échéances sont groupées par période', (tester) async {
      await _ouvrir(tester);

      expect(find.text('En retard'), findsOneWidget);
      // « Aujourd'hui » : en-tête de section ET date courte de la tâche.
      expect(find.text("Aujourd'hui"), findsWidgets);
      expect(find.text('Cette semaine'), findsOneWidget);
    });

    testWidgets('les trois filtres sont reliés à la liste', (tester) async {
      await _ouvrir(tester);
      expect(find.text('À faire · 4'), findsOneWidget);
      expect(find.text('En retard · 1'), findsOneWidget);
      expect(find.text('Faites · 1'), findsOneWidget);

      // Filtre « En retard » : seule la fiche de lecture reste.
      await tester.tap(find.text('En retard · 1'));
      await tester.pumpAndSettle();
      expect(find.text('Fiche de lecture'), findsOneWidget);
      expect(find.text('Rapport projet réseaux'), findsNothing);

      // Second appui : le filtre est désactivé, tout réapparaît.
      await tester.tap(find.text('En retard · 1'));
      await tester.pumpAndSettle();
      expect(find.text('Rapport projet réseaux'), findsOneWidget);
    });

    testWidgets('aucun débordement avec un texte agrandi à 200 %', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const CampusFlowApp(initialLocation: '/taches'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Un « RenderFlex overflowed » ferait échouer le test ici.
      expect(tester.takeException(), isNull);
    });
  });

  group('Détail', () {
    testWidgets('ouvrir une tâche puis la marquer comme faite', (tester) async {
      await _ouvrir(tester);

      await tester.tap(find.text('Rapport projet réseaux'));
      await tester.pumpAndSettle();
      expect(find.text('Détail'), findsOneWidget);
      expect(find.text('À faire'), findsOneWidget);

      // Le bouton est sous la description : on fait défiler jusqu'à lui.
      await tester.ensureVisible(find.text('Marquer comme fait'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marquer comme fait'));
      await tester.pumpAndSettle();
      expect(find.text('Terminée'), findsOneWidget);
      expect(find.text('Remettre à faire'), findsOneWidget);
    });

    testWidgets('le bloc Description est masqué quand il est vide', (
      tester,
    ) async {
      final task = Task(
        id: 't9',
        title: 'Exposé',
        description: '',
        dueDate: DateTime(2026, 12, 1),
        courseId: 'c1',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskDetailView(
              task: task,
              courseTitle: 'Génie logiciel',
              onToggleDone: () {},
            ),
          ),
        ),
      );

      expect(find.text('Exposé'), findsOneWidget);
      expect(find.text('Description'), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Marquer comme fait'),
        findsOneWidget,
      );
    });
  });

  // Le critère du sujet (p. 4) : « une tâche ajoutée ou cochée dans un
  // écran apparaît immédiatement dans les autres ».
  group('État partagé (Riverpod)', () {
    testWidgets('cochée dans le Détail → visible dans la liste et le Profil', (
      tester,
    ) async {
      await _ouvrir(tester);
      // Données de démonstration : 1 tâche faite sur 6.
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 6 tâches terminées'), findsOneWidget);

      // On coche « Rapport projet réseaux » depuis son écran Détail.
      await tester.tap(find.text('Échéances'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rapport projet réseaux'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Marquer comme fait'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marquer comme fait'));
      await tester.pumpAndSettle();

      // Retour à la liste : la tâche est cochée, sans aucun callback.
      // (pageBack() cherche l'info-bulle anglaise « Back » ; l'application
      // étant en français, on appuie directement sur le BackButton.)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      // Cochée, la tâche est passée dans la section « Faites », en bas :
      // ListView.builder ne construit que les lignes visibles, on défile.
      await tester.scrollUntilVisible(
        find.text('Rapport projet réseaux'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Faites'), findsOneWidget);
      final ligne = find.ancestor(
        of: find.text('Rapport projet réseaux'),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: ligne, matching: find.byIcon(Icons.check_circle)),
        findsOneWidget,
      );

      // Le Profil, autre écran, voit aussi le changement.
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 6 tâches terminées'), findsOneWidget);
    });

    testWidgets('ajoutée dans le Formulaire → comptée dans l\'écran Cours', (
      tester,
    ) async {
      await _ouvrir(tester, '/cours');
      // Génie logiciel : 2 tâches dans les données de démonstration.
      final ligneGL = find.ancestor(
        of: find.text('Génie logiciel'),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: ligneGL, matching: find.text('2 tâches')),
        findsOneWidget,
      );

      // Ajout d'une tâche de Génie logiciel depuis le formulaire.
      await tester.tap(find.text('Échéances'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre (obligatoire)'),
        'Revue de code',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Génie logiciel').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // L'écran Cours compte immédiatement la nouvelle tâche.
      await tester.tap(find.text('Cours'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: ligneGL, matching: find.text('3 tâches')),
        findsOneWidget,
      );
    });
  });

  group('Formulaire', () {
    testWidgets('refuse un titre vide', (tester) async {
      await _ouvrirFormulaire(tester);

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Le titre est obligatoire'), findsOneWidget);
      expect(find.text('Choisis un cours'), findsOneWidget);
      expect(find.text('Nouvelle tâche'), findsOneWidget);
    });

    testWidgets('ajoute une tâche et affiche un SnackBar', (tester) async {
      await _ouvrirFormulaire(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre (obligatoire)'),
        'Fiche de révision',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Génie logiciel').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Retour sur la liste : confirmation et nouvelle tâche visible.
      expect(find.text('« Fiche de révision » ajoutée'), findsOneWidget);
      expect(find.text('Fiche de révision'), findsOneWidget);
    });

    testWidgets('bouton × et puces de date', (tester) async {
      await _ouvrirFormulaire(tester);

      expect(find.byIcon(Icons.close), findsOneWidget);
      ChoiceChip chip(String label) =>
          tester.widget(find.widgetWithText(ChoiceChip, label));
      expect(chip('Demain').selected, isTrue);

      await tester.tap(find.text('Dans 3 jours'));
      await tester.pump();
      expect(chip('Dans 3 jours').selected, isTrue);
      expect(chip('Demain').selected, isFalse);
    });

    testWidgets('avec le clavier ouvert, le formulaire défile sans déborder', (
      tester,
    ) async {
      await _ouvrirFormulaire(tester);

      // Simule un clavier qui occupe 400 pixels en bas de l'écran.
      tester.view.viewInsets = const FakeViewPadding(bottom: 400);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Le bouton Enregistrer reste atteignable en faisant défiler.
      await tester.scrollUntilVisible(
        find.text('Enregistrer'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Enregistrer').hitTestable(), findsOneWidget);
    });
  });

  group('Tablette (840 dp)', () {
    // Le seuil se teste à sa limite exacte : 839 dp → liste seule,
    // 840 dp → liste et détail côte à côte (LayoutBuilder, séance 5).
    for (final (largeur, coteACote) in [(839.0, false), (840.0, true)]) {
      testWidgets('à $largeur dp, côte à côte : $coteACote', (tester) async {
        tester.view.physicalSize = Size(largeur, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await _ouvrir(tester);

        expect(
          find.text('Choisis une échéance à gauche.'),
          coteACote ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('sur tablette, le détail s\'affiche à côté de la liste', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _ouvrir(tester);
      await tester.tap(find.text('Rapport projet réseaux'));
      await tester.pumpAndSettle();

      // Pas de nouvelle page : la liste est toujours là, le détail à côté.
      expect(find.text('Détail'), findsNothing);
      expect(find.text('Marquer comme fait'), findsOneWidget);

      await tester.tap(find.text('Marquer comme fait'));
      await tester.pumpAndSettle();
      expect(find.text('Remettre à faire'), findsOneWidget);
    });
  });
}
