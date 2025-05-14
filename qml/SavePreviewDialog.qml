import QtQuick 2.15
import QtQuick.Dialogs 1.3

/**
 * Dialogue de sauvegarde personnalisé pour les spectrogrammes
 * 
 * Ce dialogue étend les fonctionnalités du FileDialog standard
 * pour permettre une meilleure réutilisation.
 */
FileDialog {
    id: saveDialog
    title: "Enregistrer la prévisualisation"
    selectExisting: false
    
    // Pour garantir que le dialogue est complètement fermé quand annulé
    onRejected: {
        console.log("Save dialog rejected")
        saveDialog.destroy()
    }
}
