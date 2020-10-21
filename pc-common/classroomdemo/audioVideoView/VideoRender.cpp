#include "videorender.h"
#include "../YMAudioVideoManager/AudioVideoUtils.h"
#include "../controlcenter/controlcenter.h"

VideoRender::VideoRender(QQuickPaintedItem *parent): QQuickPaintedItem(parent), m_imageId(-1)
{
    connect(ControlCenter::getInstance(), SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SLOT(onRenderVideoFrameImage(unsigned int, QImage, int)));
}

VideoRender::~VideoRender(){}

void VideoRender::changeRenderWays(bool isBeauty)
{
    BeautyList::getInstance()->beautyIsOn = isBeauty;
    // 获取Qtyer.dll路径
    QString strDllFile = QCoreApplication::applicationDirPath();
    strDllFile += "\Qtyer.dll";
    if(QFile::exists(strDllFile))
    {
        QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);
        m_setting->beginGroup("Beauty");
        if(isBeauty)
        {
            m_setting->setValue("type",2);
        }
        else
        {
            m_setting->setValue("type",1);
        }
        m_setting->endGroup();
    }
}

bool VideoRender::getBeautyIsOn()
{
    // 获取Qtyer.dll路径
    QString strDllFile = QCoreApplication::applicationDirPath();
    strDllFile += "\Qtyer.dll";
    if(QFile::exists(strDllFile))
    {
        QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);
        m_setting->beginGroup("Beauty");
        if(m_setting->value("type").toInt() == 1)
        {
            return false;
        }
        m_setting->endGroup();
    }

    return true;
}

//处理视频图片
void VideoRender::onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation)
{
    //qDebug() << "===VideoRender::onRenderVideoFrameImage===" <<"uid="<<uid<<", image.size()="<<image.size()<< ", rotation="<<rotation<<"====";
    if(m_imageId == uid)
    {
        QMatrix leftmatrix;
        leftmatrix.rotate(rotation);
        QImage images =  image.transformed(leftmatrix);
        m_imge = images.scaled(this->width(),this->height(),Qt::KeepAspectRatioByExpanding);

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
