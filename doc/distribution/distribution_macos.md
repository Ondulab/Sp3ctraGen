# Guide de distribution pour Sp3ctraGen sur macOS

Ce document explique comment distribuer Sp3ctraGen en tant qu'application open-source sur macOS, et comment résoudre les problèmes liés à la sécurité de macOS (Gatekeeper).

## Problématique

macOS utilise un système de sécurité appelé "Gatekeeper" qui bloque l'exécution des applications téléchargées depuis Internet si elles ne sont pas signées avec un certificat de développeur Apple. Pour les projets open-source qui ne souhaitent pas payer pour un certificat Apple Developer, cela peut poser problème lors de la distribution.

**Symptômes :** Les utilisateurs voient un message du type "L'application est endommagée et ne peut pas être ouverte" ou "L'application provient d'un développeur non identifié".

## Solution implémentée

Nous avons créé un système de distribution qui :

1. Génère un fichier DMG contenant l'application
2. Inclut un script d'aide qui désactive automatiquement la quarantaine
3. Fournit des instructions claires pour les utilisateurs

Cette approche est couramment utilisée pour les logiciels open-source distribués en dehors de l'Apple App Store.

## Scripts de distribution

Trois scripts sont utilisés pour la distribution :

### 1. `scripts/build.sh`

Ce script :
- Compile l'application
- Déploie automatiquement les dépendances Qt dans le bundle (grâce à `macdeployqt`)
- Re-signe l'application pour assurer qu'elle s'exécute correctement

### 2. `scripts/create_dmg.sh`

Ce script crée un DMG contenant :
- L'application Sp3ctraGen.app (avec toutes ses dépendances)
- Un lien vers le dossier Applications
- Un script d'aide `install_helper.command`
- Un fichier README avec instructions

Utilisation :
```bash
./scripts/create_dmg.sh
```

### 2. `scripts/package.sh`

Ce script effectue le processus complet :
1. Compile l'application avec un nettoyage préalable
2. Crée le DMG pour distribution

Utilisation :
```bash
./scripts/package.sh
```

Le DMG final sera généré dans le dossier `dist/`.

## Instructions pour les utilisateurs finaux

Les utilisateurs qui téléchargent Sp3ctraGen devront :

1. Monter le DMG en double-cliquant dessus
2. Glisser l'application Sp3ctraGen dans le dossier Applications
3. Exécuter le script `install_helper.command` en double-cliquant dessus
4. Entrer leur mot de passe administrateur lorsque demandé

Le script d'aide supprime l'attribut de quarantaine, permettant à l'application de s'exécuter normalement.

## Comment ça fonctionne techniquement

1. Lorsqu'un fichier est téléchargé depuis Internet, macOS ajoute un attribut de métadonnées appelé `com.apple.quarantine`
2. Cet attribut signale à Gatekeeper de vérifier si l'application est signée lors de son exécution
3. Notre script d'aide supprime cet attribut avec la commande : 
   ```
   xattr -d com.apple.quarantine /Applications/Sp3ctraGen.app
   ```

Cette approche est sûre car l'utilisateur choisit explicitement d'exécuter le script d'aide et doit fournir son mot de passe.

## Alternatives

Si le projet devient plus important, vous pourriez envisager :

1. **Distribution via Homebrew** : Créer une formule pour le gestionnaire de paquets Homebrew
2. **Compte développeur Apple** : Obtenir un certificat de développeur (99€/an) pour signer et notariser l'application
3. **Financement communautaire** : Utiliser des dons pour financer le programme développeur Apple

## Ressources additionnelles

- [Documentation Apple sur la signature de code](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html)
- [Documentation Homebrew sur la création de formules](https://docs.brew.sh/Formula-Cookbook)