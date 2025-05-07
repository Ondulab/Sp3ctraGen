#include "../include/previewimageprovider.h"

PreviewImageProvider::PreviewImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
    // Créer une image vide par défaut
    m_image = QImage(800, 600, QImage::Format_ARGB32);
    m_image.fill(Qt::transparent);
}

QImage PreviewImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug() << "PreviewImageProvider::requestImage - ID: " << id;
    qDebug() << "Image actuelle: " << m_image.width() << "x" << m_image.height() << ", format: " << m_image.format();
    qDebug() << "Image est nulle: " << m_image.isNull();
    
    // Sauvegarder l'image pour le débogage
    bool saved = m_image.save("/tmp/preview_debug.png");
    qDebug() << "Image sauvegardée pour débogage: " << saved;
    
    if (size) {
        *size = m_image.size();
        qDebug() << "Taille retournée: " << size->width() << "x" << size->height();
    }
    
    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        qDebug() << "Taille demandée: " << requestedSize.width() << "x" << requestedSize.height();
        QImage scaledImage = m_image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        qDebug() << "Image redimensionnée: " << scaledImage.width() << "x" << scaledImage.height();
        
        // Sauvegarder l'image redimensionnée pour le débogage
        bool scaledSaved = scaledImage.save("/tmp/preview_scaled_debug.png");
        qDebug() << "Image redimensionnée sauvegardée pour débogage: " << scaledSaved;
        
        return scaledImage;
    }
    
    qDebug() << "Retour de l'image originale";
    return m_image;
}

void PreviewImageProvider::updateImage(const QImage &image)
{
    qDebug() << "PreviewImageProvider::updateImage - Mise à jour de l'image";
    qDebug() << "Dimensions de l'image originale: " << image.width() << "x" << image.height();
    qDebug() << "Format de l'image: " << image.format();
    
    if (image.isNull()) {
        qDebug() << "ATTENTION: L'image est nulle!";
        return;
    }
    
    // Redimensionner l'image à une taille plus raisonnable pour l'affichage
    // Limiter la largeur à 800 pixels tout en conservant le ratio d'aspect
    int maxWidth = 800;
    QImage resizedImage;
    
    if (image.width() > maxWidth) {
        resizedImage = image.scaled(maxWidth, 
                                   (maxWidth * image.height()) / image.width(), 
                                   Qt::KeepAspectRatio, 
                                   Qt::SmoothTransformation);
        qDebug() << "Image redimensionnée à " << resizedImage.width() << "x" << resizedImage.height();
    } else {
        resizedImage = image;
    }
    
    m_image = resizedImage;
    
    qDebug() << "Image mise à jour avec succès";
}
