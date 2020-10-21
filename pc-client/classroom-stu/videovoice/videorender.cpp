#include "videorender.h"

VideoRender::VideoRender(QQuickPaintedItem *parent): QQuickPaintedItem(parent), m_imageId(-1)
{
    connect(AudioVideoManager::getInstance(), SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SLOT(onRenderVideoFrameImage(unsigned int, QImage, int ) ) ) ;
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

VideoRender::~VideoRender()
{

}
//处理视频图片
void VideoRender::onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation)
{
    //   qDebug()<<" VideoRender::onRenderVideoFrameImage =="<<uid;

//    if(uid != 0)
//    {
//        qDebug()<<"VideoRender::onRenderVideoFrameImage" << uid << m_imageId << __LINE__;
//    }

    if(m_imageId == uid)
    {
        QMatrix leftmatrix;
        leftmatrix.rotate(rotation );
        QImage images = image.transformed(leftmatrix);
        m_imge = images.scaled(this->width(), this->height(), Qt::KeepAspectRatioByExpanding);
        update();
    }
}

void VideoRender::paint(QPainter *painter)
{
    //    painter->setRenderHint(QPainter::Antialiasing);
    //    QPixmap pixmap = QPixmap::fromImage(m_imge );
    //    painter->drawPixmap(QRect(0,0,this->width(),this->height() ),pixmap);
    if(m_imageId != -1)
    {
        //painter->setRenderHint(QPainter::Antialiasing);
        //    QPixmap pixmap = QPixmap::fromImage(m_imge );
        //  painter->drawImage(QRect(0,0,this->width(),this->height() ),m_imge); //this->height() / 2 - m_imge.height() / 2
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
