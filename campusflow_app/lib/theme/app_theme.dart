import 'package:flutter/material.dart';

/// Thème de CampusFlow, traduction du design system v1
/// (docs/seance2/design-system-v1.md).
///
/// Règle : aucun widget n'écrit de couleur ou de taille en dur ; tout est lu
/// ici, ou via Theme.of(context).

/// Espacements du design system (§ 3).
abstract final class AppSpacing {
  /// Très petit : entre deux lignes d'information.
  static const double xs = 4;

  /// Petit : entre une icône et son texte, entre deux puces.
  static const double s = 8;

  /// Intermédiaire : sous un titre dans une carte.
  static const double sm = 12;

  /// Moyen : marges latérales des écrans, entre deux champs.
  static const double m = 16;

  /// Grand : avant le bouton principal d'un formulaire.
  static const double l = 24;

  /// Très grand : séparation forte (avant la description).
  static const double xl = 32;
}

/// Tailles fixes de l'interface (design system § 3 et § 5).
abstract final class AppSizes {
  /// Cible tactile minimale (Material : 48 × 48 dp).
  static const double minTouchTarget = 48;

  /// Arrondi des cartes et des champs.
  static const double radius = 12;

  /// Seuil « étendu » : liste et détail côte à côte (séance 5).
  static const double tabletBreakpoint = 840;

  /// Largeur de la liste quand le détail est affiché à côté.
  static const double masterPaneWidth = 380;

  /// Épaisseur d'un séparateur fin.
  static const double hairline = 1;

  /// Rayon de l'avatar du profil.
  static const double avatarRadius = 40;

  /// Taille des petites icônes d'information (écran Détail).
  static const double infoIcon = 20;
}

abstract final class AppTheme {
  /// Couleur de départ du design system : indigo #3F51B5 (§ 1).
  /// Flutter en dérive toute la palette Material 3, dont les contrastes
  /// ont été vérifiés (≥ 4,5:1 pour le texte).
  static const Color seed = Colors.indigo;

  /// Thème clair, le seul de la version 1.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    final rounded = BorderRadius.circular(AppSizes.radius);
    // Hauteur minimale de 48 dp pour tous les boutons (§ 4.1).
    const buttonMinSize = Size(64, AppSizes.minTouchTarget);

    return ThemeData(
      colorScheme: scheme,
      // Typographie : Roboto et l'échelle Material 3 sont les valeurs par
      // défaut de Flutter sur Android (§ 2), donc rien à redéfinir.

      // Bouton principal (§ 4.1).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonMinSize),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: buttonMinSize),
      ),

      // Champ de saisie (§ 4.3) : bordure arrondie sur tous les champs.
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(borderRadius: rounded),
      ),

      // Cartes : même arrondi que les champs.
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: rounded),
      ),

      // Ligne de tâche (§ 4.2) : ligne sélectionnée sur tablette.
      listTileTheme: ListTileThemeData(
        selectedTileColor: scheme.secondaryContainer,
        selectedColor: scheme.onSecondaryContainer,
      ),
    );
  }
}
