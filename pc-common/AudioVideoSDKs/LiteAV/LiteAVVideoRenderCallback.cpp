#include "LiteAVVideoRenderCallback.h"
#include <QDebug>
#include <QFile>

LiteAVVideoRenderCallback::LiteAVVideoRenderCallback(QObject *parent) : QObject(parent)
{

}

void LiteAVVideoRenderCallback::onRenderVideoFrame(const char *userId, TRTCVideoStreamType streamType, TRTCVideoFrame *frame)
{
    // 通过宽度和高度的比例, 判断图像是否需要旋转, 正常情况下是宽度大于高度, 如果高度大于宽度的时候就旋转
    int iRotation = 0;
    int iRate = frame->width / frame->height;
    if(iRate >= 1)
    {
        iRotation = 0;
    }
    else
    {
        iRotation = 90;
    }
    QImage image((uchar*)frame->data, frame->width, frame->height, QImage::Format_ARGB32);

    emit renderVideoFrameImage(QString(userId).toInt(), image, iRotation);
}
