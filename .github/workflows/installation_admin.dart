import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/outils.dart';

class EcranInstallationAdmin extends StatefulWidget {
  const EcranInstallationAdmin({super.key});

  @override
  State<EcranInstallationAdmin> createState() => _EtatInstallation();
}

class _EtatInstallation extends State<EcranInstallationAdmin> {
  final _cle = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _mdp = TextEditingController();
  final _mdp2 = TextEditingController();
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _mdp.dispose();
    _mdp2.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (!_cle.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await ServiceAuth.creerAdministrateur(
        nom: _nom.text,
        email: _email.text,
        motDePasse: _mdp.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreur(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Compte administrateur')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _cle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Ce compte aura tous les droits, dont la création des comptes secondaires. Notez bien le mot de passe : il ne pourra pas être récupéré sans Internet.",
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nom,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          const InputDecoration(labelText: 'Nom complet'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Saisissez votre nom'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Saisissez un email valide'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mdp,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Mot de passe (6 caractères minimum)'),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Au moins 6 caractères'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mdp2,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe'),
                      validator: (v) => v != _mdp.text
                          ? 'Les mots de passe sont différents'
                          : null,
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: 12),
                      Text(_erreur!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _enCours ? null : _creer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _enCours
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Créer le compte'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
