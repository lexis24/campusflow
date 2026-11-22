import 'package:campusflow_models/campusflow_models.dart';

import 'dates.dart';

/// Sections de l'écran Échéances, dans l'ordre d'affichage
/// (variante B retenue en séance 2 : liste groupée par période).
enum Periode {
  enRetard('En retard'),
  aujourdhui("Aujourd'hui"),
  cetteSemaine('Cette semaine'),
  plusTard('Plus tard'),
  faites('Faites');

  const Periode(this.libelle);

  /// Texte affiché dans l'en-tête de section.
  final String libelle;
}

/// Période d'une tâche par rapport à aujourd'hui.
/// « Cette semaine » couvre les 7 prochains jours.
Periode periodeDe(Task task, {DateTime? now}) {
  if (task.done) return Periode.faites;
  final jours = daysLeft(task.dueDate, now: now);
  if (jours < 0) return Periode.enRetard;
  if (jours == 0) return Periode.aujourdhui;
  if (jours <= 7) return Periode.cetteSemaine;
  return Periode.plusTard;
}

/// Regroupe les tâches par période, dans l'ordre de [Periode.values],
/// en conservant l'ordre des tâches et sans section vide.
///
/// Fonction pure : elle ne modifie pas [taches] et renvoie une nouvelle Map.
Map<Periode, List<Task>> grouperParPeriode(List<Task> taches, {DateTime? now}) {
  // Une Map littérale garde l'ordre d'insertion : les sections sortent
  // dans l'ordre de l'enum.
  final groupes = {for (final p in Periode.values) p: <Task>[]};
  for (final tache in taches) {
    groupes[periodeDe(tache, now: now)]!.add(tache);
  }
  groupes.removeWhere((_, liste) => liste.isEmpty);
  return groupes;
}
