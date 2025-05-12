#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Script de réécriture de l'historique Git pour reformater les messages de commit
# Utilise git-filter-repo (https://github.com/newren/git-filter-repo)
# Généré par commit_translation.py

# ATTENTION: Ce script va réécrire l'historique Git.
# Assurez-vous d'avoir une sauvegarde ou un clone du dépôt avant de l'exécuter.

import sys
import re

# Vérification que git-filter-repo est installé
try:
    from git_filter_repo import FilteringOptions, RepoFilter
except ImportError:
    print("Erreur: git-filter-repo n'est pas installé ou n'est pas dans le PYTHONPATH.")
    print("Installation: pip install git-filter-repo")
    print("Ou téléchargez-le depuis https://github.com/newren/git-filter-repo")
    sys.exit(1)

# Dictionnaire de correspondance: ancien message -> nouveau message
commit_translations = {
    "Fix label and boxes alignment defauts": "fix(ui): fix label and boxes alignment issues",
    "Project renamed": "chore: rename project",
    "Save project before renaming": "chore: save project before renaming",
    "Add new qml structure": "feat(ui): add new QML structure",
    "feat(ui): improve vertical scale rendering in spectrogram display": "feat(ui): improve vertical scale rendering in spectrogram display",
    "Amélioration de l'affichage des paramètres dans le spectrogramme": "feat(ui): improve parameter display in spectrogram",
    "Ajout de règles pour ignorer les fichiers volumineux dans .gitignore": "chore: add rules to ignore large files in .gitignore",
    "Suppression du fichier volumineux .vscode/browse.vc.db et mise à jour du .gitignore": "chore: remove large file .vscode/browse.vc.db and update .gitignore",
    "Restructuration de la documentation et mise à jour des fichiers sources": "docs: restructure documentation and update source files",
    "feat: display original audio filename, start time and segment duration in parameters": "feat: display original audio filename, start time and segment duration in parameters",
    "Suppression du fichier volumineux du dépôt": "chore: remove large file from repository",
    "Mise à jour du générateur de prévisualisation et ajout de ressources": "feat: update preview generator and add resources",
    "Mise à jour de la documentation pour le bouton d'impression": "docs: update documentation for print button",
    "Ajout du bouton d'impression pour les spectrogrammes": "feat(ui): add print button for spectrograms",
    "Mise à jour des fichiers de code pour la refactorisation": "refactor: update code files for refactoring",
    "Refactorisation de la documentation et de l'architecture du projet": "refactor: restructure project documentation and architecture",
    "Refactorisation majeure du code pour améliorer la modularité et l'extensibilité: - Ajout de la classe SpectrogramSettingsCpp pour centraliser les paramètres - Création du fichier Constants.h pour centraliser les constantes - Implémentation du pattern Strategy pour les visualisations - Ajout de la classe FileManager pour la gestion des fichiers - Ajout de la classe TaskManager pour la gestion des tâches en arrière-plan - Mise à jour de la classe SpectrogramGenerator pour utiliser les nouvelles abstractions - Mise à jour du fichier main.cpp pour initialiser les nouvelles classes": "refactor(core): major code refactoring to improve modularity and extensibility",
    "Commit before clean": "chore: prepare for cleanup",
    "refactor: restructure project layout and file organization": "refactor: restructure project layout and file organization",
    "refactor: reorganize project structure for better maintainability": "refactor: reorganize project structure for better maintainability",
    "Update button animation": "feat(ui): update button animation",
    "Add gold theme": "feat(ui): add gold theme",
    "Mise à jour du fichier .gitignore pour ignorer des fichiers générés par Qt spécifiques": "chore: update .gitignore to ignore Qt-specific generated files",
    "Retrait des fichiers .DS_Store du suivi Git": "chore: remove .DS_Store files from Git tracking",
    "Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés": "chore: clean repository by removing generated and binary files",
    "Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés": "chore: clean repository by removing generated and binary files",
    "Ajout du fichier .gitignore au niveau du projet parent CISYNTH_App": "chore: add .gitignore at parent CISYNTH_App project level",
    "Mise à jour de la charte graphique et du fichier de ressources QML": "feat(ui): update graphic charter and QML resources file",
    "Ajout du fichier .gitignore, des fichiers de thème (Theme.qml, ExempleTheme.qml, qmldir), du dossier fonts et du README pour la charte graphique": "feat(ui): add .gitignore, theme files, fonts folder and README for graphic charter",
    "Delete ignored files": "chore: delete ignored files",
    "Add .gitignore": "chore: add .gitignore",
    "first commit": "chore: initial commit",
}

def message_callback(commit, metadata):
    # Récupération du message de commit original
    message = commit.message.decode('utf-8')
    # Récupération de la première ligne du message
    first_line = message.split('\n')[0]
    
    # Vérification si le message doit être remplacé
    if first_line in commit_translations:
        # Remplacement de la première ligne par le nouveau message
        new_message = message.replace(first_line, commit_translations[first_line], 1)
        commit.message = new_message.encode('utf-8')

# Exécution de git-filter-repo
rf = RepoFilter(message_callback=message_callback)
rf.run()

print("Terminé ! L'historique Git a été réécrit avec les messages reformatés.")
print("Utilisez 'git push --force' pour mettre à jour le dépôt distant (si nécessaire).")