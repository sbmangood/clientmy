﻿#include "externalcallchanncel.h"
#include "debuglog.h"
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#include "../../pc-common/yimiIPC/ipcclient.h"

ExternalCallChanncel::ExternalCallChanncel(QObject *parent): QObject(parent)
{
    connect(AudioVideoManager::getInstance(), SIGNAL(sigAudioVolumeIndication(unsigned int,int)), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int)));
    connect(AudioVideoManager::getInstance(), SIGNAL(createRoomFail()), this, SIGNAL(createRoomFail()));
    connect(AudioVideoManager::getInstance(), SIGNAL(sigAudioName(QString)), this, SLOT(sigAudioName(QString)));
    connect(AudioVideoManager::getInstance(), SIGNAL(createRoomSucess()), this, SIGNAL(createRoomSucess()));
    connect(AudioVideoManager::getInstance(), SIGNAL(pushAudioQualityToQos(QString,QString,QString,QString)), this, SLOT(getAudioVideoStatus(QString,QString,QString,QString)));

    // 用户ID
    m_userId = StudentData::gestance()->m_selfStudent.m_studentId;
    // 课程ID
    m_lessonId = StudentData::gestance()->m_lessonId;
    m_apiVersion = StudentData::gestance()->m_apiVersion;
    m_appVersion = StudentData::gestance()->m_appVersion;
    m_token = StudentData::gestance()->m_token;
    m_strSpeaker = AudioVideoManager::getInstance()->getDefaultDevicesId("player_device_name");
    m_strMicPhone = AudioVideoManager::getInstance()->getDefaultDevicesId("recorder_device_name");;
    m_strCamera = AudioVideoManager::getInstance()->getDefaultDevicesId("carmer");
    m_strDllFile = StudentData::gestance()->strAppFullPath;
    m_strAppName = StudentData::gestance()->strAppName;

    m_channelName = "YiMiThSd" + m_lessonId;

    m_httpClient = YMHttpClientUtils::getInstance();
    m_httpUrl = m_httpClient->getRunUrl(1,StudentData::gestance()->strAppFullPath,StudentData::gestance()->strAppName);
}

ExternalCallChanncel::~ExternalCallChanncel()
{

}


void ExternalCallChanncel::getAudioVideoStatus(QString channel, QString audioLost, QString audioDelay, QString audioQuality)
{
    TemporaryParameter::gestance()->s_VideoQulaity = audioQuality;
    TemporaryParameter::gestance()->s_VideoDelay = audioDelay;
    TemporaryParameter::gestance()->s_VideoLost = audioLost;
    QString contents = QString("%1,%2,%3").arg(audioQuality).arg(audioDelay).arg(audioLost);
    TemporaryParameter::gestance()->m_ipContents.insert("0",contents);
}
//初始化频道
void ExternalCallChanncel::initVideoChancel()
{
    changeChanncel();
}

// 进入V2
void ExternalCallChanncel::enterChannelV2(QString videoSpan)
{
    // 视频类型：视频或音频
    QString videoType =  TemporaryParameter::gestance()->m_videoType;
    bool isStartClass = TemporaryParameter::gestance()->m_isStartClass;
    // 麦克风状态
    QString microphoneState =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId);
    // 摄像头状态
    QString cameraState = StudentData::gestance()->m_camera;
    // 角色：教师TEACHER、学生STUDENT、旁听AUDITOR
    ROLE_TYPE role = TEACHER;

    // 开始上课
    if(isStartClass)
    {
        AudioVideoManager::getInstance()->changeChanncel(CHANNEL_B2, videoType, microphoneState, cameraState,
                                                         role, m_userId, m_lessonId, m_apiVersion, m_appVersion, m_token, m_strDllFile, m_strAppName, StudentData::gestance()->strAgoraFullPath_LogFile,
                                                         m_strSpeaker, m_strMicPhone, m_strCamera, StudentData::gestance()->m_cameraPhone, videoSpan.toInt(), m_channelKey, m_channelName);
    }
}

//切换频道
void ExternalCallChanncel::changeChanncel()
{
    // 得到通道名
    QString supplier = TemporaryParameter::gestance()->m_supplier;

    CHANNEL_TYPE currentChannel;
    if(supplier == "1")
    {
        currentChannel = CHANNEL_A;
    }
    else if(supplier == "2")
    {
        // 先判断对方的腾讯SDK版本
        QString qqVoiceVersion = TemporaryParameter::gestance()->qqVoiceVersion;
        if(qqVoiceVersion == "6.0.0")// 如果是新版本字段，则启用B2通道，否则，启用B通道
        {
            currentChannel = CHANNEL_B2;
            emit sigRequestVideoSpan();
            return;
        }
        else
        {
            currentChannel = CHANNEL_B;
        }

    }
    else if(supplier == "3")
    {
        currentChannel = CHANNEL_C;
    }
    // 视频类型：视频或音频
    QString videoType =  TemporaryParameter::gestance()->m_videoType;
    bool isStartClass = TemporaryParameter::gestance()->m_isStartClass;
    // 麦克风状态
    QString microphoneState =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId);
    // 摄像头状态
    QString cameraState = StudentData::gestance()->m_camera;
    // 角色：教师TEACHER、学生STUDENT、旁听AUDITOR
    ROLE_TYPE role = STUDENT;
    m_channelKey = getJoinChannelKey();

    // 开始上课
    if(isStartClass)
    {
        AudioVideoManager::getInstance()->changeChanncel(currentChannel, videoType, microphoneState, cameraState,
                                                         role, m_userId, m_lessonId, m_apiVersion, m_appVersion, m_token, m_strDllFile, m_strAppName, StudentData::gestance()->strAgoraFullPath_LogFile,
                                                         m_strSpeaker, m_strMicPhone, m_strCamera, StudentData::gestance()->m_cameraPhone, 0, m_channelKey, m_channelName);
    }
}

// 获取加入频道时的key
QString ExternalCallChanncel::getJoinChannelKey()
{
    QDateTime dateStr = QDateTime::currentDateTime();
    QString url("http://" + m_httpUrl + "/getDynamicKey");
    QVariantMap maps;
    maps.insert("uId", StudentData::gestance()->m_selfStudent.m_studentId);
    maps.insert("apiVersion", YMUserBaseInformation::apiVersion);
    maps.insert("channelName", "YiMiThSd" + StudentData::gestance()->m_lessonId);
    maps.insert("appVersion", YMUserBaseInformation::appVersion);
    maps.insert("token", YMUserBaseInformation::token);
    maps.insert("timestamp", dateStr.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(maps);
    QString sign = YMEncryption::md5(signSort).toUpper();
    maps.insert("sign",sign);
    QByteArray bytes = m_httpClient->httpPostForm(url,maps);
    QString backData(bytes);
    QString m_channelKey;
    if(backData.contains("success"))
    {
        QJsonParseError error;
        QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
        if(error.error == QJsonParseError::NoError)
        {
            if(documet.isObject())
            {
                QJsonObject jsonObjs = documet.object();
                qDebug() << "===jsonObjs===" << jsonObjs;
                if(jsonObjs.contains("data"))
                {
                    QJsonObject jsonObj = jsonObjs.take("data").toObject();
                    m_channelKey = jsonObj.value("channelKey").toString();
                }
            }
        }
    }
    else
    {
        qDebug() << "==ExternalCallChanncel::getJoinChannelKey failed. ==" << url  << backData << __LINE__;
    }
    return m_channelKey;
}

//关闭所有界面
void ExternalCallChanncel::closeAlllWidget()
{
    if(!StudentData::gestance()->m_hasConnectServer)
    {
        QJsonObject obj;
        obj.insert("result","0");
        obj.insert("server_ip",StudentData::gestance()->m_address);
        obj.insert("errMsg",QStringLiteral("socket连接成功前用户退出教室"));

        YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);
    }
    //================================
    //先上传日志, 再退出所有通道(防止退出通道的时候, 程序出错, 导致日志没有上传)
    //DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件
    DebugLog::GetInstance()->doCloseLog();//关闭文件流
    AudioVideoManager::getInstance()->exitChannel(); //关闭进程前, 需要是否音视频的资源, 不然下次进去, 可能有问题, 尤其是C通道
    //====================进程通信实现上传日志=====================================
    QString  lessonId = StudentData::gestance()->m_lessonId + "_" + StudentData::gestance()->m_userName;
    QString  strParas = m_httpUrl;
             strParas+=";";
             strParas+= StudentData::gestance()->strAppFullPath_LogFile;
             strParas+=";";
             strParas+= StudentData::gestance()->m_token;
             strParas+=";";
             strParas+= lessonId;
             strParas+=";";
             strParas+= YMUserBaseInformation::appVersion;
             strParas+=";";
             strParas+= YMUserBaseInformation::apiVersion;
             strParas+=";";
    IpcClient ipcClient;
    ipcClient.ClientSend("server-listen",strParas);
    //================================
    QProcess process;
    process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
    process.close();
}

//关闭音频
void ExternalCallChanncel::closeAudio(QString status)
{
    if(status == "0")
        AudioVideoManager::getInstance()->closeLocalAudio();
    else
        AudioVideoManager::getInstance()->openLocalAudio();
}
//关闭视频
void ExternalCallChanncel::closeVideo(QString status)
{
    if(status == "0")
        AudioVideoManager::getInstance()->closeLocalVideo();
    else
        AudioVideoManager::getInstance()->openLocalVideo();
}
//设置留在教室
void ExternalCallChanncel::setStayInclassroom()
{
    AudioVideoManager::getInstance()->setStayInclassroom();
}

// 录播
void ExternalCallChanncel::sigAudioName(QString audioName)
{
    StudentData::gestance()->m_audioName = audioName;
}