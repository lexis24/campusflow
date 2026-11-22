import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/taches_provider.dart';
import '../theme/app_theme.dart';

/// Écran Profil, adresse /profil (destination 3 de la NavigationBar).
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(utilisateurProvider);
    final taches = ref.watch(tachesProvider);
    final faites = taches.where((t) => t.done).length;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: AppSizes.avatarRadius,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(user.name, style: textTheme.titleLarge),
              Text(user.email),
              const SizedBox(height: AppSpacing.l),
              Text('$faites / ${taches.length} tâches terminées'),
              const SizedBox(height: AppSpacing.l),
              // Action secondaire : OutlinedButton (design system § 4.1).
              OutlinedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
