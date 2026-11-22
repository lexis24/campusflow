import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Charge les noms de mois et de jours français utilisés par intl
  // (DateFormat dans utils/dates.dart) avant d'afficher le premier écran.
  await initializeDateFormatting('fr');
  // ProviderScope : le conteneur qui stocke l'état de tous les fournisseurs
  // Riverpod. Il enveloppe toute l'application (séance 6).
  runApp(const ProviderScope(child: CampusFlowApp()));
}

class CampusFlowApp extends StatefulWidget {
  const CampusFlowApp({super.key, this.initialLocation = '/login'});

  /// Adresse de départ ; les tests peuvent ouvrir n'importe quel écran.
  final String initialLocation;

  @override
  State<CampusFlowApp> createState() => _CampusFlowAppState();
}

class _CampusFlowAppState extends State<CampusFlowApp> {
  // Le routeur est créé une seule fois, puis conservé (go_router garde
  // l'historique de navigation).
  late final GoRouter _router = createRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router : la navigation est confiée à go_router.
    return MaterialApp.router(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      // Thème centralisé du design system (lib/theme/app_theme.dart).
      theme: AppTheme.light(),
      // Calendrier, boutons "Annuler"/"OK"... en français.
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
