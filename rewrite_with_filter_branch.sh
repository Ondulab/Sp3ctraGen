#!/bin/bash

# Script de réécriture de l'historique Git pour reformater les messages de commit
# Généré par commit_translation.py

# ATTENTION: Ce script va réécrire l'historique Git.
# Assurez-vous d'avoir une sauvegarde ou un clone du dépôt avant de l'exécuter.

set -e

# Fonction pour remplacer les messages de commit
function filter_commit() {
    local old_msg="$(cat $1)"
    local new_msg="$old_msg"

    if [[ "$old_msg" == "Fix label and boxes alignment defauts" ]]; then
        new_msg="fix(ui): fix label and boxes alignment issues"
    fi

    if [[ "$old_msg" == "Project renamed" ]]; then
        new_msg="chore: rename project"
    fi

    if [[ "$old_msg" == "Save project before renaming" ]]; then
        new_msg="chore: save project before renaming"
    fi

    if [[ "$old_msg" == "Add new qml structure" ]]; then
        new_msg="feat(ui): add new QML structure"
    fi

    if [[ "$old_msg" == "feat(ui): improve vertical scale rendering in spectrogram display" ]]; then
        new_msg="feat(ui): improve vertical scale rendering in spectrogram display"
    fi

    if [[ "$old_msg" == "Amélioration de l'affichage des paramètres dans le spectrogramme" ]]; then
        new_msg="feat(ui): improve parameter display in spectrogram"
    fi

    if [[ "$old_msg" == "Ajout de règles pour ignorer les fichiers volumineux dans .gitignore" ]]; then
        new_msg="chore: add rules to ignore large files in .gitignore"
    fi

    if [[ "$old_msg" == "Suppression du fichier volumineux .vscode/browse.vc.db et mise à jour du .gitignore" ]]; then
        new_msg="chore: remove large file .vscode/browse.vc.db and update .gitignore"
    fi

    if [[ "$old_msg" == "Restructuration de la documentation et mise à jour des fichiers sources" ]]; then
        new_msg="docs: restructure documentation and update source files"
    fi

    if [[ "$old_msg" == "feat: display original audio filename, start time and segment duration in parameters" ]]; then
        new_msg="feat: display original audio filename, start time and segment duration in parameters"
    fi

    if [[ "$old_msg" == "Suppression du fichier volumineux du dépôt" ]]; then
        new_msg="chore: remove large file from repository"
    fi

    if [[ "$old_msg" == "Mise à jour du générateur de prévisualisation et ajout de ressources" ]]; then
        new_msg="feat: update preview generator and add resources"
    fi

    if [[ "$old_msg" == "Mise à jour de la documentation pour le bouton d'impression" ]]; then
        new_msg="docs: update documentation for print button"
    fi

    if [[ "$old_msg" == "Ajout du bouton d'impression pour les spectrogrammes" ]]; then
        new_msg="feat(ui): add print button for spectrograms"
    fi

    if [[ "$old_msg" == "Mise à jour des fichiers de code pour la refactorisation" ]]; then
        new_msg="refactor: update code files for refactoring"
    fi

    if [[ "$old_msg" == "Refactorisation de la documentation et de l'architecture du projet" ]]; then
        new_msg="refactor: restructure project documentation and architecture"
    fi

    if [[ "$old_msg" == "Refactorisation majeure du code pour améliorer la modularité et l'extensibilité: - Ajout de la classe SpectrogramSettingsCpp pour centraliser les paramètres - Création du fichier Constants.h pour centraliser les constantes - Implémentation du pattern Strategy pour les visualisations - Ajout de la classe FileManager pour la gestion des fichiers - Ajout de la classe TaskManager pour la gestion des tâches en arrière-plan - Mise à jour de la classe SpectrogramGenerator pour utiliser les nouvelles abstractions - Mise à jour du fichier main.cpp pour initialiser les nouvelles classes" ]]; then
        new_msg="refactor(core): major code refactoring to improve modularity and extensibility"
    fi

    if [[ "$old_msg" == "Commit before clean" ]]; then
        new_msg="chore: prepare for cleanup"
    fi

    if [[ "$old_msg" == "refactor: restructure project layout and file organization" ]]; then
        new_msg="refactor: restructure project layout and file organization"
    fi

    if [[ "$old_msg" == "refactor: reorganize project structure for better maintainability" ]]; then
        new_msg="refactor: reorganize project structure for better maintainability"
    fi

    if [[ "$old_msg" == "Update button animation" ]]; then
        new_msg="feat(ui): update button animation"
    fi

    if [[ "$old_msg" == "Add gold theme" ]]; then
        new_msg="feat(ui): add gold theme"
    fi

    if [[ "$old_msg" == "Mise à jour du fichier .gitignore pour ignorer des fichiers générés par Qt spécifiques" ]]; then
        new_msg="chore: update .gitignore to ignore Qt-specific generated files"
    fi

    if [[ "$old_msg" == "Retrait des fichiers .DS_Store du suivi Git" ]]; then
        new_msg="chore: remove .DS_Store files from Git tracking"
    fi

    if [[ "$old_msg" == "Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés" ]]; then
        new_msg="chore: clean repository by removing generated and binary files"
    fi

    if [[ "$old_msg" == "Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés" ]]; then
        new_msg="chore: clean repository by removing generated and binary files"
    fi

    if [[ "$old_msg" == "Ajout du fichier .gitignore au niveau du projet parent CISYNTH_App" ]]; then
        new_msg="chore: add .gitignore at parent CISYNTH_App project level"
    fi

    if [[ "$old_msg" == "Mise à jour de la charte graphique et du fichier de ressources QML" ]]; then
        new_msg="feat(ui): update graphic charter and QML resources file"
    fi

    if [[ "$old_msg" == "Ajout du fichier .gitignore, des fichiers de thème (Theme.qml, ExempleTheme.qml, qmldir), du dossier fonts et du README pour la charte graphique" ]]; then
        new_msg="feat(ui): add .gitignore, theme files, fonts folder and README for graphic charter"
    fi

    if [[ "$old_msg" == "Delete ignored files" ]]; then
        new_msg="chore: delete ignored files"
    fi

    if [[ "$old_msg" == "Add .gitignore" ]]; then
        new_msg="chore: add .gitignore"
    fi

    if [[ "$old_msg" == "first commit" ]]; then
        new_msg="chore: initial commit"
    fi

    echo "$new_msg" > $1
}

# Exécution de git filter-branch
git filter-branch --force --msg-filter 'filter_commit "$1"' -- --all

echo "Terminé ! L'historique Git a été réécrit avec les messages reformatés."
echo "Utilisez 'git push --force' pour mettre à jour le dépôt distant (si nécessaire)."