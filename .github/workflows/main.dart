import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? erreur;
  try {
    await Firebase.initializeApp();
    // Cache hors ligne activé : l'application reste utilisable sans Internet.
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  } catch (e) {
    erreur = e.toString();
  }
  runApp(erreur == null ? const BonsApp() : ErreurDemarrage(erreur));
}

class ErreurDemarrage extends StatelessWidget {
  final String message;
  const ErreurDemarrage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              "Impossible de démarrer l'application.\n\n$message",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
