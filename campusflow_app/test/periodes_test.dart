import 'package:campusflow_app/utils/periodes.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tâche de test dont seule la date et l'état comptent.
Task _tache(String id, DateTime due, {bool done = false}) => Task(
  id: id,
  title: id,
  description: '',
  dueDate: due,
  done: done,
  courseId: 'c1',
);

void main() {
  // Date de référence fixe : le test ne dépend pas du jour où on le lance.
  final now = DateTime(2026, 11, 22, 10);

  test(
    'grouperParPeriode range chaque tâche dans sa section, dans l\'ordre',
    () {
      final taches = [
        _tache('retard', DateTime(2026, 11, 20)),
        _tache('aujourdhui', DateTime(2026, 11, 22, 18)),
        _tache('semaine', DateTime(2026, 11, 25)),
        _tache('tard', DateTime(2026, 12, 15)),
        _tache('faite', DateTime(2026, 11, 1), done: true),
      ];

      final groupes = grouperParPeriode(taches, now: now);

      expect(groupes.keys, [
        Periode.enRetard,
        Periode.aujourdhui,
        Periode.cetteSemaine,
        Periode.plusTard,
        Periode.faites,
      ]);
      expect(groupes[Periode.enRetard]!.single.id, 'retard');
      expect(groupes[Periode.faites]!.single.id, 'faite');
    },
  );

  test('les sections vides ne sont pas affichées', () {
    final groupes = grouperParPeriode([
      _tache('semaine', DateTime(2026, 11, 24)),
    ], now: now);

    expect(groupes.keys, [Periode.cetteSemaine]);
  });
}
