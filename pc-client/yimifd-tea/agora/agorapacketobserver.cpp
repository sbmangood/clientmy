#include "agorapacketobserver.h"
#include <QDebug>

AgoraPacketObserver::AgoraPacketObserver(QObject *parent) : QObject(parent)
{
}


bool AgoraPacketObserver::onCaptureVideoFrame(IVideoFrameObserver::VideoFrame &videoFrame)
{
    //  qDebug()<<"dfsfdsf";
    emit renderVideoFrame(0, videoFrame.width, videoFrame.height
                          , videoFrame.yStride, videoFrame.yBuffer
                          , videoFrame.uStride, videoFrame.uBuffer
                          , videoFrame.vStride, videoFrame.vBuffer);
    return true;
}

bool AgoraPacketObserver::onRenderVideoFrame(unsigned int uid, IVideoFrameObserver::VideoFrame &videoFrame)
{
//    qDebug() << "onRenderVideoFrame >> " << uid << videoFrame.width << videoFrame.height << videoFrame.yStride << videoFrame.uStride << videoFrame.vStride;
    emit renderVideoFrame(uid, videoFrame.width, videoFrame.height
                          , videoFrame.yStride, videoFrame.yBuffer
                          , videoFrame.uStride, videoFrame.uBuffer
                          , videoFrame.vStride, videoFrame.vBuffer);
    return true;
}
