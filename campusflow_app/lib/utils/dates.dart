import 'package:intl/intl.dart';

/// Format « jour mois-abrégé année » en français, fourni par le package intl.
/// Les données de la locale « fr » sont chargées dans main()
/// avec initializeDateFormatting('fr').
final _dateFormat = DateFormat('d MMM y', 'fr');

/// Ex. : "2 nov. 2026"
String formatDate(DateTime date) => _dateFormat.format(date);

/// Format court « jour-abrégé jour mois-abrégé » : "mer. 25 nov.".
final _shortFormat = DateFormat('E d MMM', 'fr');

/// Date courte pour la colonne de droite d'une ligne de tâche (variante B) :
/// "Hier", "Aujourd'hui", "Demain", sinon "mer. 25 nov.".
/// Volontairement court pour ne pas déborder de la ligne.
String shortDueDate(DateTime dueDate, {DateTime? now}) {
  final days = daysLeft(dueDate, now: now);
  if (days == -1) return 'Hier';
  if (days == 0) return "Aujourd'hui";
  if (days == 1) return 'Demain';
  return _shortFormat.format(dueDate);
}

/// Nombre de jours entre aujourd'hui et [dueDate] (négatif si c'est passé).
int daysLeft(DateTime dueDate, {DateTime? now}) {
  now ??= DateTime.now();
  // On passe en UTC pour ne pas être gêné par le changement d'heure.
  final today = DateTime.utc(now.year, now.month, now.day);
  final day = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
  return day.difference(today).inDays;
}

/// Ex. : "Aujourd'hui", "Demain", "Dans 3 jours", "En retard de 2 jours"
String relativeDueDate(DateTime dueDate, {DateTime? now}) {
  final days = daysLeft(dueDate, now: now);
  if (days == 0) return "Aujourd'hui";
  if (days == 1) return 'Demain';
  if (days > 1) return 'Dans $days jours';
  if (days == -1) return "En retard d'1 jour";
  return 'En retard de ${-days} jours';
}
