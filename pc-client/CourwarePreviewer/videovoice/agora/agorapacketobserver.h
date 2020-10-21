#ifndef AGORAPACKETOBSERVER_H
#define AGORAPACKETOBSERVER_H
#include <QObject>
#include <IAgoraMediaEngine.h>
#include <QDebug>
#include <QThread>
#include <QMap>
#include <QImage>
#include <QVector>


using namespace agora::media;

class AgoraPacketObserver : public QObject, public IVideoFrameObserver
{
        Q_OBJECT
    public:
        explicit AgoraPacketObserver(QObject *parent = 0);
        virtual bool onCaptureVideoFrame(VideoFrame &videoFrame);
        virtual bool onRenderVideoFrame(unsigned int uid, VideoFrame &videoFrame);

        void setInitStartClass(bool status);


    signals:
        void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);

    private:
        QVector<uchar> m_arr;
        QVector<uchar> m_arrTecent;
        bool m_isInitStartClass;
};

#endif // AGORAPACKETOBSERVER_H
