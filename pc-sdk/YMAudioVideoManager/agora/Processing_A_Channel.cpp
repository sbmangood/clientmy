#include "Processing_A_Channel.h"

RtcEngineContext Ctx;
IRtcEngine * Processing_A_Channel::m_rtcEngine = NULL;

Processing_A_Channel* Processing_A_Channel::m_processing_A_Channel = NULL;

Processing_A_Channel::Processing_A_Channel(): m_observer(NULL)
{

}

Processing_A_Channel *Processing_A_Channel::getInstance()
{
    if(NULL == m_processing_A_Channel)
    {
        m_processing_A_Channel = new Processing_A_Channel();
    }
    return m_processing_A_Channel;
}

//Capture Type  Windows平台设置成3
bool Processing_A_Channel::SetVideoCaptureType(int nType)
{
    AParameter apm(*m_rtcEngine);
    int nRet = apm->setInt("che.video.videoCaptureType", nType);
    return nRet == 0 ? true : false;
}


// 是否开启FEC增强弱网对抗
int Processing_A_Channel::setFECParameters(bool preferSetFEC)
{
    AParameter apm(*m_rtcEngine);
    if(preferSetFEC)
    {
        return apm->setParameters("{\"che.video.moreFecSchemeEnable\":true}");
    }
    else
    {
        return apm->setParameters("{\"che.video.moreFecSchemeEnable\":false}");
    }
}

// 设置UC模式, hasIntraReq:小组课true,其他false
int Processing_A_Channel::setUCMode(bool hasIntraReq)
{
    AParameter apm(*m_rtcEngine);
    int ret = 0;
    if(NULL != apm)
    {
        ret = apm->setParameters("{\"che.video.fecMethod\":2}");
    }
    if(ret < 0)
    {
        return ret;
    }
    if(hasIntraReq)
    {
        if(NULL != apm)
        {
            ret = apm->setParameters("{\"che.video.has_intra_request\":true}");
        }
    }
    return ret;
}

// 设置观众端低延迟
int Processing_A_Channel::setAudienceLowLatency()
{
    AParameter apm(*m_rtcEngine);
    int ret = 0;
    if(NULL != apm)
    {
        ret = apm->setParameters("{\"rtc.min_playout_delay\":50}");
    }
    if(ret < 0)
    {
        return ret;
    }
    if(NULL != apm)
    {
        ret = apm->setParameters("{\"che.audio.specify.codec\":\"OPUSFB\"}");
    }
    return ret;
}

Processing_A_Channel::~Processing_A_Channel(){}

// 初始化频道
bool Processing_A_Channel::initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                                       QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath, ENVIRONMENT_TYPE enType)
{
    m_courseType = courseType;
    m_role = role;
    m_userId = userId;
    m_camera = camera;
    m_microphone = microphone;
    m_lessonId = lessonId;
    m_apiVersion = apiVersion;
    m_appVersion = appVersion;
    m_token = token;
    m_strDllFile = strDllFile;
    m_strAppName = strAppName;
    // 场景切换时释放
    if(m_rtcEngine)
    {
        m_rtcEngine->release();
    }
    m_rtcEngine = (IRtcEngine*)createAgoraRtcEngine();
    m_rtcEngine->setAudioProfile(agora::rtc::AUDIO_PROFILE_DEFAULT, agora::rtc::AUDIO_SCENARIO_EDUCATION);
    // 设置环境url, 大班课通过环境参数传进来，小组课及其他课程依旧读取配置文件获取
    m_httpClient = YMHttpClientUtils::getInstance();
    if(courseType == BIG_CLASS)
    {
        m_httpUrl = m_httpClient->getRunUrl(enType);
    }
    else
    {
        m_httpUrl = m_httpClient->getRunUrl(1, m_strDllFile, m_strAppName);
    }
    qDebug()<<"======Processing_A_Channel::initChannel::m_httpUrl="<<m_httpUrl;
    connect(&m_handler, SIGNAL(sigAudioVolumeIndication(unsigned int, int)), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int)));
    Ctx.eventHandler = &m_handler;
    if(courseType == BIG_CLASS)// 大班课
    {
        if(enType == API)
        {
            Ctx.appId = "7169a6c5ab5b4eeba2ca37b831fb9239";
        }
        else
        {
            Ctx.appId = "d10cd7b114b3401ea986c0e6c53523e6";
        }
    }
    else                       // 其他课程
    {
        if(YMHttpClientUtils::getInstance()->getCurrentEnvironmentType() == "pre")
        {
            Ctx.appId = "eb08a4bf2ac340a08b7eb3304f38e73f";
        }
        else
        {
            Ctx.appId = "6bdd1aedee814f1fade7ef5e42578ff7";
        }
    }
    int iResult = 0;
    if(0 != (iResult = m_rtcEngine->initialize(Ctx))) //初始化
    {
        qDebug() << "Processing_A_Channel::Processing_A_Channel initialize." << iResult <<__LINE__;
    }
    logFilePath = setAgoraLogFile();
    agora::util::AutoPtr<agora::media::IMediaEngine> mediaEngine;
    mediaEngine.queryInterface(m_rtcEngine, agora::AGORA_IID_MEDIA_ENGINE);
    // 对于小组课, 视频分辨率设为160*120, 其他设为320*180
    if(m_courseType == SMALL_GROUP)
    {
        if(NULL == m_observer)
        {
            m_observer = new AgoraPacketObserver(160, 120);
        }
    }
    else if(m_courseType == BIG_CLASS)
    {
        if(NULL == m_observer)
        {
            m_observer = new AgoraPacketObserver(480, 360);
        }
    }
    else
    {
        if(NULL == m_observer)
        {
            m_observer = new AgoraPacketObserver(320, 180);
        }
    }

    if (mediaEngine)
    {
        mediaEngine->registerVideoFrameObserver(m_observer);
    }

    // 小组课、大班课设为直播模式 CHANNEL_PROFILE_LIVE_BROADCASTING
    // 其他设置为通信模式 CHANNEL_PROFILE_COMMUNICATION
    CHANNEL_PROFILE_TYPE channel_profile;
    if(m_courseType == SMALL_GROUP || m_courseType == BIG_CLASS)
    {
        channel_profile = CHANNEL_PROFILE_LIVE_BROADCASTING;
    }
    else
    {
        channel_profile = CHANNEL_PROFILE_COMMUNICATION;
    }

    if(0 != (iResult = m_rtcEngine->setChannelProfile(channel_profile)))
    {
        qDebug() << "Processing_A_Channel::Processing_A_Channel setChannelProfile failed." << iResult << __LINE__;
    }

    // 直播模式下需要设置主播、观众角色
    if(channel_profile == CHANNEL_PROFILE_LIVE_BROADCASTING)
    {
        // 小组课
        if(m_courseType == SMALL_GROUP)
        {
            if(m_role == TEACHER || m_role == STUDENT)
            {
                m_rtcEngine->setClientRole(CLIENT_ROLE_BROADCASTER);
            }
            else
            {
                m_rtcEngine->setClientRole(CLIENT_ROLE_AUDIENCE);
            }
        }
        // 大班课
        else if(m_courseType == BIG_CLASS)
        {
            if(m_role == TEACHER)
            {
                m_rtcEngine->setClientRole(CLIENT_ROLE_BROADCASTER);
            }
            else
            {
                m_rtcEngine->setClientRole(CLIENT_ROLE_AUDIENCE);
                setAudienceLowLatency();
            }
        }
        // 其他课程
        else
        {

        }
    }

    if(0 != (iResult = m_rtcEngine->enableAudio())) //打开音频
    {
        qDebug() << "Processing_A_Channel::Processing_A_Channel enableAudio failed." << iResult << __LINE__;
    }
    if(0 != (iResult = m_rtcEngine->enableVideo())) //打开视频
    {
        qDebug() << "Processing_A_Channel::Processing_A_Channel enableVideo failed." << iResult << __LINE__;
    }
    this->setDefaultDevice();
    connect(m_observer, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)), this, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)));
    SetVideoCaptureType(3); //声网的技术支持Nick推荐使用nType为3的设置
    if(0 != (iResult = m_rtcEngine->enableAudio()))//打开音频
    {
        qDebug() << "Processing_A_Channel::exchangeToWaysA enableAudio failed." << iResult << __LINE__;
    }
    if(0 != (iResult = m_rtcEngine->enableVideo()))//打开视频
    {
        qDebug() << "Processing_A_Channel::exchangeToWaysA enableVideo failed." << iResult << __LINE__;
    }

    // 设置视频属性：小组课设为160x120 15fps, 其他设为320x180 15fps
    if(m_courseType == SMALL_GROUP)
    {
        m_rtcEngine->setVideoProfile(agora::rtc::VIDEO_PROFILE_LANDSCAPE_120P, false);
    }
    else if(m_courseType == BIG_CLASS)
    {
        m_rtcEngine->setVideoProfile(agora::rtc::VIDEO_PROFILE_LANDSCAPE_360P_7, false);// 大班班默认以标清360P分辨率进入频道
    }
    else
    {
        m_rtcEngine->setVideoProfile(agora::rtc::VIDEO_PROFILE_LANDSCAPE_180P, false);
    }

    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    rtcEngineParameters.enableAudioVolumeIndication(300, 3);
    // 对小组课场景, 加入频道前,开启FEC，增强弱网对抗; 并开启流畅优先模式
    if(m_courseType == SMALL_GROUP)
    {
        setFECParameters(true);
        rtcEngineParameters.setVideoQualityParameters(true);
        setUCMode(true);// 小组课设置fecMethod为2, has_intra_request为true
    }
    // 大班课设置fecMethod为2
    else if(m_courseType == BIG_CLASS)
    {
        setUCMode(false);
    }
    if(role == AUDITOR)// 如果是旁听者默认关闭本地音视频
    {
        closeLocalAudio();
        closeLocalVideo();
    }
    //logFilePath = setAgoraLogFile();
    return true;
}

// 加入频道
bool Processing_A_Channel::enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan)
{

    if(NULL == channelName || NULL == channelKey || NULL == info)
    {
        qDebug() << "Processing_A_Channel::enterChannel fail QString(channelName).isEmpty()." << __LINE__; // 加入频道时的频道名为空
        emit createRoomFail();
        return false;
    }
    if(QVariant(uid).isNull())
    {
        qDebug() << "Processing_A_Channel::enterChannel fail QVariant(uid).isNull()." << __LINE__; // 加入频道的id标示为空
        emit createRoomFail();
        return false;
    }
    int iResult = 0;

    if(0 == (iResult = m_rtcEngine->joinChannel(channelKey, channelName, info, uid))) // 加入频道
    {
        qDebug() << "Processing_A_Channel::enterChannel success." << __LINE__; // 加入频道成功
        emit createRoomSucess();
        return true;
    }
    else
    {
        qDebug() << "Processing_A_Channel::enterChannel failed." << iResult << __LINE__; // 加入频道失败
        emit createRoomFail();
        return false;
    }
}

// 打开本地视频
bool Processing_A_Channel::openLocalVideo()
{
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    qDebug() << "Processing_A_Channel::openLocalVideo" << __LINE__;
    return rtcEngineParameters.enableLocalVideo(true) == 0;
}

// 关闭本地视频
bool Processing_A_Channel::closeLocalVideo()
{
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    qDebug() << "Processing_A_Channel::closeLocalVideo" << __LINE__;
    return rtcEngineParameters.enableLocalVideo(false) == 0;
}

// 打开本地音频
bool Processing_A_Channel::openLocalAudio()
{
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    qDebug() << "Processing_A_Channel::openLocalAudio" << __LINE__;
    return rtcEngineParameters.muteLocalAudioStream(false) == 0;
}

// 关闭本地音频
bool Processing_A_Channel::closeLocalAudio()
{
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    qDebug() << "Processing_A_Channel::closeLocalAudio" << __LINE__;
    return rtcEngineParameters.muteLocalAudioStream(true) == 0;
}

// 设置用户角色
int Processing_A_Channel::setUserRole(CLIENT_ROLE role)
{
    if(NULL == m_rtcEngine)
    {
        return -1;
    }
    int ret = 0;
    if(role == BROADCASTER)
    {
        ret = m_rtcEngine->setClientRole(CLIENT_ROLE_BROADCASTER);
    }
    else
    {
        ret = m_rtcEngine->setClientRole(CLIENT_ROLE_AUDIENCE);
    }
    return ret;
}

// 设置视频分辨率
int Processing_A_Channel::setVideoResolution(VIDEO_RESOLUTION resolution)
{
    int ret = -1;
    if(NULL != m_rtcEngine)
    {
        if(resolution == STANDARD_DEFINITION)// 标清
        {
            ret = m_rtcEngine->setVideoProfile(agora::rtc::VIDEO_PROFILE_LANDSCAPE_360P_7, false);// 480x360   15   320
            //qDebug()<<"========标清=======";
        }
        else if(resolution == HIGH_DEFINITION)// 高清
        {
            ret = m_rtcEngine->setVideoProfile(agora::rtc::VIDEO_PROFILE_LANDSCAPE_480P, false);// 640x480   15   500
            //qDebug()<<"========高清=======";
        }
        else if(resolution == SUPER_DEFINITION)// 超清
        {
            ret = m_rtcEngine->setVideoProfile(agora::rtc::VIDEO_PROFILE_LANDSCAPE_720P_5, false);// 960x720   15   910
            //qDebug()<<"========超清=======";
        }
    }
    return ret;
}

// 离开频道
bool Processing_A_Channel::leaveChannel()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(&m_handler, SIGNAL(onLeaveChannelSignal()), &loop, SLOT(quit()));
    int ret = 0;
    if(0 != (ret = m_rtcEngine->disableAudio()))
    {
        return false;
    }
    if(0 != (ret = m_rtcEngine->disableVideo()))
    {
        return false;
    }
    if(0 != (ret = m_rtcEngine->leaveChannel()))
    {
        return false;
    }
    loop.exec();
    qDebug() << "Processing_A_Channel::leaveChannel" << __LINE__;
    if(NULL != m_observer)
    {
        delete m_observer;
        m_observer = NULL;
    }
    return true;
}

// 获取加入频道时的key
const char* Processing_A_Channel::getJoinChannelKey()
{
    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    QDateTime dateStr = QDateTime::currentDateTime();
    QString url("http://" + m_httpUrl + "/getDynamicKey?");
    QMap<QString, QString> maps;
    maps.insert("uId", m_userId);
    maps.insert("apiVersion", m_apiVersion);
    maps.insert("channelName", "YiMiThSd" + m_lessonId);
    maps.insert("appVersion", m_appVersion);
    maps.insert("token", m_token);
    maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));
    QString sign;
    QString urls;
    QMap <QString, QString>::iterator it = maps.begin();
    for(int i = 0; it != maps.end(); it++, i++)
    {
        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());
    QByteArray post_data;
    post_data.append(urls);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    httpRequest.setUrl(url);
    QNetworkReply * httpReply = httpAccessmanger->post(httpRequest, post_data);
    QEventLoop httploop;
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    httploop.exec();
    QByteArray bytes = httpReply->readAll();
    QString backData(bytes);
    if(backData.contains("success"))
    {
        QJsonParseError error;
        QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
        if(error.error == QJsonParseError::NoError)
        {
            if(documet.isObject())
            {
                QJsonObject jsonObjs = documet.object();
                if(jsonObjs.contains("data"))
                {
                    QJsonObject jsonObj = jsonObjs.take("data").toObject();
                    QString channelKey = jsonObj.value("channelKey").toString();
                    m_channelKey = channelKey;
                }
            }
        }
    }
    else
    {
        qDebug() << "==Processing_A_Channel::getJoinChannelKey failed. ==" << url  << backData << __LINE__;
    }
    QByteArray tempdata = m_channelKey.toLatin1();
    const  char *bd = tempdata.data();
    return bd;
}

// 得到设备ID
QString Processing_A_Channel::getDefaultDevicesId(QString deviceKey)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString m_systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) // docPath是空, 或者不存在
    {
        m_systemPublicFilePath = "C:/";
    }
    else
    {
        m_systemPublicFilePath = docPath + "/";
    }

    m_systemPublicFilePath += "/YiMi/temp/";
    QDir isDir;
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
        return "";
    }
    QSettings deviceSetting(m_systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
    deviceSetting.beginGroup("Device");
    return deviceSetting.value(deviceKey).toString();
}

// 设置默认设备属性
void Processing_A_Channel::setDefaultDevice()
{
    // 获取默认的设备Id信息
    QString playerId = getDefaultDevicesId("player");
    QString recorderId = getDefaultDevicesId("recorder");
    QString carmerId = getDefaultDevicesId("carmer");
    // 设置默认声音播放设备*****************************
    m_audioDevicemanager = new AAudioDeviceManager(m_rtcEngine);
    m_audioPlayDeviceCollection = (*m_audioDevicemanager)->enumeratePlaybackDevices();
    char caName[MAX_DEVICE_ID_LENGTH], caId[MAX_DEVICE_ID_LENGTH];
    if(m_audioPlayDeviceCollection != NULL && playerId != "")
    {
        if(m_audioPlayDeviceCollection->getCount() > 0)
        {
            for(int a = 0; a < m_audioPlayDeviceCollection->getCount(); a++)
            {
                m_audioPlayDeviceCollection->getDevice(a, caName, caId);
                if(playerId == caId)
                {
                    (*m_audioDevicemanager)->setPlaybackDevice(caId);
                }
            }
        }
    }
    // 设置默认扬声器设备*****************************
    m_audioPlayDeviceCollection = (*m_audioDevicemanager)->enumerateRecordingDevices();
    RtcEngineParameters(m_rtcEngine).adjustRecordingSignalVolume(100);
    RtcEngineParameters(m_rtcEngine).adjustPlaybackSignalVolume(100);
    if(m_audioPlayDeviceCollection != NULL && recorderId != "")
    {
        if(m_audioPlayDeviceCollection->getCount() > 0)
        {
            for(int a = 0; a < m_audioPlayDeviceCollection->getCount(); a++)
            {
                m_audioPlayDeviceCollection->getDevice(a, caName, caId);
                if(recorderId == caId)
                {
                    (*m_audioDevicemanager)->setRecordingDevice(caId);
                }
            }
        }
    }
    // 设置默认摄像设备***************************
    m_videoDeviceManger = new AVideoDeviceManager(m_rtcEngine);
    m_videoDeviceCollect = (*m_videoDeviceManger)->enumerateVideoDevices();
    if(m_videoDeviceCollect != NULL && carmerId != "")
    {
        if(m_videoDeviceCollect->getCount() > 0)
        {
            for(int a = 0; a < m_videoDeviceCollect->getCount(); a++)
            {
                m_videoDeviceCollect->getDevice(a, caName, caId);
                if(carmerId == caId)
                {
                    (*m_videoDeviceManger)->setDevice(caId);
                }
            }
        }
    }
}

// 声网日志上传
QString Processing_A_Channel::setAgoraLogFile()
{
    // log file
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString m_systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) // docPath是空, 或者不存在
    {
        m_systemPublicFilePath = "C:/";
    }
    else
    {
        m_systemPublicFilePath = docPath + "/";
    }

    m_systemPublicFilePath += "/YiMi/teaLog";
    QDir isDir(m_systemPublicFilePath);
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }
    QFileInfoList tempFileInfo = isDir.entryInfoList();
    QDateTime tempDate;
    for (int i = 0; i < tempFileInfo.size(); ++i)
    {
        QFileInfo fileInfo = tempFileInfo.at(i);
        QString tempfileName = fileInfo.fileName();
        tempfileName = tempfileName.remove("log_1.log");
        tempfileName = tempfileName.remove("log_2.log");
        tempDate = QDateTime::fromString(tempfileName.remove("log.log"), "yyyyMMdd");
        if(tempDate.date().addDays(14) < QDateTime::currentDateTime().date())
        {
            QFile::remove(m_systemPublicFilePath + "/" + fileInfo.fileName());
        }
    }
    m_systemPublicFilePath.append(QString("/%1log.log").arg(QDateTime::currentDateTime().toString("yyyyMMdd")));
    m_systemPublicFilePath.replace("/", "\\");

    // 保存声网SDK的日志文件的路径
    qDebug() << "Processing_A_Channel::setAgoraLogFile: " << qPrintable(m_systemPublicFilePath);
    RtcEngineParameters(m_rtcEngine).setLogFile(m_systemPublicFilePath.toStdString().c_str());
    return m_systemPublicFilePath;
}
