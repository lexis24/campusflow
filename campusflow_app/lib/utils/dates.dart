const _months = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// Ex. : "2 nov. 2026"
String formatDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
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
