import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Écran de connexion, adresse /login (hors barre de navigation).
///
/// Il reprend l'écran de titre de la séance 4 (logo en asset, titre).
/// En séance 6, « Se connecter » mène simplement aux échéances ; les
/// champs e-mail / mot de passe et le jeton arrivent en séance 7.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              // Asset déclaré dans pubspec.yaml (séance 4).
              // semanticLabel : lu par le lecteur d'écran (accessibilité).
              Image.asset(
                'assets/images/logo.png',
                height: AppSizes.logo,
                semanticLabel: 'Logo CampusFlow',
              ),
              const SizedBox(height: AppSpacing.l),
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
                // go : on remplace la pile, le retour ne ramène pas ici.
                onPressed: () => context.go('/taches'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
