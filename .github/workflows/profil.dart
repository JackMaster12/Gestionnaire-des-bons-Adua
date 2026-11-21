import 'package:cloud_firestore/cloud_firestore.dart';

import '../constantes.dart';

class ProfilUtilisateur {
  final String uid;
  final String email;
  final String nom;
  final String role;
  final bool actif;

  const ProfilUtilisateur({
    required this.uid,
    required this.email,
    required this.nom,
    required this.role,
    required this.actif,
  });

  bool get estAdmin => role == roleAdmin;

  factory ProfilUtilisateur.depuisDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return ProfilUtilisateur(
      uid: doc.id,
      email: (d['email'] ?? '') as String,
      nom: (d['nom'] ?? '') as String,
      role: (d['role'] ?? roleSecondaire) as String,
      actif: (d['actif'] ?? false) as bool,
    );
  }
}
