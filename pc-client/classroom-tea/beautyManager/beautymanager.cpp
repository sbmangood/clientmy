#include "beautymanager.h"

extern bool doCheckOpenGL_Status();

BeautyManager::BeautyManager(QObject *parent) : QObject(parent)
{

}
bool BeautyManager::checkHideBeautyButton()
{
    qDebug() << "BeautyManager::checkHideBeautyButton" << nama->getErrorCode() << __LINE__;

    if( 0 != nama->getErrorCode())
    {
        doHideBeautyButton();
        return false;
    }

    return true;
}

void BeautyManager::doHideBeautyButton()
{
    canUseBeautySdk = false;
    StudentData::gestance()->beautyIsOn = false;
    hideBeautyButton();
}

BeautyManager::~BeautyManager()
{
    if(initGlw != NULL)
    {
        delete initGlw;
    }
}

uchar * BeautyManager::beautyImage(uchar * img)
{
//    qDebug() << "BeautyManager::beautyImage" << StudentData::gestance()->beautyIsOn << initBeautySDKSUccess << __LINE__;
    if( !StudentData::gestance()->beautyIsOn || !initBeautySDKSUccess)
    {
        StudentData::gestance()->beautyIsOn = false;
        if(!initBeautySDKSUccess)
        {
            doHideBeautyButton();
        }

        //qDebug() << "BeautyManager::beautyImage" << StudentData::gestance()->beautyIsOn << initBeautySDKSUccess << __LINE__;
        return img;
    }

    if( 1 == currentRenderWay )//&& img.byteCount() >= 3686400
    {
        if(!hasInitSdk)
        {
            GLWidget *initGlw = new GLWidget (0);
            initGlw->move(10000, 10000);
            initGlw->show();
            initGlw->hide();

            nama = std::tr1::shared_ptr<NamaExampleNameSpace::Nama>(new NamaExampleNameSpace::Nama);
            initBeautySDKSUccess = nama->Init(1280, 720);
            if(!initBeautySDKSUccess)
            {
                return img;
            }
#if 0
            if(!nama->Init(1280, 720))
            {
                qDebug() << "BeautyManager::beautyImage" << nama->getErrorCode() << __LINE__;
                doHideBeautyButton();
                return img;
            }
#endif

            hasInitSdk = !hasInitSdk;

            if(!checkHideBeautyButton())
            {
                return img;
            }

            nama->m_isBeautyOn = 1;
            nama->m_isDrawProp = 0;
            nama->m_curColorLevel = 2;
            nama->m_curBlurLevel = 3;
            nama->m_redLevel = 1.1;
            //nama->SetCurrentBundle(0);
            nama->UpdateBeauty();
        }

        //再次检测美颜是否可用
        if(doCheckOpenGL_Status())
        {
            //            qDebug() << "BeautyManager::beautyImage" << nama->getErrorCode() << __LINE__;
            nama->RenderItems(img);
        }
#if 0
        else
        {
            qDebug() << "BeautyManager::beautyImage" << nama->getErrorCode() << __LINE__;
            doHideBeautyButton();
        }
#endif
    }

    return img;
}


void BeautyManager::setBeautyOn(bool isBeautyOn)
{
    StudentData::gestance()->beautyIsOn = isBeautyOn;
}

void BeautyManager::setCurBlurLevel(float level)
{
    if( 1 == currentRenderWay )
    {
        if(level < 0)
        {
            level = 0.0;
        }
        else if(level > 5.68)
        {
            level = 5.68;
        }
        nama->m_curBlurLevel = level;
        nama->UpdateBeauty();
    }
}

void BeautyManager::setCurColorLevel(float level)
{
    if( 1 == currentRenderWay )
    {
        if(level < 0)
        {
            level = 0.0;
        }
        else if(level > 1.0)
        {
            level = 1.0;
        }
        nama->m_curColorLevel = level;
        nama->UpdateBeauty();
    }
}

void BeautyManager::setRedLevel(float level)
{
    if( 1 == currentRenderWay )
    {
        if(level < 0)
        {
            level = 0.0;
        }
        else if(level > 1.0)
        {
            level = 1.0;
        }
        nama->m_redLevel = level;
        nama->UpdateBeauty();
    }
}
