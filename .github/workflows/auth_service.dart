import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../constantes.dart';
import 'journal_service.dart';

const Duration _delai = Duration(seconds: 20);

class ServiceAuth {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Future<void> seConnecter(String email, String motDePasse) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: motDePasse);
  }

  static Future<void> seDeconnecter() => _auth.signOut();

  /// Vrai si le compte administrateur a déjà été créé (lecture sur le serveur).
  static Future<bool> installationFaite() async {
    final d = await _db
        .collection(colEtat)
        .doc(docInstallation)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    return d.exists;
  }

  /// Première utilisation : crée le compte administrateur, marque
  /// l'installation comme faite et écrit les paramètres par défaut.
  static Future<void> creerAdministrateur({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: motDePasse);
    final user = cred.user!;
    try {
      final maintenant = FieldValue.serverTimestamp();
      await _db.collection(colUtilisateurs).doc(user.uid).set(<String, dynamic>{
        'email': email.trim(),
        'nom': nom.trim(),
        'role': roleAdmin,
        'actif': true,
        'creeLe': maintenant,
        'creePar': user.uid,
        'majLe': maintenant,
      }).timeout(_delai);
      await _db.collection(colEtat).doc(docInstallation).set(<String, dynamic>{
        'initialise': true,
        'creeLe': maintenant,
      }).timeout(_delai);
      await _db
          .collection(colParametres)
          .doc(docParametres)
          .set(parametresParDefaut())
          .timeout(_delai);
    } catch (e) {
      // Retour en arrière : on supprime le compte à moitié créé.
      try {
        await user.delete();
      } catch (_) {
        await _auth.signOut();
      }
      rethrow;
    }
  }

  /// Crée un compte secondaire sans déconnecter l'administrateur :
  /// on utilise une seconde instance de Firebase le temps de la création.
  static Future<void> creerCompteSecondaire({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    FirebaseApp autre;
    try {
      autre = Firebase.app('creation_compte');
    } catch (_) {
      autre = await Firebase.initializeApp(
        name: 'creation_compte',
        options: Firebase.app().options,
      );
    }
    try {
      final auth2 = FirebaseAuth.instanceFor(app: autre);
      final cred = await auth2.createUserWithEmailAndPassword(
          email: email.trim(), password: motDePasse);
      final uid = cred.user!.uid;
      await auth2.signOut();
      final moi = _auth.currentUser;
      final maintenant = FieldValue.serverTimestamp();
      await _db.collection(colUtilisateurs).doc(uid).set(<String, dynamic>{
        'email': email.trim(),
        'nom': nom.trim(),
        'role': roleSecondaire,
        'actif': true,
        'creeLe': maintenant,
        'creePar': moi?.uid ?? '',
        'majLe': maintenant,
      }).timeout(_delai);
      Journal.ecrire('utilisateur_cree', detail: email.trim());
    } finally {
      try {
        await autre.delete();
      } catch (_) {}
    }
  }
}
