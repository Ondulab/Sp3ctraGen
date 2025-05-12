# Distribution de Sp3ctraGen sur macOS

Ce dossier contient la documentation et les scripts pour distribuer Sp3ctraGen sur macOS sans certificat de développeur Apple.

## Pourquoi mon application fonctionne sur mon Mac mais pas sur celui des autres ?

Sur votre machine de développement, macOS n'applique pas les mêmes restrictions qu'il impose aux applications téléchargées depuis Internet. Lorsque vous distribuez votre application :

1. L'attribut `com.apple.quarantine` est automatiquement ajouté aux fichiers téléchargés
2. Gatekeeper bloque alors l'exécution car l'application n'est pas signée
3. Les utilisateurs voient un message "l'application est endommagée et ne peut pas être ouverte"

## Comment distribuer Sp3ctraGen

### Méthode simple (DMG avec helper)

1. Exécutez le script de packaging complet :
   ```bash
   ./scripts/package.sh
   ```

2. Partagez le fichier `dist/Sp3ctraGen.dmg` avec vos utilisateurs

3. Les utilisateurs doivent :
   - Monter le DMG
   - Glisser l'application dans le dossier Applications
   - Exécuter le script `install_helper.command` inclus dans le DMG

### Uniquement créer le DMG

Si vous avez déjà compilé l'application, vous pouvez seulement créer le DMG :

```bash
./scripts/create_dmg.sh
```

## Documentation détaillée

- [Guide complet de distribution macOS](distribution_macos.md) - Explications techniques et alternatives
- [Exemple de formule Homebrew](homebrew_formula_example.rb) - Alternative pour la distribution via Homebrew

## Futures améliorations possibles

- Créer une formule Homebrew pour simplifier l'installation
- Ajouter une étape dans le script pour générer un beau design de DMG avec arrière-plan personnalisé
- Créer un assistant d'installation pkg au lieu du script helper