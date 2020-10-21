#ifndef AGORAPACKETOBSERVER_H
#define AGORAPACKETOBSERVER_H

#include <QObject>
#include "include/IAgoraMediaEngine.h"
#include <QDebug>
#include <QThread>
#include <QMutex>
#include <QMap>
#include <QImage>
#include <QVector>
#include <specstrings.h>
#include <winapifamily.h>
#include "libyuv.h"
#include "../AudioVideoUtils.h"

#undef FAR
#undef  NEAR
#define FAR                 far
#define NEAR                near
#ifndef CONST
#define CONST               const
#endif

typedef unsigned long       DWORD;
typedef int                 BOOL;
typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef float               FLOAT;
typedef FLOAT               *PFLOAT;
typedef BYTE  *LPBYTE;

typedef int                 INT;
typedef unsigned int        UINT;
typedef unsigned int        *PUINT;

using namespace agora::media;

class AgoraPacketObserver : public QObject, public IVideoFrameObserver
{
    Q_OBJECT
public:
    explicit AgoraPacketObserver(int width, int height);
    virtual bool onCaptureVideoFrame(VideoFrame &videoFrame);
    virtual bool onRenderVideoFrame(unsigned int uid, VideoFrame &videoFrame);
    QMutex m_mutex;
signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);

private:
    QVector<uchar> m_arr;
    QVector<uchar> m_arrTecent;

    LPBYTE				m_lpImageBuffer;
    LPBYTE				m_lpY;
    LPBYTE				m_lpU;
    LPBYTE				m_lpV;
    bool hasLoad = false;
    QImage testImage;

    LPBYTE m_lpBufferYUV;
    int m_nLenYUV;
    LPBYTE m_lpBufferYUVRotate;
    int m_nWidth,m_tWidth;
    int m_nHeight,m_tHeight;
    bool m_isHasInit = false;
};
#endif // AGORAPACKETOBSERVER_H
