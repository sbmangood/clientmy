#include "videorender.h"

VideoRender::VideoRender(QQuickPaintedItem *parent): QQuickPaintedItem(parent), m_imageId(-1)
{
    connect(AudioVideoManager::getInstance(), SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SLOT(onRenderVideoFrameImage(unsigned int, QImage, int ) ) ) ;
    beautyManager = new BeautyManager();
    connect(beautyManager,SIGNAL(hideBeautyButton()),this,SIGNAL(hideBeautyButton()));
}

VideoRender::~VideoRender(){}


void VideoRender::changeRenderWays(bool isBeauty)
{
    BeautyList::getInstance()->beautyIsOn = isBeauty;
    QString strDllFile = StudentData::gestance()->strAppFullPath;
    strDllFile = strDllFile.replace(StudentData::gestance()->strAppName, "Qtyer.dll"); //得到dll文件的绝对路径
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
    beautyManager->checkHideBeautyButton();
    QString strDllFile = StudentData::gestance()->strAppFullPath;
    strDllFile = strDllFile.replace(StudentData::gestance()->strAppName, "Qtyer.dll"); //得到dll文件的绝对路径
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
        //美颜代码
        if(BeautyList::getInstance()->beautyIsOn && uid == 0)
        {
            QImage beautyImage;
            beautyImage.load(QString::number(uid));
            if(beautyImage.isNull())
            {
                return;
            }
            QMatrix leftmatrix;
            leftmatrix.rotate( rotation );
            beautyImage =  beautyImage.transformed(leftmatrix);

            beautyImage = beautyImage.scaled(1280,720, Qt::KeepAspectRatioByExpanding);
            m_imge = QImage(beautyManager->beautyImage(beautyImage.bits()),1280,720, QImage::Format_RGB32).scaled(this->width(),this->height(), Qt::KeepAspectRatioByExpanding);
            BeautyList::getInstance()->hasBeautyImageList.append(m_imge);
            //==================================
            //将美颜后的图片, 保存到本地, 如果图片大小, 小于500字节, 说明美颜失败了, 就不美颜了
            static bool bOnlyOnce = false;
            if(!bOnlyOnce)
            {
                bOnlyOnce = true;
                QString strName = QString("./aaa.png");
                m_imge.save(strName, 0);
                QFile files(strName);
                qDebug()<<"VideoRender::onRenderVideoFrameImage1212" << beautyImage.byteCount() << m_imge.size() << m_imge.byteCount() << files.size() << __LINE__;
                if(files.size() <= 500) //如果美颜后的图片文件的大小, 小于500字节, 认为美颜失败, 就不需要继续美颜了
                {
                    beautyManager->doHideBeautyButton();
                }
                else
                {
                    //小于500字节的时候, 不删除图片文件
                    QFile::remove(strName);
                }
            }
            //==================================
        }
        else
        {
            QMatrix leftmatrix;
            leftmatrix.rotate(rotation);
            QImage images =  image.transformed(leftmatrix);
            m_imge = images.scaled(this->width(),this->height(),Qt::KeepAspectRatioByExpanding);
        }
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
