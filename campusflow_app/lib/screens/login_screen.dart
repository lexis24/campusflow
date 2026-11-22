import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Écran de connexion, adresse /login (hors barre de navigation).
///
/// Reprend le logo (asset, séance 4) et le wireframe 01 (séance 2).
/// En cas de succès, le jeton est rangé dans le stockage sécurisé et le
/// routeur redirige tout seul vers /taches (il écoute la session).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  // États éphémères de l'écran : setState suffit.
  bool _masquer = true;
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      // ref.read dans une action : POST /login.
      await ref
          .read(authProvider.notifier)
          .connecter(_emailController.text.trim(), _motDePasseController.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Vrai si l'on arrive ici après un 401 (jeton refusé par le serveur).
    final expiree = ref.watch(sessionExpireeProvider);

    return Scaffold(
      body: SafeArea(
        // Défilant : le clavier ne bloque pas le bouton (séance 5).
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Asset déclaré dans pubspec.yaml (séance 4).
                Image.asset(
                  'assets/images/logo.png',
                  height: AppSizes.logo,
                  semanticLabel: 'Logo CampusFlow',
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'CampusFlow',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Tes cours, échéances et tâches au même endroit',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (expiree) ...[
                  Text(
                    'Ta session a expiré, reconnecte-toi.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: colors.error),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail étudiant',
                    hintText: 'prenom.nom@exemple.bf',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Saisis une adresse e-mail valide'
                      : null,
                ),
                const SizedBox(height: AppSpacing.m),
                TextFormField(
                  controller: _motDePasseController,
                  obscureText: _masquer,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    // « Afficher » du wireframe 01, avec un libellé (pas une
                    // simple icône) pour le lecteur d'écran.
                    suffixIcon: IconButton(
                      tooltip: _masquer ? 'Afficher' : 'Masquer',
                      icon: Icon(
                        _masquer ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _masquer = !_masquer),
                    ),
                  ),
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _connecter(),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Le mot de passe est obligatoire'
                      : null,
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    _erreur!,
                    style: textTheme.bodyMedium?.copyWith(color: colors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.l),
                FilledButton(
                  onPressed: _enCours ? null : _connecter,
                  child: Text(_enCours ? 'Connexion…' : 'Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
