import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/outils.dart';
import 'installation_admin.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EtatConnexion();
}

class _EtatConnexion extends State<EcranConnexion> {
  final _cle = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _mdp = TextEditingController();
  bool _enCours = false;
  bool _masque = true;
  bool _premiereUtilisation = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _verifierInstallation();
  }

  @override
  void dispose() {
    _email.dispose();
    _mdp.dispose();
    super.dispose();
  }

  Future<void> _verifierInstallation() async {
    try {
      final faite = await ServiceAuth.installationFaite();
      if (mounted) setState(() => _premiereUtilisation = !faite);
    } catch (_) {
      // Pas d'Internet ou règles non publiées : on n'affiche pas le bouton.
    }
  }

  Future<void> _connecter() async {
    if (!_cle.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await ServiceAuth.seConnecter(_email.text, _mdp.text);
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
                    Icon(Icons.local_pharmacy,
                        size: 72, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Gestionnaire des bons',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Dépôt Pharmaceutique ADUA',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 28),
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
                      obscureText: _masque,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(_masque
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() => _masque = !_masque),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Saisissez le mot de passe'
                          : null,
                      onFieldSubmitted: (_) => _connecter(),
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: 12),
                      Text(_erreur!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _enCours ? null : _connecter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _enCours
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Se connecter'),
                      ),
                    ),
                    if (_premiereUtilisation) ...[
                      const SizedBox(height: 32),
                      Card(
                        color: theme.colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Première utilisation',
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 6),
                              const Text(
                                  "Aucun compte n'existe encore. Créez le compte administrateur."),
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const EcranInstallationAdmin(),
                                  ),
                                ),
                                child: const Text(
                                    'Créer le compte administrateur'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
