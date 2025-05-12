#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script pour générer un script bash de réécriture de l'historique Git
en utilisant les conventions 'conventional commits'
"""

import os
import sys

# Dictionnaire de correspondance: ancien message -> nouveau message
commit_translations = {
    "7eafe35": {
        "original": "Fix label and boxes alignment defauts",
        "reformatted": "fix(ui): fix label and boxes alignment issues"
    },
    "4621d04": {
        "original": "Project renamed",
        "reformatted": "chore: rename project"
    },
    "d430eee": {
        "original": "Save project before renaming",
        "reformatted": "chore: save project before renaming"
    },
    "baa55b5": {
        "original": "Add new qml structure",
        "reformatted": "feat(ui): add new QML structure"
    },
    "be8478d": {
        "original": "feat(ui): improve vertical scale rendering in spectrogram display",
        "reformatted": "feat(ui): improve vertical scale rendering in spectrogram display"
    },
    "332152e": {
        "original": "Amélioration de l'affichage des paramètres dans le spectrogramme",
        "reformatted": "feat(ui): improve parameter display in spectrogram"
    },
    "c1bea25": {
        "original": "Ajout de règles pour ignorer les fichiers volumineux dans .gitignore",
        "reformatted": "chore: add rules to ignore large files in .gitignore"
    },
    "1b642ad": {
        "original": "Suppression du fichier volumineux .vscode/browse.vc.db et mise à jour du .gitignore",
        "reformatted": "chore: remove large file .vscode/browse.vc.db and update .gitignore"
    },
    "9e77591": {
        "original": "Restructuration de la documentation et mise à jour des fichiers sources",
        "reformatted": "docs: restructure documentation and update source files"
    },
    "e6795f2": {
        "original": "feat: display original audio filename, start time and segment duration in parameters",
        "reformatted": "feat: display original audio filename, start time and segment duration in parameters"
    },
    "dc6f7e8": {
        "original": "Suppression du fichier volumineux du dépôt",
        "reformatted": "chore: remove large file from repository"
    },
    "0e53278": {
        "original": "Mise à jour du générateur de prévisualisation et ajout de ressources",
        "reformatted": "feat: update preview generator and add resources"
    },
    "09cd104": {
        "original": "Mise à jour de la documentation pour le bouton d'impression",
        "reformatted": "docs: update documentation for print button"
    },
    "d6916fa": {
        "original": "Ajout du bouton d'impression pour les spectrogrammes",
        "reformatted": "feat(ui): add print button for spectrograms"
    },
    "93d872f": {
        "original": "Mise à jour des fichiers de code pour la refactorisation",
        "reformatted": "refactor: update code files for refactoring"
    },
    "2721113": {
        "original": "Refactorisation de la documentation et de l'architecture du projet",
        "reformatted": "refactor: restructure project documentation and architecture"
    },
    "9e72b91": {
        "original": "Refactorisation majeure du code pour améliorer la modularité et l'extensibilité: - Ajout de la classe SpectrogramSettingsCpp pour centraliser les paramètres - Création du fichier Constants.h pour centraliser les constantes - Implémentation du pattern Strategy pour les visualisations - Ajout de la classe FileManager pour la gestion des fichiers - Ajout de la classe TaskManager pour la gestion des tâches en arrière-plan - Mise à jour de la classe SpectrogramGenerator pour utiliser les nouvelles abstractions - Mise à jour du fichier main.cpp pour initialiser les nouvelles classes",
        "reformatted": "refactor(core): major code refactoring to improve modularity and extensibility"
    },
    "9c48df2": {
        "original": "Commit before clean",
        "reformatted": "chore: prepare for cleanup"
    },
    "a1aaf76": {
        "original": "refactor: restructure project layout and file organization",
        "reformatted": "refactor: restructure project layout and file organization"
    },
    "ee4017c": {
        "original": "refactor: reorganize project structure for better maintainability",
        "reformatted": "refactor: reorganize project structure for better maintainability"
    },
    "362f2a1": {
        "original": "Update button animation",
        "reformatted": "feat(ui): update button animation"
    },
    "beb7f14": {
        "original": "Add gold theme",
        "reformatted": "feat(ui): add gold theme"
    },
    "8c2c621": {
        "original": "Mise à jour du fichier .gitignore pour ignorer des fichiers générés par Qt spécifiques",
        "reformatted": "chore: update .gitignore to ignore Qt-specific generated files"
    },
    "5211d31": {
        "original": "Retrait des fichiers .DS_Store du suivi Git",
        "reformatted": "chore: remove .DS_Store files from Git tracking"
    },
    "d33a28e": {
        "original": "Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés",
        "reformatted": "chore: clean repository by removing generated and binary files"
    },
    "9a2dbe0": {
        "original": "Nettoyage du dépôt : retrait des fichiers générés et binaires qui devraient être ignorés",
        "reformatted": "chore: clean repository by removing generated and binary files"
    },
    "2c28b67": {
        "original": "Ajout du fichier .gitignore au niveau du projet parent CISYNTH_App",
        "reformatted": "chore: add .gitignore at parent CISYNTH_App project level"
    },
    "a6e5602": {
        "original": "Mise à jour de la charte graphique et du fichier de ressources QML",
        "reformatted": "feat(ui): update graphic charter and QML resources file"
    },
    "09a220c": {
        "original": "Ajout du fichier .gitignore, des fichiers de thème (Theme.qml, ExempleTheme.qml, qmldir), du dossier fonts et du README pour la charte graphique",
        "reformatted": "feat(ui): add .gitignore, theme files, fonts folder and README for graphic charter"
    },
    "a6b573e": {
        "original": "Delete ignored files",
        "reformatted": "chore: delete ignored files"
    },
    "3fb5e18": {
        "original": "Add .gitignore",
        "reformatted": "chore: add .gitignore"
    },
    "5df6b5c": {
        "original": "first commit",
        "reformatted": "chore: initial commit"
    }
}

# Génération du script filter-branch
def generate_filter_branch_script():
    script_lines = [
        "#!/bin/bash",
        "",
        "# Script de réécriture de l'historique Git pour reformater les messages de commit",
        "# Généré par commit_translation.py",
        "",
        "# ATTENTION: Ce script va réécrire l'historique Git.",
        "# Assurez-vous d'avoir une sauvegarde ou un clone du dépôt avant de l'exécuter.",
        "",
        "set -e",
        "",
        "# Fonction pour remplacer les messages de commit",
        "function filter_commit() {",
        "    local old_msg=\"$(cat $1)\"",
        "    local new_msg=\"$old_msg\"",
        "",
    ]
    
    # Ajout des règles de remplacement
    for commit_hash, data in commit_translations.items():
        old_msg = data["original"].replace('"', '\\"')
        new_msg = data["reformatted"].replace('"', '\\"')
        script_lines.append(f"    if [[ \"$old_msg\" == \"{old_msg}\" ]]; then")
        script_lines.append(f"        new_msg=\"{new_msg}\"")
        script_lines.append("    fi")
        script_lines.append("")
    
    script_lines.extend([
        "    echo \"$new_msg\" > $1",
        "}",
        "",
        "# Exécution de git filter-branch",
        "git filter-branch --force --msg-filter 'filter_commit \"$1\"' -- --all",
        "",
        "echo \"Terminé ! L'historique Git a été réécrit avec les messages reformatés.\"",
        "echo \"Utilisez 'git push --force' pour mettre à jour le dépôt distant (si nécessaire).\""
    ])
    
    return "\n".join(script_lines)

# Génération du script filter-repo
def generate_filter_repo_script():
    script_lines = [
        "#!/usr/bin/env python3",
        "# -*- coding: utf-8 -*-",
        "",
        "# Script de réécriture de l'historique Git pour reformater les messages de commit",
        "# Utilise git-filter-repo (https://github.com/newren/git-filter-repo)",
        "# Généré par commit_translation.py",
        "",
        "# ATTENTION: Ce script va réécrire l'historique Git.",
        "# Assurez-vous d'avoir une sauvegarde ou un clone du dépôt avant de l'exécuter.",
        "",
        "import sys",
        "import re",
        "",
        "# Vérification que git-filter-repo est installé",
        "try:",
        "    from git_filter_repo import FilteringOptions, RepoFilter",
        "except ImportError:",
        "    print(\"Erreur: git-filter-repo n'est pas installé ou n'est pas dans le PYTHONPATH.\")",
        "    print(\"Installation: pip install git-filter-repo\")",
        "    print(\"Ou téléchargez-le depuis https://github.com/newren/git-filter-repo\")",
        "    sys.exit(1)",
        "",
        "# Dictionnaire de correspondance: ancien message -> nouveau message",
        "commit_translations = {",
    ]
    
    # Ajout des règles de remplacement
    for commit_hash, data in commit_translations.items():
        old_msg = data["original"].replace('"', '\\"')
        new_msg = data["reformatted"].replace('"', '\\"')
        script_lines.append(f"    \"{old_msg}\": \"{new_msg}\",")
    
    script_lines.extend([
        "}",
        "",
        "def message_callback(commit, metadata):",
        "    # Récupération du message de commit original",
        "    message = commit.message.decode('utf-8')",
        "    # Récupération de la première ligne du message",
        "    first_line = message.split('\\n')[0]",
        "    ",
        "    # Vérification si le message doit être remplacé",
        "    if first_line in commit_translations:",
        "        # Remplacement de la première ligne par le nouveau message",
        "        new_message = message.replace(first_line, commit_translations[first_line], 1)",
        "        commit.message = new_message.encode('utf-8')",
        "",
        "# Exécution de git-filter-repo",
        "rf = RepoFilter(message_callback=message_callback)",
        "rf.run()",
        "",
        "print(\"Terminé ! L'historique Git a été réécrit avec les messages reformatés.\")",
        "print(\"Utilisez 'git push --force' pour mettre à jour le dépôt distant (si nécessaire).\")"
    ])
    
    return "\n".join(script_lines)

# Génération du tableau comparatif en format Markdown
def generate_markdown_table():
    markdown_lines = [
        "# Comparaison des messages de commit",
        "",
        "| Hash | Message original | Message reformaté |",
        "|------|-----------------|-------------------|"
    ]
    
    for commit_hash, data in commit_translations.items():
        markdown_lines.append(f"| {commit_hash} | {data['original']} | {data['reformatted']} |")
    
    return "\n".join(markdown_lines)

# Écriture des fichiers
with open("rewrite_with_filter_branch.sh", "w") as f:
    f.write(generate_filter_branch_script())
    os.chmod("rewrite_with_filter_branch.sh", 0o755)  # Rendre le script exécutable

with open("rewrite_with_filter_repo.py", "w") as f:
    f.write(generate_filter_repo_script())
    os.chmod("rewrite_with_filter_repo.py", 0o755)  # Rendre le script exécutable

with open("commit_comparison.md", "w") as f:
    f.write(generate_markdown_table())

print("Fichiers générés avec succès :")
print("1. rewrite_with_filter_branch.sh - Script utilisant git filter-branch (méthode intégrée)")
print("2. rewrite_with_filter_repo.py - Script utilisant git-filter-repo (nécessite installation)")
print("3. commit_comparison.md - Tableau comparatif des messages avant/après")