import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constantes.dart';
import '../modeles/profil.dart';
import '../services/auth_service.dart';
import '../services/journal_service.dart';
import '../services/outils.dart';

class EcranComptes extends StatefulWidget {
  final ProfilUtilisateur profil;
  const EcranComptes({super.key, required this.profil});

  @override
  State<EcranComptes> createState() => _EtatComptes();
}

class _EtatComptes extends State<EcranComptes> {
  bool _enCours = false;

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _ajouter() async {
    final res = await showDialog<_NouveauCompte>(
      context: context,
      builder: (_) => const _DialogueNouveauCompte(),
    );
    if (res == null) return;
    setState(() => _enCours = true);
    try {
      await ServiceAuth.creerCompteSecondaire(
        nom: res.nom,
        email: res.email,
        motDePasse: res.mdp,
      );
      if (mounted) _message('Compte créé pour ${res.nom}.');
    } catch (e) {
      if (mounted) _message(messageErreur(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  void _changerEtat(QueryDocumentSnapshot<Map<String, dynamic>> doc, bool actif) {
    final email = (doc.data()['email'] ?? '') as String;
    lancer(() => doc.reference.update(<String, dynamic>{
          'actif': actif,
          'majLe': FieldValue.serverTimestamp(),
        }));
    Journal.ecrire(actif ? 'utilisateur_active' : 'utilisateur_desactive',
        detail: email);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.profil.estAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comptes utilisateurs')),
        body: const Center(
            child: Text("Réservé à l'administrateur.")),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Comptes utilisateurs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _enCours ? null : _ajouter,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter un compte'),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(colUtilisateurs)
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text(messageErreur(snap.error!)));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = [...snap.data!.docs];
              docs.sort((a, b) => (a.data()['nom'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b.data()['nom'] ?? '').toString().toLowerCase()));
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final d = doc.data();
                  final estMoi = doc.id == widget.profil.uid;
                  final role = (d['role'] ?? '') as String;
                  final actif = (d['actif'] ?? false) as bool;
                  return ListTile(
                    leading: Icon(role == roleAdmin
                        ? Icons.admin_panel_settings
                        : Icons.person),
                    title: Text('${d['nom'] ?? ''}${estMoi ? ' (vous)' : ''}'),
                    subtitle: Text(
                        '${d['email'] ?? ''}\n${role == roleAdmin ? 'Administrateur' : 'Secondaire'} — ${actif ? 'actif' : 'désactivé'}'),
                    isThreeLine: true,
                    trailing: Switch(
                      value: actif,
                      onChanged: estMoi ? null : (v) => _changerEtat(doc, v),
                    ),
                  );
                },
              );
            },
          ),
          if (_enCours)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _NouveauCompte {
  final String nom;
  final String email;
  final String mdp;
  const _NouveauCompte(this.nom, this.email, this.mdp);
}

class _DialogueNouveauCompte extends StatefulWidget {
  const _DialogueNouveauCompte();

  @override
  State<_DialogueNouveauCompte> createState() => _EtatDialogue();
}

class _EtatDialogue extends State<_DialogueNouveauCompte> {
  final _cle = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _mdp = TextEditingController();

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _mdp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau compte secondaire'),
      content: Form(
        key: _cle,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nom,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Saisissez un nom' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Email invalide'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mdp,
                decoration: const InputDecoration(
                    labelText: 'Mot de passe (6 caractères minimum)'),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Au moins 6 caractères' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (!_cle.currentState!.validate()) return;
            Navigator.of(context).pop(_NouveauCompte(
                _nom.text.trim(), _email.text.trim(), _mdp.text));
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
