# CampusFlow

Application mobile Flutter de suivi des cours, échéances et tâches d'un étudiant.
TP de Programmation Mobile, Master 1 (2026-2027), enseignant : COMPAORE Moctar.

## Organisation du dépôt

| Dossier | Contenu | Séances |
|---|---|---|
| [docs/](docs/) | Livrables non codés : décision de plateforme, persona, parcours, wireframes, design system | 1, 2, 4 |
| [campusflow_models/](campusflow_models/) | Package Dart : modèles `Task`, `Course`, `User`, `fromJson`, dépôt simulé et tests | 3 |
| [campusflow_app/](campusflow_app/) | Application Flutter | 4 à 7 |
| [server/](server/) | `db.json` pour json-server (API REST simulée) | 7 |

## Lancer le projet

```bash
# Tests du package de modèles (séance 3)
cd campusflow_models
dart pub get
dart test

# Application Flutter (séances 4 à 7)
cd campusflow_app
flutter pub get
flutter run
```

## Auto-vérification (sujet, p. 4)

- [ ] Séance 1 : fiche comparative, autopsie sourcée, paragraphe de décision
- [ ] Séance 2 : persona, parcours, 5 wireframes (3 variantes d'un écran), design system v1
- [ ] Séance 3 : package `campusflow_models` avec Task, Course, User, fromJson et 3 tests qui passent
- [ ] Séance 4 : flutter doctor sans erreur, application sur l'émulateur, thème centralisé, asset affiché, au moins 3 commits
- [ ] Séance 5 : écrans Échéances, Détail et Formulaire, version tablette à 840 dp
- [ ] Séance 6 : navigation par adresses, état partagé entre les trois écrans, trois filtres
- [ ] Séance 7 : API json-server, couches Repository, liste connectée (POST, PATCH, DELETE), connexion avec jeton sécurisé
