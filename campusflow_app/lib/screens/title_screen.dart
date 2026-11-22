import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Écran de titre affiché au lancement de l'application (séance 4).
///
/// Toutes les couleurs et tailles viennent du thème : aucune valeur en dur.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  void _start(BuildContext context) {
    // pushReplacement : on ne revient pas sur l'écran de titre avec « retour ».
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'CampusFlow',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Tes cours, échéances et tâches au même endroit',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _start(context),
                child: const Text('Commencer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
