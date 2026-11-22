# Séance 2 : design system v1 de CampusFlow

Cette page est la référence visuelle de l'application. Elle sera traduite en `ThemeData` en séance 4 : **aucune couleur ni taille ne sera écrite en dur dans les widgets**, tout sera lu dans le thème.

Les choix découlent des étapes précédentes :
- **Material 3**, puisque la cible est Android en priorité ([décision](../seance1/decision-campusflow.md)) ;
- l'usage **à une main entre deux cours** ([persona](persona-job-stories.md)) ;
- la **variante B** retenue pour l'écran Échéances ([wireframes](wireframes/justification.md)).

---

## 1. Couleurs

**Couleur de départ (seed) : indigo `#3F51B5`** (`Colors.indigo`). Flutter en dérive toute la palette avec `ColorScheme.fromSeed`. Les valeurs ci-dessous ont été **générées par Flutter 3.47** et ne sont pas des estimations. Thème **clair uniquement** pour la version 1.

| Rôle (token) | Valeur | Usage dans CampusFlow |
|---|---|---|
| `primary` | `#515B92` | Bouton principal, bouton « Nouvelle tâche », icône « fait », liens |
| `onPrimary` | `#FFFFFF` | Texte et icône posés sur `primary` |
| `primaryContainer` | `#DEE0FF` | Fond de la destination active dans la barre de navigation |
| `onPrimaryContainer` | `#394379` | Texte sur `primaryContainer` |
| `secondaryContainer` | `#E0E1F9` | Puce de filtre active, ligne sélectionnée (tablette) |
| `onSecondaryContainer` | `#434659` | Texte sur `secondaryContainer` |
| `surface` | `#FBF8FF` | Fond des écrans |
| `onSurface` | `#1B1B21` | Texte principal (titres de tâches) |
| `onSurfaceVariant` | `#46464F` | Texte secondaire (nom du cours, date) |
| `surfaceContainerHighest` | `#E4E1E9` | Fond des en-têtes de section (« Aujourd'hui », « Cette semaine »…) |
| `outline` | `#767680` | Bordure des champs et des cartes |
| `error` | `#BA1A1A` | Tâche **en retard**, message d'erreur de formulaire |
| `onError` | `#FFFFFF` | Texte posé sur `error` (badge, en-tête « En retard ») |

### Vérification du contraste (WCAG 2.1, niveau AA)

**Méthode.** On calcule la luminance relative de chaque couleur : L = 0,2126 R + 0,7152 G + 0,0722 B, où R, G et B sont les composantes après correction gamma. Le rapport de contraste vaut ensuite **(L_claire + 0,05) / (L_foncée + 0,05)**.

**Seuils** : **4,5:1** pour le texte courant (cours, séance 2, diapo 14) et **3:1** pour les éléments non textuels comme les bordures et les icônes (WCAG 1.4.11).

| Usage | Texte / élément | Fond | Rapport | Seuil | Résultat |
|---|---|---|---:|---:|:--:|
| Texte principal | `onSurface` #1B1B21 | `surface` #FBF8FF | **16,30:1** | 4,5 | ✓ |
| Texte secondaire (cours, dates) | `onSurfaceVariant` #46464F | `surface` #FBF8FF | **8,88:1** | 4,5 | ✓ |
| Texte du bouton principal | `onPrimary` #FFFFFF | `primary` #515B92 | **6,44:1** | 4,5 | ✓ |
| Lien, bouton texte | `primary` #515B92 | `surface` #FBF8FF | **6,12:1** | 4,5 | ✓ |
| Texte « En retard » | `error` #BA1A1A | `surface` #FBF8FF | **6,14:1** | 4,5 | ✓ |
| Texte sur badge d'erreur | `onError` #FFFFFF | `error` #BA1A1A | **6,46:1** | 4,5 | ✓ |
| Badge « en retard » (écran Détail, ajouté en séance 5) | `onErrorContainer` #93000A | `errorContainer` #FFDAD6 | **7,24:1** | 4,5 | ✓ |
| Puce active, ligne sélectionnée | `onSecondaryContainer` #434659 | `secondaryContainer` #E0E1F9 | **7,22:1** | 4,5 | ✓ |
| Texte sur conteneur primaire | `onPrimaryContainer` #394379 | `primaryContainer` #DEE0FF | **7,20:1** | 4,5 | ✓ |
| En-tête de section | `onSurface` #1B1B21 | `surfaceContainerHighest` #E4E1E9 | **13,26:1** | 4,5 | ✓ |
| Bordure de champ | `outline` #767680 | `surface` #FBF8FF | **4,27:1** | 3 | ✓ |
| ⚠ Icône « fait » du code actuel | `Colors.green` #4CAF50 (en dur) | `surface` #FBF8FF | **2,64:1** | 3 | ✗ |

**Conclusion.** Toutes les paires du thème respectent le niveau AA. La seule couleur qui échoue est le **vert écrit en dur** dans le code actuel (`home_screen.dart`) : c'est la preuve concrète qu'il faut passer par le thème. **Règle :** l'icône « fait » utilise `primary` (6,12:1), et l'état « fait » est aussi signalé par le texte barré, pour ne jamais reposer sur la couleur seule.

---

## 2. Typographie

**Police : Roboto**, la police par défaut de Material sur Android. Elle ne demande aucune dépendance ni aucun téléchargement, ce qui reste léger pour le parc visé. On utilise l'**échelle typographique Material 3** sans la modifier. Les tailles sont en sp et suivent donc le réglage de taille de texte du téléphone (jusqu'à 200 %, cours, diapo 14).

| Style (token `TextTheme`) | Taille / interligne | Graisse | Usage |
|---|---|---|---|
| `headlineSmall` | 24 / 32 sp | Regular | Titre de la tâche (écran Détail) |
| `titleLarge` | 22 / 28 sp | Regular | Titre de la barre d'application (« Échéances ») |
| `titleMedium` | 16 / 24 sp | Medium | Titre d'une ligne de tâche, en-tête de section |
| `bodyLarge` | 16 / 24 sp | Regular | Description, saisie dans les champs |
| `bodyMedium` | 14 / 20 sp | Regular | Nom du cours, sous-titres |
| `labelLarge` | 14 / 20 sp | Medium | Texte des boutons, des puces et de la date relative |

## 3. Espacements et formes

| Token | Valeur | Usage |
|---|---|---|
| Espacement S | 8 dp | Entre une icône et son texte, entre deux puces |
| Espacement M | 16 dp | Marges latérales des écrans, entre deux champs |
| Espacement L | 24 dp | Avant le bouton principal d'un formulaire |
| Arrondi moyen | 12 dp | Cartes, champs de saisie |
| Arrondi complet | Pilule | Boutons, puces de filtre |
| **Cible tactile minimale** | **48 × 48 dp** | Tout élément touchable (Material, cours, diapo 14) |

---

## 4. Trois composants

### 4.1 Bouton principal

| | |
|---|---|
| **Flutter** | `FilledButton` (action principale d'un écran), `FloatingActionButton.extended` (« Nouvelle tâche »), `OutlinedButton` (action secondaire : « Se déconnecter ») |
| **Couleurs** | Fond `primary`, texte `onPrimary` (6,44:1) |
| **Texte** | `labelLarge`, avec un verbe d'action : « Se connecter », « Enregistrer », « Marquer comme fait » |
| **Taille** | Hauteur minimale de 48 dp, pleine largeur dans les formulaires |
| **Règles** | **Un seul bouton plein par écran**, celui de l'action principale. Le bouton flottant porte toujours un **libellé** (« Nouvelle tâche »), pas seulement une icône. |

### 4.2 Ligne de tâche *(variante B)*

| | |
|---|---|
| **Flutter** | `ListTile` dans un `ListView.builder`, avec des en-têtes de section intercalés |
| **Contenu** | `title` : titre de la tâche (`titleMedium`, `onSurface`). `subtitle` : nom du cours (`bodyMedium`, `onSurfaceVariant`). `trailing` : date relative (« Demain », « Lun. 23 ») et chevron. |
| **États** | **À faire** : affichage normal. **En retard** : la date passe en `error` et la tâche se place dans la section « En retard », dont l'en-tête utilise `error` / `onError`. **Faite** : titre barré et icône de validation en `primary`. **Sélectionnée** (tablette) : fond `secondaryContainer`. |
| **Taille** | Hauteur d'au moins 56 dp, toute la ligne est touchable |
| **En-tête de section** | Fond `surfaceContainerHighest`, texte `titleMedium` avec le nombre de tâches (« Cette semaine · 2 ») |

### 4.3 Champ de saisie

| | |
|---|---|
| **Flutter** | `TextFormField` dans un `Form`, `InputDecoration` avec `OutlineInputBorder` |
| **Couleurs** | Bordure `outline` (4,27:1). Au focus, bordure `primary`. En erreur, bordure et message en `error` (6,14:1). |
| **Texte** | Libellé toujours visible (« Titre (obligatoire) »), exemple dans le texte d'aide (« Ex. Rapport projet réseaux »), saisie en `bodyLarge` |
| **Validation** | Message clair sous le champ : « Le titre est obligatoire » (validator, séance 5) |
| **Règles** | Hauteur d'au moins 48 dp. Le formulaire défile pour rester utilisable quand le clavier est ouvert. |

---

## 5. Tailles de fenêtre visées

Les classes de largeur viennent du cours (séance 2, diapo 13).

| Classe | Largeur | Appareils | Structure de CampusFlow |
|---|---|---|---|
| **Compact** | < 600 dp | Téléphones, la cible principale (360×800 dp dans les wireframes) | Une colonne : liste **ou** détail. Barre de navigation inférieure. |
| **Moyen** | 600 – 839 dp | Petites tablettes, pliables | Même structure que compact, contenu plus large |
| **Étendu** | ≥ 840 dp | Tablettes, mode paysage | **Liste et détail côte à côte** ([wireframe tablette](wireframes/echeances-tablette.png)) |

Le **seuil de 840 dp** sera implémenté avec un `LayoutBuilder` (séance 5). Le rail de navigation latéral visible sur le wireframe tablette est une évolution possible : la version 1 garde la barre inférieure sur toutes les tailles.

---

## 6. Traduction prévue en Flutter (séance 4)

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), // palette du § 1
  // Roboto et l'échelle Material 3 sont les valeurs par défaut (§ 2)
  filledButtonTheme: ...,   // hauteur minimale 48 dp (§ 4.1)
  inputDecorationTheme: ..., // OutlineInputBorder, arrondi 12 (§ 4.3)
)
```

Dans les widgets, on lira toujours le thème, par exemple `Theme.of(context).colorScheme.error` ou `Theme.of(context).textTheme.titleMedium`, et jamais `Colors.green` ou `fontSize: 32`.
