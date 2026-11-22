import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/app_shell.dart';
import 'screens/cours_screen.dart';
import 'screens/echeances_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/task_form_screen.dart';

/// Crée le routeur de CampusFlow : une adresse par écran (séance 6).
///
/// | Chemin            | Écran          | Niveau                     |
/// |-------------------|----------------|----------------------------|
/// | /login            | Connexion      | hors barre de navigation   |
/// | /taches           | Échéances      | destination 1 (ShellRoute) |
/// | /taches/nouvelle  | Formulaire     | écran secondaire           |
/// | /taches/:id       | Détail         | écran secondaire           |
/// | /cours            | Cours          | destination 2 (ShellRoute) |
/// | /profil           | Profil         | destination 3 (ShellRoute) |
///
/// Une fonction (et non une variable globale) : chaque test peut créer
/// son propre routeur, en partant de n'importe quelle adresse.
///
/// Connexion (séance 7) : [estConnecte] et [enChargement] décrivent la
/// session ; [rafraichir] prévient le routeur quand elle change (connexion,
/// déconnexion, 401), pour qu'il réapplique la règle de redirection.
GoRouter createRouter({
  String initialLocation = '/login',
  bool Function()? estConnecte,
  bool Function()? enChargement,
  Listenable? rafraichir,
}) {
  // Navigateur racine : les écrans secondaires s'y affichent, par-dessus
  // la coquille, donc en plein écran et sans la barre de navigation.
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    refreshListenable: rafraichir,
    // Consultée à chaque navigation : pas de session → /login.
    redirect: (_, state) {
      // Session encore en cours de lecture dans le stockage : on attend.
      if (estConnecte == null || (enChargement?.call() ?? false)) return null;
      final connecte = estConnecte();
      final versLogin = state.matchedLocation == '/login';
      if (!connecte && !versLogin) return '/login';
      if (connecte && versLogin) return '/taches';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

      // ShellRoute : la NavigationBar entoure les trois destinations.
      ShellRoute(
        builder: (_, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/taches',
            builder: (_, _) => const EcheancesScreen(),
            routes: [
              // « nouvelle » AVANT « :id », sinon « nouvelle » serait lu
              // comme un identifiant de tâche (cours, séance 6, diapo 6).
              GoRoute(
                path: 'nouvelle',
                parentNavigatorKey: rootKey,
                // fullscreenDialog : bouton × « Fermer » (wireframe 04).
                pageBuilder: (_, _) => const MaterialPage(
                  fullscreenDialog: true,
                  child: TaskFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootKey,
                // Lecture du paramètre de chemin :id.
                builder: (_, state) =>
                    TaskDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/cours', builder: (_, _) => const CoursScreen()),
          GoRoute(path: '/profil', builder: (_, _) => const ProfilScreen()),
        ],
      ),
    ],
  );
}
