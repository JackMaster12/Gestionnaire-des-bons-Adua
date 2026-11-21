import 'package:flutter/material.dart';

import '../modeles/profil.dart';
import '../services/appareil_service.dart';
import '../services/auth_service.dart';
import 'comptes.dart';
import 'parametres.dart';

class EcranAccueil extends StatefulWidget {
  final ProfilUtilisateur profil;
  const EcranAccueil({super.key, required this.profil});

  @override
  State<EcranAccueil> createState() => _EtatAccueil();
}

class _EtatAccueil extends State<EcranAccueil> {
  @override
  void initState() {
    super.initState();
    ServiceAppareil.enregistrer();
  }

  void _bientot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Disponible à l'étape 3 (clients et bons).")),
    );
  }

  void _menu(String valeur) {
    switch (valeur) {
      case 'parametres':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => EcranParametres(profil: widget.profil)));
        break;
      case 'comptes':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => EcranComptes(profil: widget.profil)));
        break;
      case 'deconnexion':
        ServiceAuth.seDeconnecter();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profil = widget.profil;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bons ADUA'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _menu,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'parametres', child: Text('Paramètres')),
              if (profil.estAdmin)
                const PopupMenuItem(
                    value: 'comptes', child: Text('Comptes utilisateurs')),
              const PopupMenuItem(
                  value: 'deconnexion', child: Text('Se déconnecter')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Bonjour ${profil.nom}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profil.estAdmin ? 'Administrateur' : 'Compte secondaire'),
          const SizedBox(height: 20),
          Text('Tableau de bord', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 92,
            ),
            children: const [
              _CarteStat(titre: 'Total dû'),
              _CarteStat(titre: 'Hors tolérance'),
              _CarteStat(titre: 'Comptes bloqués'),
              _CarteStat(titre: 'SMS en attente'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Commandes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 84,
            ),
            children: [
              _BoutonAccueil(
                  icone: Icons.tag, titre: 'Recherche par rang', onTap: _bientot),
              _BoutonAccueil(
                  icone: Icons.person_search,
                  titre: 'Recherche par nom',
                  onTap: _bientot),
              _BoutonAccueil(
                  icone: Icons.phone,
                  titre: 'Recherche par téléphone',
                  onTap: _bientot),
              _BoutonAccueil(
                  icone: Icons.person_add,
                  titre: 'Nouveau client',
                  onTap: _bientot),
              _BoutonAccueil(
                  icone: Icons.schedule,
                  titre: 'Clients en retard',
                  onTap: _bientot),
              _BoutonAccueil(
                  icone: Icons.payments,
                  titre: 'Montants élevés',
                  onTap: _bientot),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                  "Étape 2 : connexion, comptes et droits en place. Les clients, les bons et les SMS arrivent aux étapes suivantes."),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteStat extends StatelessWidget {
  final String titre;
  const _CarteStat({required this.titre});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(titre, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text('—',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _BoutonAccueil extends StatelessWidget {
  final IconData icone;
  final String titre;
  final VoidCallback onTap;
  const _BoutonAccueil(
      {required this.icone, required this.titre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(titre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
