import 'package:flutter/material.dart';

import '../core/api_exception.dart';

/// Exécute une action réseau (POST, PATCH, DELETE) et informe l'utilisateur
/// par un SnackBar : [succes] si elle réussit, le message d'erreur sinon.
/// Renvoie true si l'action a réussi.
Future<bool> executerAction(
  BuildContext context,
  Future<void> Function() action, {
  String? succes,
}) async {
  // Récupéré AVANT l'attente : après un await, le context peut ne plus être
  // valide (écran fermé entre-temps).
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (succes != null) {
      messenger.showSnackBar(SnackBar(content: Text(succes)));
    }
    return true;
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return false;
  }
}

/// Demande confirmation avant une suppression, action irréversible
/// (séance 5 : « Dialog pour confirmer une suppression »).
Future<bool> confirmerSuppression(BuildContext context, String titre) async {
  final confirme = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer la tâche ?'),
      content: Text('« $titre » sera définitivement supprimée.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return confirme ?? false;
}
