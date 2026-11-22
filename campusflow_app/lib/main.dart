import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/title_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Charge les noms de mois et de jours français utilisés par intl
  // (DateFormat dans utils/dates.dart) avant d'afficher le premier écran.
  await initializeDateFormatting('fr');
  // ProviderScope : le conteneur qui stocke l'état de tous les fournisseurs
  // Riverpod. Il enveloppe toute l'application (séance 6).
  runApp(const ProviderScope(child: CampusFlowApp()));
}

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      // Thème centralisé du design system (lib/theme/app_theme.dart).
      theme: AppTheme.light(),
      // Calendrier, boutons "Annuler"/"OK"... en français.
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const TitleScreen(),
    );
  }
}
