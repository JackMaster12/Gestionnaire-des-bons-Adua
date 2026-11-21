import 'package:cloud_firestore/cloud_firestore.dart';

const String versionAppli = '0.1.0 (étape 2)';

const String colUtilisateurs = 'utilisateurs';
const String colAppareils = 'appareils';
const String colParametres = 'parametres';
const String docParametres = 'general';
const String colEtat = 'etat';
const String docInstallation = 'installation';
const String colJournal = 'journal';

const String roleAdmin = 'admin';
const String roleSecondaire = 'secondaire';

/// Paramètres créés à la première utilisation (modifiables ensuite).
Map<String, dynamic> parametresParDefaut() {
  return <String, dynamic>{
    'modeleSmsBon':
        'Dépôt pharmaceutique ADUA. Vous venez de prendre un bon de [montant] '
            'sur votre compte [nom] [rang].\n'
            'Montant avant le bon : [total_avant]\n'
            'Montant actuel à payer : [total_apres]\n'
            'Merci de votre fidélité',
    'modeleSmsVersement':
        'Dépôt pharmaceutique ADUA. Vous venez de verser [montant] '
            'sur votre compte [nom] [rang].\n'
            'Montant avant versement : [total_avant]\n'
            'Reste à payer : [total_apres]\n'
            'Merci de votre fidélité',
    'modeleRelance':
        'Dépôt pharmaceutique ADUA. Bonjour [nom], compte [rang]. '
            'Votre reste à payer est de [total], sans versement depuis [retard]. '
            'Merci de passer régler votre bon.',
    'toleranceJours': 90,
    'seuilMontant': 10000,
    'delaiMaxSmsHeures': 48,
    'heuresCalmesDebut': 22,
    'heuresCalmesFin': 7,
    'pauseSmsSecondes': 4,
    'simIndex': 1,
    'appareilExpediteurId': '',
    'relanceAutoActive': true,
    'relanceAutoHeure': 9,
    'relanceAutoIntervalleJours': 30,
    'majLe': FieldValue.serverTimestamp(),
  };
}
