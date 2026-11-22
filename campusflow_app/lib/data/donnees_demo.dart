import 'package:campusflow_models/campusflow_models.dart';

/// Données de démonstration en mémoire (séance 6).
/// En séance 7, elles seront remplacées par l'API json-server.
/// Contexte repris du persona (docs/seance2) : Sanata, L3 Informatique.

const demoUtilisateur = User(
  id: 'u1',
  name: 'Sanata Ouédraogo',
  email: 'sanata.ouedraogo@exemple.bf',
);

const demoCours = [
  Course(id: 'c1', title: 'Réseaux informatiques', teacher: 'M. Kaboré'),
  Course(id: 'c2', title: 'Bases de données', teacher: 'Mme Ilboudo'),
  Course(id: 'c3', title: 'Génie logiciel', teacher: 'M. Sawadogo'),
  Course(id: 'c4', title: 'Anglais technique', teacher: 'M. Zongo'),
];

/// Tâches de démonstration, datées par rapport à [maintenant] pour que
/// chaque section de l'écran Échéances (variante B) soit représentée.
List<Task> demoTaches(DateTime maintenant) {
  // Jour J à 18 h, décalé de [jours].
  DateTime jour(int jours, {int heure = 18}) => DateTime(
    maintenant.year,
    maintenant.month,
    maintenant.day + jours,
    heure,
  );

  return [
    Task(
      id: 't1',
      title: 'Fiche de lecture',
      description: 'Résumé d\'un article technique en anglais, 2 pages.',
      dueDate: jour(-1),
      courseId: 'c4',
    ),
    Task(
      id: 't2',
      title: 'Quiz en ligne',
      description: 'Quiz de 20 questions sur la normalisation.',
      dueDate: jour(0, heure: 23),
      courseId: 'c2',
    ),
    Task(
      id: 't3',
      title: 'Rapport projet réseaux',
      description:
          'Rapport de 10 pages : plan d\'adressage IP, VLAN et tests de '
          'connectivité. Rendu en PDF sur la plateforme, en binôme.',
      dueDate: jour(1),
      courseId: 'c1',
    ),
    Task(
      id: 't4',
      title: 'TP Bases de données',
      description: 'Requêtes SQL avec jointures et sous-requêtes.',
      dueDate: jour(3),
      courseId: 'c2',
    ),
    Task(
      id: 't5',
      title: 'Exposé Génie logiciel',
      description: 'Présentation de 15 minutes sur les méthodes agiles.',
      dueDate: jour(12),
      courseId: 'c3',
    ),
    Task(
      id: 't6',
      title: 'Diagramme de classes',
      description: 'Modélisation UML du projet de groupe.',
      dueDate: jour(-4),
      done: true,
      courseId: 'c3',
    ),
  ];
}
