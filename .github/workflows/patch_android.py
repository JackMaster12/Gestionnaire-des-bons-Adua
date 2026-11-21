#!/usr/bin/env python3
"""Prépare le projet Android généré par `flutter create` :
- ajoute le plugin Google Services (Firebase) ;
- fixe minSdk à 23.
À lancer depuis la racine du projet Flutter."""
import pathlib
import re
import sys

ANDROID = pathlib.Path("android")
GS_VERSION = "4.4.2"
ID_GS = "com.google.gms.google-services"


def echec(message):
    print("Error: " + message)
    sys.exit(1)


# 1) settings.gradle(.kts) : déclaration du plugin
fait = False
for nom in ("settings.gradle.kts", "settings.gradle"):
    p = ANDROID / nom
    if not p.exists():
        continue
    kts = nom.endswith(".kts")
    lignes = p.read_text(encoding="utf-8").split("\n")
    if any(ID_GS in l for l in lignes):
        fait = True
        break
    sortie = []
    for l in lignes:
        sortie.append(l)
        m = re.match(
            r'^(\s*)id\s*\(?\s*["\']com\.android\.application["\']\s*\)?\s*version', l)
        if m and not fait:
            ind = m.group(1)
            if kts:
                sortie.append(f'{ind}id("{ID_GS}") version "{GS_VERSION}" apply false')
            else:
                sortie.append(f'{ind}id "{ID_GS}" version "{GS_VERSION}" apply false')
            fait = True
    if fait:
        p.write_text("\n".join(sortie), encoding="utf-8")
    break
if not fait:
    echec("impossible d'ajouter le plugin Google Services dans settings.gradle")

# 2) app/build.gradle(.kts) : application du plugin + minSdk
fait = False
for nom in ("app/build.gradle.kts", "app/build.gradle"):
    p = ANDROID / nom
    if not p.exists():
        continue
    kts = nom.endswith(".kts")
    texte = p.read_text(encoding="utf-8")
    if ID_GS not in texte:
        sortie = []
        ajoute = False
        for l in texte.split("\n"):
            sortie.append(l)
            m = re.match(
                r'^(\s*)id\s*\(?\s*["\']com\.android\.application["\']\s*\)?\s*$', l)
            if m and not ajoute:
                ind = m.group(1)
                sortie.append(f'{ind}id("{ID_GS}")' if kts else f'{ind}id "{ID_GS}"')
                ajoute = True
        if not ajoute:
            echec("impossible d'appliquer le plugin Google Services dans app/build.gradle")
        texte = "\n".join(sortie)
    texte, n = re.subn(
        r'minSdk(?:Version)?\s*=?\s*(?:flutter\.minSdkVersion|\d+)', 'minSdk = 23', texte)
    if n == 0:
        echec("minSdk introuvable dans app/build.gradle")
    p.write_text(texte, encoding="utf-8")
    fait = True
    break
if not fait:
    echec("app/build.gradle introuvable")

print("Android prêt : plugin Google Services ajouté, minSdk = 23.")
