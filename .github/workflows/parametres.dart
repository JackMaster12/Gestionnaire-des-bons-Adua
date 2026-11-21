import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constantes.dart';
import '../modeles/profil.dart';
import '../services/appareil_service.dart';
import '../services/journal_service.dart';
import '../services/outils.dart';

class EcranParametres extends StatefulWidget {
  final ProfilUtilisateur profil;
  const EcranParametres({super.key, required this.profil});

  @override
  State<EcranParametres> createState() => _EtatParametres();
}

class _EtatParametres extends State<EcranParametres> {
  final _nom = TextEditingController();
  String _id = '';
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final id = await ServiceAppareil.id();
    var nom = '';
    try {
      final d = await FirebaseFirestore.instance
          .collection(colAppareils)
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 5));
      nom = (d.data()?['nom'] ?? '') as String;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _id = id;
      _nom.text = nom;
      _chargement = false;
    });
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  void _enregistrerNom() {
    final nom = _nom.text.trim();
    if (nom.isEmpty) {
      _message("Saisissez un nom pour l'appareil.");
      return;
    }
    final ref = FirebaseFirestore.instance.collection(colAppareils).doc(_id);
    lancer(() => ref.set(<String, dynamic>{
          'nom': nom,
          'majLe': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)));
    _message("Nom de l'appareil enregistré.");
  }

  void _changerExpediteur(bool devenir, String ancienId) {
    final db = FirebaseFirestore.instance;
    final lot = db.batch();
    final maintenant = FieldValue.serverTimestamp();
    if (devenir) {
      if (ancienId.isNotEmpty && ancienId != _id) {
        lot.set(
            db.collection(colAppareils).doc(ancienId),
            <String, dynamic>{'estExpediteurSms': false, 'majLe': maintenant},
            SetOptions(merge: true));
      }
      lot.set(
          db.collection(colAppareils).doc(_id),
          <String, dynamic>{'estExpediteurSms': true, 'majLe': maintenant},
          SetOptions(merge: true));
      lot.set(
          db.collection(colParametres).doc(docParametres),
          <String, dynamic>{'appareilExpediteurId': _id, 'majLe': maintenant},
          SetOptions(merge: true));
    } else {
      lot.set(
          db.collection(colAppareils).doc(_id),
          <String, dynamic>{'estExpediteurSms': false, 'majLe': maintenant},
          SetOptions(merge: true));
      lot.set(
          db.collection(colParametres).doc(docParametres),
          <String, dynamic>{'appareilExpediteurId': '', 'majLe': maintenant},
          SetOptions(merge: true));
    }
    lancer(() => lot.commit());
    Journal.ecrire(devenir ? 'expediteur_designe' : 'expediteur_retire',
        detail: _id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Cet appareil', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(
                  controller: _nom,
                  decoration: const InputDecoration(
                    labelText: "Nom de l'appareil",
                    helperText: 'Exemple : Téléphone caisse, Ordinateur bureau',
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: _enregistrerNom,
                    child: const Text('Enregistrer le nom'),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Identifiant : ${_id.substring(0, 8)}',
                    style: theme.textTheme.bodySmall),
                const Divider(height: 36),
                Text('Envoi des SMS', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(colParametres)
                      .doc(docParametres)
                      .snapshots(),
                  builder: (context, snap) {
                    final data = snap.data?.data() ?? <String, dynamic>{};
                    final expediteur =
                        (data['appareilExpediteurId'] ?? '') as String;
                    final moi = expediteur == _id && _id.isNotEmpty;
                    final texte = expediteur.isEmpty
                        ? 'Aucun appareil expéditeur désigné.'
                        : (moi
                            ? "Cet appareil est l'expéditeur (SIM 1 par défaut)."
                            : "Un autre appareil est l'expéditeur.");
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cet appareil envoie les SMS'),
                      subtitle: Text(widget.profil.estAdmin
                          ? texte
                          : "$texte\nSeul l'administrateur peut le modifier."),
                      value: moi,
                      onChanged: widget.profil.estAdmin
                          ? (v) => _changerExpediteur(v, expediteur)
                          : null,
                    );
                  },
                ),
                const Divider(height: 36),
                Text('À propos', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                const Text('Gestionnaire des bons ADUA'),
                Text('Version $versionAppli'),
              ],
            ),
    );
  }
}
