import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// État « erreur » d'un écran asynchrone (séance 7) : un message clair et
/// un bouton Réessayer qui relance le chargement.
class ErreurReessayer extends StatelessWidget {
  const ErreurReessayer({
    super.key,
    required this.message,
    required this.onReessayer,
  });

  /// Message en français (ApiException.message).
  final String message;

  /// Relance le chargement, en pratique ref.invalidate(fournisseur).
  final VoidCallback onReessayer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: AppSizes.logo / 2, color: colors.error),
            const SizedBox(height: AppSpacing.m),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton.icon(
              onPressed: onReessayer,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
