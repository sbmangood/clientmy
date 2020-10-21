#ifndef CAMERACAPTURE_H
#define CAMERACAPTURE_H

#include <QObject>
#include <QAbstractVideoSurface>

class CameraCapture : public QAbstractVideoSurface
{
    Q_OBJECT
public:
    explicit CameraCapture(QObject *parent = 0);
    QList<QVideoFrame::PixelFormat> supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const override;
    void setVideoFrame(const QVideoFrame &frame);

private slots:
    bool present(const QVideoFrame &frame) override;
signals:
    void sendData(QImage image);

public slots:
private:

private:
    QImage m_image;
    QVector<uchar> arr;
};

#endif // CAMERACAPTURE_H
