import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constantes.dart';
import 'outils.dart';

/// Identité de cet appareil (créée une fois à la première ouverture).
class ServiceAppareil {
  static String? _id;

  static Future<String> id() async {
    final deja = _id;
    if (deja != null) return deja;
    final prefs = await SharedPreferences.getInstance();
    var v = prefs.getString('appareil_id');
    if (v == null) {
      v = const Uuid().v4();
      await prefs.setString('appareil_id', v);
    }
    _id = v;
    return v;
  }

  /// Déclare l'appareil dans Firestore et met à jour sa dernière activité.
  static Future<void> enregistrer() async {
    try {
      final id = await ServiceAppareil.id();
      final prefs = await SharedPreferences.getInstance();
      final dejaEnregistre = prefs.getBool('appareil_enregistre') ?? false;
      final donnees = <String, dynamic>{
        'plateforme': 'android',
        'versionAppli': versionAppli,
        'derniereSynchro': FieldValue.serverTimestamp(),
        'majLe': FieldValue.serverTimestamp(),
      };
      if (!dejaEnregistre) {
        donnees['nom'] = 'Appareil ${id.substring(0, 4)}';
        donnees['estExpediteurSms'] = false;
        await prefs.setBool('appareil_enregistre', true);
      }
      final ref = FirebaseFirestore.instance.collection(colAppareils).doc(id);
      lancer(() => ref.set(donnees, SetOptions(merge: true)));
    } catch (_) {}
  }
}
