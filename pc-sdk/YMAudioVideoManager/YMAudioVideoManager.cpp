#include "YMAudioVideoManager.h"

YMAudioVideoManager* YMAudioVideoManager::m_YMAudioVideoManager = NULL;

YMAudioVideoManager::YMAudioVideoManager() : m_processingchannel(NULL), m_isSuccess(false)
{
    beautyManager = new BeautyManager();
    connect(beautyManager, SIGNAL(hideBeautyButton()), this, SIGNAL(hideBeautyButton()));
}

YMAudioVideoManager::~YMAudioVideoManager()
{
    if(NULL != m_processingchannel)
    {
        delete m_processingchannel;
        m_processingchannel = NULL;
    }
}

YMAudioVideoManager* YMAudioVideoManager::getInstance()
{
    if(NULL == m_YMAudioVideoManager)
    {
        m_YMAudioVideoManager = new YMAudioVideoManager();
    }
    return m_YMAudioVideoManager;
}

void YMAudioVideoManager::release()
{
    if(NULL != m_YMAudioVideoManager)
    {
        delete m_YMAudioVideoManager;
        m_YMAudioVideoManager = NULL;
    }
}

// 切换频道
void YMAudioVideoManager::changeChanncel(CHANNEL_TYPE currentChannel, QString videoType, QString microphoneState, QString cameraState,
                                       ROLE_TYPE role, QString userId, QString lessonId, QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath,
                                       QString strSpeaker, QString strMicPhone, QString strCamera, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan,QString channelKey,QString channelName,
                                       COURSE_TYPE courseType, ENVIRONMENT_TYPE enType)
{
    // 在切换前先退出上一个频道,currentChannel--当前的通道  m_preChannel--上一个通道
    if(currentChannel == m_preChannel)
    {
        return;
    }

    if(NULL != m_processingchannel)
    {
        // 关闭摄像头和麦克风，切换至另一通道后会重新打开，这相当于刷新设备的过程，可避免切换通道费时的问题
        m_processingchannel->closeLocalAudio();
        m_processingchannel->closeLocalVideo();
        m_processingchannel->leaveChannel();
        // 切换通道先断开之前的视频画面信号绑定
        disconnect(m_processingchannel, SIGNAL(renderVideoFrameImage(uint,QImage,int)), this, SLOT(onRenderVideoFrameImage(uint,QImage,int)));
        disconnect(m_processingchannel, SIGNAL(pushAudioQualityToQos(QString,QString,QString,QString)), this, SIGNAL(pushAudioQualityToQos(QString,QString,QString,QString)));
        disconnect(m_processingchannel, SIGNAL(pushFrameRateToQos(QString,QString)), this, SIGNAL(pushFrameRateToQos(QString,QString)));
        disconnect(m_processingchannel, SIGNAL(createRoomFail()), this, SIGNAL(createRoomFail()));
        disconnect(m_processingchannel, SIGNAL(createRoomSucess()), this, SIGNAL(createRoomSucess()));
        disconnect(m_processingchannel, SIGNAL(sigAudioName(QString)), this, SIGNAL(sigAudioName(QString)));
        disconnect(m_processingchannel, SIGNAL(createRoomFail()), this, SLOT(slotCreateRoomFail()));
        disconnect(m_processingchannel, SIGNAL(createRoomSucess()), this, SLOT(slotCreateRoomSuccess()));
        disconnect(m_processingchannel, SIGNAL(sigAudioVolumeIndication(uint,int)), this, SIGNAL(sigAudioVolumeIndication(uint,int)));
    }

    // 如果退出了上一个通道指针新建
    switch (currentChannel)
    {
    case CHANNEL_A:
        m_processingchannel = Processing_A_Channel::getInstance();
        qDebug() << "==== curChannel = CHANNEL_A ====";
        break;
    case CHANNEL_B:
        m_processingchannel = Processing_B_Channel::getInstance();
        qDebug() << "==== curChannel = CHANNEL_B ====";
        break;
    case CHANNEL_B2:
        m_processingchannel = Processing_B2_Channel::getInstance();
        qDebug() << "==== curChannel = CHANNEL_B2 ====";
        break;
    case CHANNEL_C:
        m_processingchannel = Processing_C_Channel::getInstance();
        qDebug() << "==== curChannel = CHANNEL_C ====";
        break;
    default:
        break;
    }
    if(NULL == m_processingchannel)
    {
        return;
    }
    m_preChannel = currentChannel;

    // 视频画面信号绑定
    connect(m_processingchannel, SIGNAL(renderVideoFrameImage(uint,QImage,int)), this, SLOT(onRenderVideoFrameImage(uint,QImage,int)));
    connect(m_processingchannel, SIGNAL(pushAudioQualityToQos(QString,QString,QString,QString)), this, SIGNAL(pushAudioQualityToQos(QString,QString,QString,QString)));
    connect(m_processingchannel, SIGNAL(pushFrameRateToQos(QString,QString)), this, SIGNAL(pushFrameRateToQos(QString,QString)));
    connect(m_processingchannel, SIGNAL(sigJoinOrLeaveRoom(unsigned int,int)), this, SIGNAL(sigJoinOrLeaveRoom(unsigned int,int)));
    connect(m_processingchannel, SIGNAL(createRoomFail()), this, SIGNAL(createRoomFail()));
    connect(m_processingchannel, SIGNAL(createRoomSucess()), this, SIGNAL(createRoomSucess()));
    connect(m_processingchannel, SIGNAL(sigAudioName(QString)), this, SIGNAL(sigAudioName(QString)));
    connect(m_processingchannel, SIGNAL(createRoomFail()), this, SLOT(slotCreateRoomFail()));
    connect(m_processingchannel, SIGNAL(createRoomSucess()), this, SLOT(slotCreateRoomSuccess()));
    connect(m_processingchannel, SIGNAL(sigAudioVolumeIndication(uint,int)), this, SIGNAL(sigAudioVolumeIndication(uint,int)));

    // 通道发生了变化,重新初始化并进入频道
    m_processingchannel->initChannel(courseType, role, userId, lessonId, cameraState, microphoneState, strSpeaker, strMicPhone, strCamera,
                                     apiVersion, appVersion, token, strDllFile, strAppName, logFilePath, enType);
    m_processingchannel->enterChannel(channelKey.toLatin1().data(),channelName.toLatin1().data(), "", userId.toInt(), cameraPhone,videoSpan);

    // 如果是旁听，则关闭本地视频、关闭本地音频
    if(role == AUDITOR)
    {
        m_processingchannel->closeLocalAudio();
        m_processingchannel->closeLocalVideo();
        return;
    }

    if(microphoneState == "1")
    {
        m_processingchannel->openLocalAudio();
    }
    else
    {
        m_processingchannel->closeLocalAudio();
    }

    if(videoType == "0")
    {
        m_processingchannel->closeLocalVideo();
    }
    else
    {
        if(cameraState == "1")
        {
            m_processingchannel->openLocalVideo();
        }
        else
        {
            m_processingchannel->closeLocalVideo();
        }
    }
}

// 设置留在教室
void YMAudioVideoManager::setStayInclassroom()
{
    exitChannel();
}

// 退出频道
void YMAudioVideoManager::exitChannel()
{
    m_preChannel = CHANNEL_0;
    if(NULL != m_processingchannel)
    {
        // 关闭摄像头和麦克风，切换至另一通道后会重新打开，这相当于刷新设备的过程，可避免切换通道费时的问题
        m_processingchannel->closeLocalAudio();
        m_processingchannel->closeLocalVideo();
        m_processingchannel->leaveChannel();
        m_processingchannel = NULL;//此处应置空，防止调用setStayInclassroom()留在教室重新加入后重复关闭摄像头和视频造成崩溃
    }
}

QString YMAudioVideoManager::getDefaultDevicesId(QString deviceKey)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString m_systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) //docPath是空, 或者不存在
    {
        m_systemPublicFilePath = "C:/";
    }
    else
    {
        m_systemPublicFilePath = docPath + "/";
    }

    m_systemPublicFilePath += "/YiMi/temp/";

    QDir isDir;

    // 设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
        return "";
    }
    QSettings deviceSetting(m_systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
    deviceSetting.setIniCodec(QTextCodec::codecForName("UTF-8"));

    deviceSetting.beginGroup("Device");

    qDebug() << "YMAudioVideoManager::getDefaultDevicesId" << deviceSetting.value(deviceKey).toString() << __LINE__;
    return deviceSetting.value(deviceKey).toString();
}

// 关闭本地音频
void YMAudioVideoManager::closeLocalAudio()
{
    if(NULL != m_processingchannel)
    {
        m_processingchannel->closeLocalAudio();
    }
}

// 打开本地音频
void YMAudioVideoManager::openLocalAudio()
{
    if(NULL != m_processingchannel)
    {
        m_processingchannel->openLocalAudio();
    }
}

// 关闭本地视频
void YMAudioVideoManager::closeLocalVideo()
{
    if(NULL != m_processingchannel)
    {
        m_processingchannel->closeLocalVideo();
    }
}
// 打开本地视频
void YMAudioVideoManager::openLocalVideo()
{
    if(NULL != m_processingchannel)
    {
        m_processingchannel->openLocalVideo();
    }

}

void YMAudioVideoManager::slotCreateRoomFail()
{
    m_isSuccess = false;
    emit sigAisleFinish(m_isSuccess);
}

void YMAudioVideoManager::slotCreateRoomSuccess()
{
    m_isSuccess = true;
    emit sigAisleFinish(m_isSuccess);
}

void YMAudioVideoManager::enableBeauty(bool isBeauty)
{
    BeautyList::getInstance()->beautyIsOn = isBeauty;
    QString exePath = QCoreApplication::applicationDirPath();
    QString strDllFile = exePath + "/Qtyer.dll";
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

bool YMAudioVideoManager::getBeautyIsOn()
{
    beautyManager->checkHideBeautyButton();
    QString exePath = QCoreApplication::applicationDirPath();
    QString strDllFile = exePath + "/Qtyer.dll";
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

int YMAudioVideoManager::setUserRole(CLIENT_ROLE role)
{
    int ret = -1;
    if(NULL != m_processingchannel)
    {
        ret = m_processingchannel->setUserRole(role);
    }
    return ret;
}

int YMAudioVideoManager::setVideoResolution(VIDEO_RESOLUTION resolution)
{
    int ret = -1;
    if(NULL != m_processingchannel)
    {
        ret = m_processingchannel->setVideoResolution(resolution);
    }
    return ret;
}

void YMAudioVideoManager::onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation)
{
   if(BeautyList::getInstance()->beautyIsOn && uid == 0)
   {
       QImage beautyImage;
       beautyImage.load(QString::number(uid));
       if(beautyImage.isNull())
       {
           return;
       }
       QMatrix leftmatrix;
       leftmatrix.rotate(rotation);
       beautyImage =  beautyImage.transformed(leftmatrix);
       beautyImage = beautyImage.scaled(1280, 720, Qt::KeepAspectRatioByExpanding);
       m_imge = QImage(beautyManager->beautyImage(beautyImage.bits()), 1280, 720, QImage::Format_RGB32).scaled(640, 360, Qt::KeepAspectRatioByExpanding);
       BeautyList::getInstance()->hasBeautyImageList.append(m_imge);
       // 将美颜后的图片, 保存到本地, 如果图片大小, 小于500字节, 说明美颜失败了, 就不美颜了
       static bool bOnlyOnce = false;
       if(!bOnlyOnce)
       {
           bOnlyOnce = true;
           QString strName = QString("./aaa.png");
           m_imge.save(strName, 0);
           QFile files(strName);
           // 如果美颜后的图片文件的大小, 小于500字节, 认为美颜失败, 就不需要继续美颜了
           if(files.size() <= 500)
           {
               beautyManager->doHideBeautyButton();
           }
           else
           {
               // 小于500字节的时候, 删除图片文件
               QFile::remove(strName);
           }
       }
   }
   else
   {
       QMatrix leftmatrix;
       leftmatrix.rotate(rotation);
       m_imge = image.transformed(leftmatrix);
   }
   emit renderVideoFrameImage(uid, m_imge, rotation);
}
