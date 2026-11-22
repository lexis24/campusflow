import 'package:flutter/foundation.dart';

/// Adresse de l'API json-server (séance 7).
///
/// Sur l'émulateur Android, « localhost » désigne l'émulateur lui-même :
/// l'ordinateur qui fait tourner json-server s'appelle 10.0.2.2.
/// Sur les autres plateformes (Windows, web), localhost convient.
String get apiBaseUrl {
  const port = 3000;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:$port';
  }
  return 'http://localhost:$port';
}
