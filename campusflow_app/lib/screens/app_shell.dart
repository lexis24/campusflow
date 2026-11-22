import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille commune aux trois destinations (ShellRoute, séance 6) :
/// l'écran courant [child] au-dessus, la NavigationBar en dessous.
///
/// Pas de Scaffold ici : chaque écran a déjà le sien (AppBar, bouton
/// flottant). Un Scaffold dans un Scaffold est une erreur classique
/// (séance 5, diapo 8) ; une Column suffit.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  /// Adresse courante, pour savoir quelle destination surligner.
  final String location;

  /// Écran de la destination courante, fourni par go_router.
  final Widget child;

  /// Adresses des trois destinations, dans l'ordre de la barre.
  static const _destinations = ['/taches', '/cours', '/profil'];

  int get _selectedIndex {
    final index = _destinations.indexWhere(location.startsWith);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // La barre gère déjà la marge du bas (zone système) : on la retire
          // de l'écran pour ne pas la compter deux fois.
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        NavigationBar(
          selectedIndex: _selectedIndex,
          // go : on change de destination, on ne l'empile pas.
          onDestinationSelected: (index) => context.go(_destinations[index]),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Échéances',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Cours',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ],
    );
  }
}
