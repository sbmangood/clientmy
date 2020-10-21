#ifndef LITEAVVIDEORENDERCALLBACK_H
#define LITEAVVIDEORENDERCALLBACK_H

#include <QObject>
#include <QImage>
#include "include/TXLiteAVBase.h"
#include "include/TXLiteAVCode.h"
#include "include/ITXLiteAVNetworkProxy.h"
#include "include/TRTC/ITRTCCloud.h"
#include "include/TRTC/TRTCCloudCallback.h"
#include "include/TRTC/TRTCCloudDef.h"
#include "include/TRTC/TRTCStatistics.h"

class LiteAVVideoRenderCallback : public QObject, public ITRTCVideoRenderCallback
{
    Q_OBJECT

public:
    explicit LiteAVVideoRenderCallback(QObject *parent = 0);

    virtual void onRenderVideoFrame(const char* userId, TRTCVideoStreamType streamType, TRTCVideoFrame* frame) override;

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);

public slots:
};

#endif // LITEAVVIDEORENDERCALLBACK_H
