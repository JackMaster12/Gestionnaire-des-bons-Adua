import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Lance une tâche sans attendre son résultat.
/// Sert aux écritures Firestore : hors ligne, elles restent en file
/// d'attente et partent à la prochaine connexion.
void lancer(Future<void> Function() tache) {
  unawaited(() async {
    try {
      await tache();
    } catch (_) {}
  }());
}

/// Transforme une erreur technique en message lisible en français.
String messageErreur(Object e) {
  if (e is TimeoutException) {
    return 'Le serveur ne répond pas. Vérifiez la connexion Internet puis réessayez.';
  }
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email ou mot de passe incorrect.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'network-request-failed':
        return 'Pas de connexion Internet.';
      case 'too-many-requests':
        return 'Trop de tentatives. Patientez quelques minutes.';
      case 'user-disabled':
        return 'Ce compte est désactivé.';
      case 'operation-not-allowed':
        return "La connexion par email et mot de passe n'est pas activée dans Firebase.";
    }
    return 'Erreur de connexion (${e.code}).';
  }
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return "Action refusée par les règles de sécurité. Vérifiez que les règles Firestore ont bien été publiées.";
      case 'unavailable':
        return 'Serveur inaccessible. Vérifiez la connexion Internet.';
    }
    return 'Erreur Firebase (${e.code}).';
  }
  return 'Erreur : $e';
}
