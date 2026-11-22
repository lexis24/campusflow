import 'dart:convert';

import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session ouverte : le jeton délivré par /login et l'utilisateur connecté.
class Session {
  const Session({required this.jeton, required this.utilisateur});

  final String jeton;
  final User utilisateur;
}

/// Contrat de stockage de la session (séance 7).
/// Deux implémentations : chiffrée pour l'application, en mémoire pour les
/// tests (le stockage sécurisé dépend du système, absent en test).
abstract interface class SessionStorage {
  Future<Session?> lire();
  Future<void> ecrire(Session session);
  Future<void> effacer();
}

/// Stockage SÉCURISÉ : flutter_secure_storage chiffre les données avec le
/// Keystore d'Android (Keychain sur iOS). Le jeton n'est jamais écrit en
/// clair (pas de SharedPreferences ni de fichier texte).
class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage([this._stockage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _stockage;

  static const _cleJeton = 'jeton';
  static const _cleUtilisateur = 'utilisateur';

  @override
  Future<Session?> lire() async {
    final jeton = await _stockage.read(key: _cleJeton);
    final json = await _stockage.read(key: _cleUtilisateur);
    if (jeton == null || json == null) return null;
    return Session(
      jeton: jeton,
      utilisateur: User.fromJson(jsonDecode(json) as Map<String, dynamic>),
    );
  }

  @override
  Future<void> ecrire(Session session) async {
    await _stockage.write(key: _cleJeton, value: session.jeton);
    await _stockage.write(
      key: _cleUtilisateur,
      value: jsonEncode(session.utilisateur.toJson()),
    );
  }

  @override
  Future<void> effacer() async {
    await _stockage.delete(key: _cleJeton);
    await _stockage.delete(key: _cleUtilisateur);
  }
}

/// Stockage EN MÉMOIRE, pour les tests uniquement.
class MemorySessionStorage implements SessionStorage {
  MemorySessionStorage([this.session]);

  Session? session;

  @override
  Future<Session?> lire() async => session;

  @override
  Future<void> ecrire(Session nouvelle) async => session = nouvelle;

  @override
  Future<void> effacer() async => session = null;
}

/// Fournit le stockage de session (remplacé par la mémoire dans les tests).
final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => const SecureSessionStorage(),
);
