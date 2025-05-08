#ifndef PREVIEWIMAGEPROVIDER_H
#define PREVIEWIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QDebug>

class PreviewImageProvider : public QQuickImageProvider
{
public:
    PreviewImageProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    void updateImage(const QImage &image);
    
    // Méthode pour récupérer l'image originale à haute résolution
    QImage getOriginalImage() const { return m_originalImage; }
    
    // Méthode pour sauvegarder l'image originale dans un fichier
    bool saveOriginalImage(const QString &filePath, const QString &format = "png") const;
    
    // Méthode de débogage pour vérifier l'état de l'image
    void debugImageState() {
        qDebug() << "PreviewImageProvider::debugImageState";
        qDebug() << "Display image dimensions: " << m_displayImage.width() << "x" << m_displayImage.height();
        qDebug() << "Display image format: " << m_displayImage.format();
        qDebug() << "Display image is null: " << m_displayImage.isNull();
        qDebug() << "Original image dimensions: " << m_originalImage.width() << "x" << m_originalImage.height();
        qDebug() << "Original image is null: " << m_originalImage.isNull();
    }

private:
    QImage m_displayImage;  // Version redimensionnée pour l'affichage
    QImage m_originalImage; // Image originale à haute résolution
};

#endif // PREVIEWIMAGEPROVIDER_H
