# CampusFlow

Application mobile Flutter de suivi des cours, échéances et tâches d'un étudiant.
TP de Programmation Mobile, Master 1 (2026-2027), enseignant : COMPAORE Moctar.

## Organisation du dépôt

| Dossier | Contenu | Séances |
|---|---|---|
| [docs/](docs/) | Livrables non codés et preuves : décision de plateforme, persona, parcours, wireframes, design system, captures | 1, 2, 4, 5, 7 |
| [campusflow_models/](campusflow_models/) | Package Dart : modèles `Task`, `Course`, `User`, `fromJson`, dépôt simulé et tests | 3 |
| [campusflow_app/](campusflow_app/) | Application Flutter | 4 à 7 |
| [server/](server/) | `db.json` et `auth.js` pour json-server (API REST simulée avec connexion) | 7 |

## Lancer le projet

```bash
# 1. Tests du package de modèles (séance 3)
cd campusflow_models
dart pub get
dart test

# 2. Serveur simulé avec authentification (séance 7)
npm install -g json-server@0.17.4          # une seule fois
cd server
json-server --watch db.json --host 127.0.0.1 --port 3000 --middlewares ./auth.js

# 3. Application (dans un autre terminal, émulateur Android démarré)
cd campusflow_app
flutter pub get
flutter test                               # 61 tests
flutter run
```

**Compte de démonstration :** `sanata.ouedraogo@exemple.bf` / `campus2026`

L'application appelle l'API par `http://10.0.2.2:3000` sur l'émulateur Android. Voir [server/README.md](server/README.md) pour les détails (dont la raison de `--host 127.0.0.1`).

## Architecture de l'application

```
campusflow_app/lib/
├── core/        client Dio, intercepteur d'authentification, stockage sécurisé, erreurs
├── data/        contrats TaskRepository / AuthRepository, implémentations API et Fake
├── providers/   état partagé Riverpod : TachesNotifier (AsyncNotifier), filtres, session
├── screens/     écrans (connexion, échéances, détail, formulaire, cours, profil)
├── theme/       ThemeData du design system (aucune couleur ni taille en dur)
├── utils/       dates, périodes (variante B), actions réseau
└── router.dart  GoRouter : 6 adresses, ShellRoute, redirection selon la session
```

## Auto-vérification (sujet, p. 4)

- [x] **Séance 1** : [fiche comparative](docs/seance1/fiche-comparative.md), [autopsie sourcée](docs/seance1/autopsie.md), [paragraphe de décision](docs/seance1/decision-campusflow.md)
- [x] **Séance 2** : [persona](docs/seance2/persona-job-stories.md), [parcours](docs/seance2/parcours.md), [wireframes avec 3 variantes d'un écran](docs/seance2/wireframes/justification.md), [design system v1](docs/seance2/design-system-v1.md)
- [x] **Séance 3** : package [`campusflow_models`](campusflow_models/) avec Task, Course, User, fromJson et 3 tests (24 au total) qui passent
- [x] **Séance 4** : [flutter doctor sans erreur](docs/seance4/flutter-doctor.txt), [application sur l'émulateur](docs/seance4/app-emulateur.png), thème centralisé, [asset affiché](docs/seance4/asset-logo.png), plus de 3 commits
- [x] **Séance 5** : écrans Échéances (variante B), Détail et Formulaire, [version tablette à 840 dp](docs/seance5/tablette-paysage.png)
- [x] **Séance 6** : navigation par adresses (GoRouter, ShellRoute), état partagé entre les trois écrans, trois filtres
- [x] **Séance 7** : API json-server, couches Repository, liste connectée ([données](docs/seance7/etat-donnees-api.png), [erreur et Réessayer](docs/seance7/etat-erreur-reessayer.png), POST, PATCH, DELETE), connexion avec jeton sécurisé ([session conservée](docs/seance7/session-conservee.png), [redirection sur 401](docs/seance7/redirection-401.png))
- [x] Lien du dépôt GitHub ouvert en lecture et envoyé à l'enseignant
