# CampusFlow

Application Flutter de suivi des échéances de cours : on voit ce qu'il reste à rendre,
on ouvre une tâche pour la marquer comme faite et on en ajoute de nouvelles.

**Tester en ligne :** https://lexis24.github.io/campusflow_app/

Les données (utilisateur, cours, tâches) viennent du package
[campusflow_models](https://github.com/lexis24/campusflow_models) réalisé à la séance précédente.

## Écrans

| Écran | Widgets principaux |
|---|---|
| Échéances | `Scaffold`, `AppBar`, `ListView.builder` de `ListTile`, `FloatingActionButton`, `NavigationBar` |
| Détail | `Column`, `Card`, `FilledButton` « Marquer comme fait » |
| Formulaire | `Form`, `TextFormField` + `validator`, `SnackBar`, `SingleChildScrollView` |
| Tablette | `LayoutBuilder` : au-delà de 840 dp, liste et détail côte à côte |

## Lancer le projet

```bash
flutter pub get
flutter run -d chrome
```

Pour voir la version tablette, il suffit d'élargir la fenêtre du navigateur au-delà de 840 px.

## Tests

```bash
flutter test
flutter analyze
```

## Déploiement

À chaque push sur `main`, GitHub Actions lance les tests, construit la version web
(`flutter build web`) et la publie sur GitHub Pages (voir `.github/workflows/deploy.yml`).
