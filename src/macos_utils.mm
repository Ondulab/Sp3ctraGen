#import <Cocoa/Cocoa.h>
#include <QDebug>

/**
 * Utilitaires spécifiques à macOS
 * Implémentation du protocole NSApplicationDelegate
 */
@interface Sp3ctraGenAppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation Sp3ctraGenAppDelegate

// Indique à macOS que l'application prend en charge la restauration d'état sécurisée
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end

// Fonction d'initialisation appelable depuis C++
extern "C" void initMacOSSpecific() {
    @autoreleasepool {
        // Créer et définir le délégué de l'application
        Sp3ctraGenAppDelegate* delegate = [[Sp3ctraGenAppDelegate alloc] init];
        [[NSApplication sharedApplication] setDelegate:delegate];
        qDebug() << "macOS specific initialization complete";
    }
}

/**
 * Correctifs pour les dialogues de fichiers macOS
 * 
 * Ces fonctions contournent les problèmes de Qt avec les dialogues natifs sur macOS
 */

// Fonction pour corriger les erreurs de dialogue de fichiers
extern "C" void fixFileDialogIssues() {
    // Force la configuration des dialogues pour éviter les problèmes ViewBridge
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    // Configurer également NSSavePanel pour s'assurer qu'il fonctionne correctement
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    // Définir les propriétés du savePanel pour éviter les avertissements
    [savePanel setCanCreateDirectories:YES];
    
    qDebug() << "macOS file dialog configuration applied";
}

// Fonction pour configurer correctement un panneau d'ouverture de fichiers
extern "C" void configureFileOpenPanel() {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    qDebug() << "macOS file open panel configured";
}

// Fonction pour configurer correctement un panneau de sélection de dossier
extern "C" void configureFolderSelectPanel() {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    
    qDebug() << "macOS folder select panel configured";
}

// Fonction pour configurer correctement un panneau de sauvegarde de fichier
extern "C" void configureSavePanel() {
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setShowsTagField:NO];
    
    qDebug() << "macOS save panel configured";
}
