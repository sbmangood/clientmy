#ifndef VIDEOFRAMECAPTURE_H
#define VIDEOFRAMECAPTURE_H
#include "CameraCapture.h"
#include <QCamera>
#include <QObject>

class VideoFrameCapture : public QObject
{
    Q_OBJECT
public:
    explicit VideoFrameCapture();
    virtual ~VideoFrameCapture();

    int startCapture();
    int stopCapture();

private:
    CameraCapture *cam;
    QCamera *ca;

signals:
    void renderVideoFrame(QImage image);
};

#endif // VIDEOFRAMECAPTURE_H
