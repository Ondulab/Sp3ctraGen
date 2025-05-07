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
    
    // Méthode de débogage pour vérifier l'état de l'image
    void debugImageState() {
        qDebug() << "PreviewImageProvider::debugImageState";
        qDebug() << "Image dimensions: " << m_image.width() << "x" << m_image.height();
        qDebug() << "Image format: " << m_image.format();
        qDebug() << "Image is null: " << m_image.isNull();
    }

private:
    QImage m_image;
};

#endif // PREVIEWIMAGEPROVIDER_H
