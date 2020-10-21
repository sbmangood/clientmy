#include "videorender.h"

VideoRender::VideoRender(QQuickPaintedItem *parent): QQuickPaintedItem(parent)
    , m_imageId(-1)
{
    OperationChannel::gestance();
    connect(OperationChannel::gestance(), SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SLOT(onRenderVideoFrameImage(unsigned int, QImage, int ) ) ) ;
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

VideoRender::~VideoRender()
{

}
//处理视频图片
void VideoRender::onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation)
{
    //qDebug() << "11111111" << m_imageId << uid;
    if(m_imageId == uid)
    {
        QMatrix leftmatrix;
        leftmatrix.rotate(rotation);
        QImage images =  image.transformed(leftmatrix);
        m_imge = images.scaled(this->width(), this->height(), Qt::KeepAspectRatioByExpanding);
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
    //  qDebug()<<"m_imageId ==="<<m_imageId;
}

QString VideoRender::imageId()
{
    return QString::number(m_imageId);
}
