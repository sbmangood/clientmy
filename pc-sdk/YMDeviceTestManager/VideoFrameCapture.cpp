#include "videoframecapture.h"

VideoFrameCapture::VideoFrameCapture(): cam(NULL), ca(NULL)
{
    cam = new CameraCapture();
    connect(cam, SIGNAL(sendData(QImage)), this, SIGNAL(renderVideoFrame(QImage)));
    ca = new QCamera();
    ca->setCaptureMode(QCamera::CaptureStillImage);
    ca->setViewfinder(cam);
    ca->setCaptureMode(QCamera::CaptureVideo);
}

VideoFrameCapture::~VideoFrameCapture()
{
    if(NULL != cam)
    {
        delete cam;
        cam = NULL;
    }

    if(NULL != ca)
    {
        delete ca;
        ca = NULL;
    }
}

int VideoFrameCapture::startCapture()
{
    if(NULL != ca)
    {
        ca->start();
    }
    return 0;
}

int VideoFrameCapture::stopCapture()
{
    if(NULL != ca)
    {
        ca->stop();
    }
    return 0;
}

