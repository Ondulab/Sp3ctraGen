#include "../include/previewimageprovider.h"
#include <QFileInfo>
#include <QDir>
#include <QPainter>
#include <QPageLayout>
#include <QProcess>

// Forward declarations for QtPrintSupport classes
namespace QtPrintSupport {
    class QPrinter;
}

PreviewImageProvider::PreviewImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
    // Créer une image vide par défaut
    m_displayImage = QImage(800, 600, QImage::Format_ARGB32);
    m_displayImage.fill(Qt::transparent);
    m_originalImage = m_displayImage;
}

QImage PreviewImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug() << "PreviewImageProvider::requestImage - ID: " << id;
    qDebug() << "Display image: " << m_displayImage.width() << "x" << m_displayImage.height() << ", format: " << m_displayImage.format();
    qDebug() << "Display image is null: " << m_displayImage.isNull();
    qDebug() << "Original image: " << m_originalImage.width() << "x" << m_originalImage.height();
    qDebug() << "Original image is null: " << m_originalImage.isNull();
    
    // Sauvegarder l'image pour le débogage
    bool saved = m_displayImage.save("/tmp/preview_debug.png");
    qDebug() << "Display image saved for debug: " << saved;
    
    if (size) {
        *size = m_displayImage.size();
        qDebug() << "Size returned: " << size->width() << "x" << size->height();
    }
    
    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        qDebug() << "Requested size: " << requestedSize.width() << "x" << requestedSize.height();
        QImage scaledImage = m_displayImage.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        qDebug() << "Scaled image: " << scaledImage.width() << "x" << scaledImage.height();
        
        // Sauvegarder l'image redimensionnée pour le débogage
        bool scaledSaved = scaledImage.save("/tmp/preview_scaled_debug.png");
        qDebug() << "Scaled image saved for debug: " << scaledSaved;
        
        return scaledImage;
    }
    
    qDebug() << "Returning display image";
    return m_displayImage;
}

void PreviewImageProvider::updateImage(const QImage &image)
{
    qDebug() << "PreviewImageProvider::updateImage - Updating image";
    qDebug() << "Original image dimensions: " << image.width() << "x" << image.height();
    qDebug() << "Image format: " << image.format();
    
    if (image.isNull()) {
        qDebug() << "WARNING: Image is null!";
        return;
    }
    
    // Store the original high-resolution image
    m_originalImage = image;
    qDebug() << "Original high-resolution image stored: " << m_originalImage.width() << "x" << m_originalImage.height();
    
    // Create a resized version for display
    int maxWidth = 800;
    
    if (image.width() > maxWidth) {
        m_displayImage = image.scaled(maxWidth, 
                                     (maxWidth * image.height()) / image.width(), 
                                     Qt::KeepAspectRatio, 
                                     Qt::SmoothTransformation);
        qDebug() << "Display image resized to " << m_displayImage.width() << "x" << m_displayImage.height();
    } else {
        m_displayImage = image;
        qDebug() << "Image small enough, using as display image without resizing";
    }
    
    qDebug() << "Image updated successfully";
}

bool PreviewImageProvider::saveOriginalImage(const QString &filePath, const QString &format) const
{
    qDebug() << "PreviewImageProvider::saveOriginalImage - Saving to: " << filePath;
    
    if (m_originalImage.isNull()) {
        qDebug() << "ERROR: Cannot save null image";
        return false;
    }
    
    // Ensure the directory exists
    QFileInfo fileInfo(filePath);
    QDir dir = fileInfo.dir();
    if (!dir.exists()) {
        qDebug() << "Creating directory: " << dir.path();
        if (!dir.mkpath(".")) {
            qDebug() << "ERROR: Failed to create directory: " << dir.path();
            return false;
        }
    }
    
    bool success = false;
    
    // Gestion spéciale pour le format PDF
    if (format.toLower() == "pdf") {
        qDebug() << "Saving as PDF format";
        
        // Pour le format PDF, nous utilisons sips (outil intégré à macOS) pour convertir PNG en PDF
        // Créer d'abord un fichier PNG temporaire
        QString tempPngPath = filePath + ".temp.png";
        if (m_originalImage.save(tempPngPath, "PNG")) {
            qDebug() << "Temporary PNG saved successfully to: " << tempPngPath;
            
            // Utiliser sips pour convertir PNG en PDF
            QProcess process;
            QStringList arguments;
            arguments << "-s" << "format" << "pdf" << tempPngPath << "--out" << filePath;
            
            qDebug() << "Executing sips command: sips " << arguments.join(" ");
            process.start("sips", arguments);
            process.waitForFinished(-1); // Attendre indéfiniment que la commande se termine
            
            // Vérifier le résultat
            if (process.exitCode() == 0) {
                qDebug() << "PDF conversion successful: " << filePath;
                success = true;
            } else {
                QString errorOutput = process.readAllStandardError();
                qDebug() << "ERROR: sips command failed with exit code: " << process.exitCode();
                qDebug() << "Error output: " << errorOutput;
                success = false;
            }
            
            // Supprimer le fichier temporaire
            QFile::remove(tempPngPath);
            qDebug() << "Temporary PNG file removed";
        } else {
            qDebug() << "ERROR: Failed to save temporary PNG";
            success = false;
        }
    } else {
        // Pour les autres formats, utiliser la méthode standard
        success = m_originalImage.save(filePath, format.toUtf8().constData());
    }
    
    if (success) {
        qDebug() << "Original image saved successfully to: " << filePath;
        qDebug() << "Image dimensions: " << m_originalImage.width() << "x" << m_originalImage.height();
    } else {
        qDebug() << "ERROR: Failed to save image to: " << filePath;
    }
    
    return success;
}
