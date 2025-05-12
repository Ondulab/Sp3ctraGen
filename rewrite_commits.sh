#!/bin/bash

# Script de réécriture de l'historique Git pour reformater les messages de commit
# Version simplifiée utilisant des commandes sed directement

# ATTENTION: Ce script va réécrire l'historique Git.
# Assurez-vous d'avoir une sauvegarde ou un clone du dépôt avant de l'exécuter.

set -e

echo "Réécriture de l'historique Git en cours..."
echo "Cette opération peut prendre quelques minutes..."

# Squelcher l'avertissement de git filter-branch
export FILTER_BRANCH_SQUELCH_WARNING=1

# Français vers anglais et conventional commits
git filter-branch --force --msg-filter '
    sed -e "s/^Fix label and boxes alignment defauts$/fix(ui): fix label and boxes alignment issues/g" \
        -e "s/^Project renamed$/chore: rename project/g" \
        -e "s/^Save project before renaming$/chore: save project before renaming/g" \
        -e "s/^Add new qml structure$/feat(ui): add new QML structure/g" \
        -e "s/^Amélioration de l'\''affichage des paramètres dans le spectrogramme$/feat(ui): improve parameter display in spectrogram/g" \
        -e "s/^Ajout de règles pour ignorer les fichiers volumineux dans .gitignore$/chore: add rules to ignore large files in .gitignore/g" \
        -e "s/^Suppression du fichier volumineux .vscode\/browse.vc.db et mise à jour du .gitignore$/chore: remove large file .vscode\/browse.vc.db and update .gitignore/g" \
        -e "s/^Restructuration de la documentation et mise à jour des fichiers sources$/docs: restructure documentation and update source files/g" \
        -e "s/^Suppression du fichier volumineux du dépôt$/chore: remove large file from repository/g" \
        -e "s/^Mise à jour du générateur de prévisualisation et ajout de ressources$/feat: update preview generator and add resources/g" \
        -e "s/^Mise à jour de la documentation pour le bouton d'\''impression$/docs: update documentation for print button/g" \
        -e "s/^Ajout du bouton d'\''impression pour les spectrogrammes$/feat(ui): add print button for spectrograms/g" \
        -e "s/^Mise à jour des fichiers de code pour la refactorisation$/refactor: update code files for refactoring/g" \
        -e "s/^Refactorisation de la documentation et de l'\''architecture du projet$/refactor: restructure project documentation and architecture/g" \
        -e "s/^Refactorisation majeure du code pour améliorer la modularité et l'\''extensibilité: .*$/refactor(core): major code refactoring to improve modularity and extensibility/g" \
        -e "s/^Commit before clean$/chore: prepare for cleanup/g" \
        -e "s/^Update button animation$/feat(ui): update button animation/g" \
        -e "s/^Add gold theme$/feat(ui): add gold theme/g" \
        -e "s/^Mise à jour du fichier .gitignore pour ignorer des fichiers générés par Qt spécifiques$/chore: update .gitignore to ignore Qt-specific generated files/g" \
        -e "s/^Retrait des fichiers .DS_Store du suivi Git$/chore: remove .DS_Store files from Git tracking/g" \
        -e "s/^Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés$/chore: clean repository by removing generated and binary files/g" \
        -e "s/^Ajout du fichier .gitignore au niveau du projet parent CISYNTH_App$/chore: add .gitignore at parent CISYNTH_App project level/g" \
        -e "s/^Mise à jour de la charte graphique et du fichier de ressources QML$/feat(ui): update graphic charter and QML resources file/g" \
        -e "s/^Ajout du fichier .gitignore, des fichiers de thème (Theme.qml, ExempleTheme.qml, qmldir), du dossier fonts et du README pour la charte graphique$/feat(ui): add .gitignore, theme files, fonts folder and README for graphic charter/g" \
        -e "s/^Delete ignored files$/chore: delete ignored files/g" \
        -e "s/^Add .gitignore$/chore: add .gitignore/g" \
        -e "s/^first commit$/chore: initial commit/g"
' -- --all

echo "Terminé ! L'historique Git a été réécrit avec les messages reformatés."
echo "Utilisez 'git push --force' pour mettre à jour le dépôt distant (si nécessaire)."