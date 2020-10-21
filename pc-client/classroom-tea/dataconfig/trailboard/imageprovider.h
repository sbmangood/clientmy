#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H
#include<QImage>
#include<QPixmap>
#include<QQuickImageProvider>

class ImageProvider : public QQuickImageProvider
{
    public:
        ImageProvider(): QQuickImageProvider(QQuickImageProvider::Image)
        {
        }

        QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize)
        {
            return this->image;
        }
    public:
        QImage image;
};

#endif // IMAGEPROVIDER_H
