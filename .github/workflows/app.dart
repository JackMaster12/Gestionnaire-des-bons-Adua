import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'constantes.dart';
import 'ecrans/accueil.dart';
import 'ecrans/connexion.dart';
import 'modeles/profil.dart';
import 'services/auth_service.dart';

class BonsApp extends StatelessWidget {
  const BonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bons ADUA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F5C)),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const PorteAcces(),
    );
  }
}

/// Aiguille l'utilisateur : connexion, chargement du profil ou accueil.
class PorteAcces extends StatelessWidget {
  const PorteAcces({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const EcranChargement('Démarrage…');
        }
        final user = snap.data;
        if (user == null) return const EcranConnexion();
        return PorteProfil(user: user);
      },
    );
  }
}

class PorteProfil extends StatelessWidget {
  final User user;
  const PorteProfil({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(colUtilisateurs)
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return EcranMessage(
            titre: 'Accès impossible',
            texte: 'Impossible de lire votre profil.\n${snap.error}',
          );
        }
        final doc = snap.data;
        if (doc == null) return const EcranChargement('Chargement du profil…');
        if (!doc.exists) {
          if (doc.metadata.isFromCache) {
            return const EcranChargement('Chargement du profil…');
          }
          return const EcranMessage(
            titre: 'Compte non autorisé',
            texte:
                "Ce compte n'a pas de profil dans l'application. Contactez l'administrateur.",
          );
        }
        final profil = ProfilUtilisateur.depuisDoc(doc);
        if (!profil.actif) {
          return const EcranMessage(
            titre: 'Compte désactivé',
            texte:
                "Votre compte a été désactivé par l'administrateur. Vous n'avez plus accès aux données.",
          );
        }
        return EcranAccueil(profil: profil);
      },
    );
  }
}

class EcranChargement extends StatelessWidget {
  final String message;
  const EcranChargement(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class EcranMessage extends StatelessWidget {
  final String titre;
  final String texte;
  const EcranMessage({super.key, required this.titre, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 16),
                Text(titre,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(texte, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: ServiceAuth.seDeconnecter,
                  child: const Text('Se déconnecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
