#include "processingachannel.h"
#include <QDebug>
#include <debuglog.h>
#include <QTimer>

RtcEngineContext Ctx;
ProcessingAchannel::ProcessingAchannel(QObject *parent) : QObject(parent)
{
//    m_rtcEngine = (IRtcEngine*)createAgoraRtcEngine();
//    m_rtcEngine->setAudioProfile(agora::rtc::AUDIO_PROFILE_DEFAULT,agora::rtc::AUDIO_SCENARIO_EDUCATION);

//    m_httpClient = YMHttpClient::defaultInstance();
//    m_httpUrl = m_httpClient->getRunUrl(1);

//    connect(&m_handler ,SIGNAL(sigAudioVolumeIndication(unsigned int  , int  )) ,this , SIGNAL(sigAudioVolumeIndication(unsigned int  , int  ))  );
//    Ctx.eventHandler = &m_handler;
//    Ctx.appId = "6bdd1aedee814f1fade7ef5e42578ff7";
//    if(0== m_rtcEngine->initialize(Ctx))//初始化
//    {
//        //qDebug()<<QStringLiteral("初始化成功");
//    }

//    agora::util::AutoPtr<agora::media::IMediaEngine> mediaEngine;
//    mediaEngine.queryInterface(m_rtcEngine,agora::rtc::AGORA_IID_MEDIA_ENGINE);

//    if (mediaEngine)
//    {
//        mediaEngine->registerVideoFrameObserver(&m_observer);
//    }


//    if(0==m_rtcEngine->setChannelProfile(CHANNEL_PROFILE_COMMUNICATION))//设置通信模式 CHANNEL_PROFILE_COMMUNICATION 为通信模式
//    {
//        //qDebug()<<QStringLiteral("通信模式设置成功");
//    }
//    if(0==m_rtcEngine->enableAudio())//打开音频
//    {
//        //qDebug()<<QStringLiteral("音频打开成功");
//    }
//    if(0==m_rtcEngine->enableVideo())//打开视频
//    {
//        //qDebug()<<QStringLiteral("视频打开成功");
//    }
//    //    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
//    //    rtcEngineParameters.setLogFile("D:\\logs.txt");
//    this->setDefaultDevice();
//    m_currentModeVideo = true;
//    connect(&m_observer,SIGNAL(renderVideoFrameImage(unsigned int , QImage ,int)),this ,SIGNAL( renderVideoFrameImage(unsigned int , QImage ,int ) ));
//    disableOrEnableAudio(false);
//    disableOrEnableVideo(false);

//    this->setAgoraLogFile();
}

ProcessingAchannel::~ProcessingAchannel()
{

}
void ProcessingAchannel::setAgoraLogFile()
{
    //log file
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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
    RtcEngineParameters(m_rtcEngine).setLogFile(m_systemPublicFilePath.toStdString().c_str());

}


//是否开课
void ProcessingAchannel::setInitStartClass(bool status)
{
    m_observer.setInitStartClass( status);
}
//切换到wayA
void ProcessingAchannel::exchangeToWaysA()
{
    m_currentModeVideo = true;
    if(0 == m_rtcEngine->enableAudio())//打开音频
    {
        //qDebug()<<QStringLiteral("音频打开成功");
    }
    if(0 == m_rtcEngine->enableVideo())//打开视频
    {
        //qDebug()<<QStringLiteral("视频打开成功");
        //   rtcEngine->setVideoProfile(VIDEO_PROFILE_180P,true);//设置视频属性
    }
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    rtcEngineParameters.enableAudioVolumeIndication(300, 3);

}
//打开与关闭本地音频
bool ProcessingAchannel::disableOrEnableAudio(bool stsuts)
{
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    rtcEngineParameters.muteLocalAudioStream(stsuts);

    return stsuts;

}
//打开与关闭本地视频
bool ProcessingAchannel::disableOrEnableVideo(bool stsuts)
{
    RtcEngineParameters rtcEngineParameters(*m_rtcEngine);
    rtcEngineParameters.enableLocalVideo(stsuts);
    return stsuts;
}
//设置音频
void ProcessingAchannel::setAudioMode()
{
    if(m_currentModeVideo)
    {
        m_currentModeVideo = false;
        m_rtcEngine->disableVideo();
    }
}
//设置视频
void ProcessingAchannel::setVideoMode()
{
    //qDebug()<< "ProcessingAchannel::setVideoMode" <<m_currentModeVideo;
    if(m_currentModeVideo)
    {

    }
    else
    {
        m_currentModeVideo = true;
        m_rtcEngine->enableVideo();

    }

}
//进入频道
bool ProcessingAchannel::joinChannel(const char *channelName, const char *info, uid_t uid)
{
    if(QString(channelName).isEmpty() || QString(channelName).isEmpty())
    {
        //qDebug()<< "11111111111111";//"加入频道时的频道名为空";
        return false;
    }
    if(QVariant(uid).isNull())
    {
        //qDebug()<< "22222222222222";//("加入频道的 id标示为空");
        return false;
    }

    if(0 == m_rtcEngine->joinChannel(getJoinChannelKey(channelName, uid), channelName, info, uid)) //加入频道
    {
        //qDebug()<< "33333333333333";//("加入频道成功");
        //rtcEngine->leaveChannel();
        return true;
    }
    else
    {
        //qDebug()<< "44444444444444";//("加入频道失败");
        return false;
    }

}
//离开频道
bool ProcessingAchannel::leaveChannel()
{
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(&m_handler, SIGNAL(onLeaveChannelSignal()), &loop, SLOT(quit()));
    m_rtcEngine->disableAudio();
    m_rtcEngine->disableVideo();
    m_rtcEngine->leaveChannel();
    loop.exec();
    return true;
}

QString ProcessingAchannel::getDefaultDevicesId(QString deviceKey)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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

//设置默认属性
void ProcessingAchannel::setDefaultDevice()
{
    //获取默认的设备Id信息
    QString playerId = getDefaultDevicesId("player");
    QString recorderId = getDefaultDevicesId("recorder");
    QString carmerId = getDefaultDevicesId("carmer");

    //设置默认声音播放设备*****************************
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
                    //qDebug()<<QStringLiteral("默认播放设备设置成功");
                    (*m_audioDevicemanager)->setPlaybackDevice(caId);
                }
            }
        }
    }

    //设置默认扬声器设备*****************************
    m_audioPlayDeviceCollection = (*m_audioDevicemanager)->enumerateRecordingDevices();
    //(*m_audioDevicemanager)->setRecordingDeviceVolume(150);//默认100
    //(*m_audioDevicemanager)->setPlaybackDeviceVolume(100);
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
                    //qDebug()<<"defualt aud-i-----------------------------------";
                    (*m_audioDevicemanager)->setRecordingDevice(caId);
                }
            }
        }
    }

    //设置默认摄像设备***************************
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
                    // qDebug()<<QStringLiteral("默认摄像设备设置成功");
                    (*m_videoDeviceManger)->setDevice(caId);
                }
            }
        }
    }
}

//获取加入频道时的key
const char *ProcessingAchannel::getJoinChannelKey(const char *channelName, uid_t userId)
{
    QNetworkAccessManager * httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    QDateTime dateStr = QDateTime::currentDateTime();
    QString teahcStr =  StudentData::gestance()->m_selfStudent.m_studentId;
    QString url("http://" + m_httpUrl + "/getDynamicKey?");
    QMap<QString, QString> maps;
    maps.insert("uId", teahcStr);
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("channelName", "YiMiThSd" + StudentData::gestance()->m_lessonId);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));

    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  maps.begin();
    for(int i = 0; it != maps.end() ; it++, i++)
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
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded"); //QNetworkRequest::ContentLengthHeader, post_data.length());
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

                    QString channelKey = jsonObj.take("channelKey").toString();

                    StudentData::gestance()->m_channelKey = channelKey;
                }
            }
        }

    }
    else
    {
        qDebug() << "ProcessingAchannel::getJoinChannelKey" << backData;
    }

    QByteArray tempdata = StudentData::gestance()->m_channelKey.toLatin1();
    const  char *bd = tempdata.data();
    return bd;
}

