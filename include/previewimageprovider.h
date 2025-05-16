/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#ifndef PREVIEWIMAGEPROVIDER_H
#define PREVIEWIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QDebug>
#include <QObject>
#include "SharedConstants.h"

class PreviewImageProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
    Q_PROPERTY(double dpi READ getDpi WRITE setDpi NOTIFY dpiChanged)

public:
    PreviewImageProvider();
    
    // Valeur par défaut pour la résolution
    static constexpr double DEFAULT_DPI = 400.0;
    
    // Méthodes pour obtenir et définir le DPI
    double getDpi() const { return m_dpi; }
    void setDpi(double dpi) {
        if (m_dpi != dpi) {
            m_dpi = dpi;
            emit dpiChanged(dpi);
        }
    }
    
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    void updateImage(const QImage &image);
    
    // Method to retrieve the original high-resolution image
    QImage getOriginalImage() const { return m_originalImage; }
    
    // Method to save the original image to a file
    bool saveOriginalImage(const QString &filePath, const QString &format = "png") const;
    
    // Method to print the original image in high resolution
    Q_INVOKABLE bool printImage() const;
    
    // Methods to get image dimensions and resolution information
    Q_INVOKABLE int getImageWidth() const { return m_originalImage.width(); }
    Q_INVOKABLE int getImageHeight() const { return m_originalImage.height(); }
    Q_INVOKABLE double getImageDPI() const { return m_dpi; }
    
    // Get physical dimensions in millimeters
    Q_INVOKABLE double getImageWidthMM() const {
        return m_originalImage.width() / (m_dpi / 25.4);
    }
    Q_INVOKABLE double getImageHeightMM() const {
        return m_originalImage.height() / (m_dpi / 25.4);
    }
    
    // Get physical dimensions in centimeters
    Q_INVOKABLE double getImageWidthCM() const { 
        return getImageWidthMM() / 10.0; 
    }
    Q_INVOKABLE double getImageHeightCM() const { 
        return getImageHeightMM() / 10.0; 
    }
    
    // Debug method to check the image state
    void debugImageState() {
        qDebug() << "PreviewImageProvider::debugImageState";
        qDebug() << "Display image dimensions: " << m_displayImage.width() << "x" << m_displayImage.height();
        qDebug() << "Display image format: " << m_displayImage.format();
        qDebug() << "Display image is null: " << m_displayImage.isNull();
        qDebug() << "Original image dimensions: " << m_originalImage.width() << "x" << m_originalImage.height();
        qDebug() << "Original image is null: " << m_originalImage.isNull();
    }

signals:
    void dpiChanged(double dpi);

private:
    QImage m_displayImage;  // Resized version for display
    QImage m_originalImage; // Original high-resolution image
    double m_dpi = DEFAULT_DPI; // DPI value
};

#endif // PREVIEWIMAGEPROVIDER_H
