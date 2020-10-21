#include "VideoRender.h"
#include <QCoreApplication>
#include "../../classroom-sdk/sdk/inc/controlcenter/controlcenter.h"

VideoRender::VideoRender(QQuickPaintedItem *parent): QQuickPaintedItem(parent), m_imageId(-1)
{
    connect(ControlCenter::getInstance(), SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SLOT(onRenderVideoFrameImage(unsigned int, QImage, int)));
    connect(ControlCenter::getInstance(), SIGNAL(hideBeautyButton()), this, SIGNAL(hideBeautyButton()));
}

VideoRender::~VideoRender()
{

}

void VideoRender::enableBeauty(bool isBeauty)
{
    ControlCenter::getInstance()->enableBeauty(isBeauty);
}

bool VideoRender::getBeautyIsOn()
{
    return ControlCenter::getInstance()->getBeautyIsOn();
}

// 处理视频图片
void VideoRender::onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation)
{
    if(m_imageId == uid)
    {
        image = image.copy(0, (image.height() - image.width() * 9 / 16) / 2, image.width(), image.width() * 9 / 16);// 截取图片为16：9
        m_imge = image.scaled(this->width(), this->height(), Qt::IgnoreAspectRatio);
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
