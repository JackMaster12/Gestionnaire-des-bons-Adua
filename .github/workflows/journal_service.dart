import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../constantes.dart';
import 'appareil_service.dart';
import 'outils.dart';

/// Journal des actions : qui a fait quoi, quand, sur quel appareil.
class Journal {
  static void ecrire(String action, {String detail = ''}) {
    lancer(() async {
      final appareil = await ServiceAppareil.id();
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection(colJournal)
          .doc(const Uuid().v4())
          .set(<String, dynamic>{
        'action': action,
        'detail': detail,
        'par': user?.uid ?? '',
        'parEmail': user?.email ?? '',
        'appareilId': appareil,
        'le': FieldValue.serverTimestamp(),
        'majLe': FieldValue.serverTimestamp(),
      });
    });
  }
}
