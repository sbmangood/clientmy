#ifndef AGORAPACKETOBSERVER_H
#define AGORAPACKETOBSERVER_H
#include <QObject>
#include <IAgoraMediaEngine.h>

using namespace agora::media;

class AgoraPacketObserver : public QObject, public IVideoFrameObserver
{
        Q_OBJECT
    public:
        explicit AgoraPacketObserver(QObject *parent = 0);
        virtual bool onCaptureVideoFrame(VideoFrame &videoFrame);
        virtual bool onRenderVideoFrame(unsigned int uid, VideoFrame &videoFrame);

    signals:
        void renderVideoFrame(unsigned int uid, int w, int h, int y, void *yb, int u, void *ub, int v, void *vb);

};

#endif // AGORAPACKETOBSERVER_H
