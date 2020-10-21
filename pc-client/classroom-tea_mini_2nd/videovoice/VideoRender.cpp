﻿#include "VideoRender.h"
#include <QCoreApplication>
#include "AudioVideoCenter.h"

VideoRender::VideoRender(QQuickPaintedItem *parent): QQuickPaintedItem(parent), m_imageId(-1)
{
    connect(AudioVideoCenter::getInstance(), SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SLOT(onRenderVideoFrameImage(unsigned int, QImage, int)));
    connect(AudioVideoCenter::getInstance(), SIGNAL(hideBeautyButton()), this, SIGNAL(hideBeautyButton()));
}

VideoRender::~VideoRender()
{

}

void VideoRender::enableBeauty(bool isBeauty)
{
    AudioVideoCenter::getInstance()->enableBeauty(isBeauty);
}

bool VideoRender::getBeautyIsOn()
{
    return AudioVideoCenter::getInstance()->getBeautyIsOn();
}

// 处理视频图片
void VideoRender::onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation)
{
    if(m_imageId == uid)
    {
        m_imge = image.scaled(this->width(), this->height(), Qt::KeepAspectRatioByExpanding);
        update();
    }
}

void VideoRender::paint(QPainter *painter)
{
    if(m_imageId != -1)
    {
        painter->setRenderHint(QPainter::Antialiasing);
        painter->drawImage(-(m_imge.width() - this->width()) / 2, (m_imge.height() - this->height()) / 2, m_imge);
    }
}

void VideoRender::setImageId(QString &imageId)
{
    m_imageId = imageId.toInt();
}

QString VideoRender::imageId()
{
    return QString::number(m_imageId);
}
