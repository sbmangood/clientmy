#include "Processing_C_Channel.h"

Processing_C_Channel* Processing_C_Channel::m_processing_C_Channel = NULL;

Processing_C_Channel::Processing_C_Channel()
{
    connect(&m_objChanelWangyi, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)), this, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)));
    connect(&m_objChanelWangyi, SIGNAL(sigAudioName(QString)), this, SIGNAL(sigAudioName(QString)));
}

Processing_C_Channel::~Processing_C_Channel()
{
    disconnect(&m_objChanelWangyi, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)), this, SIGNAL(renderVideoFrameImage(unsigned int, QImage, int)));
    disconnect(&m_objChanelWangyi, SIGNAL(sigAudioName(QString)), this, SIGNAL(sigAudioName(QString)));
}

Processing_C_Channel* Processing_C_Channel::getInstance()
{
    if(NULL == m_processing_C_Channel)
    {
        m_processing_C_Channel = new Processing_C_Channel();
    }
    return m_processing_C_Channel;
}

// 得到推流地址
bool Processing_C_Channel::doGet_Push_Url()
{
    QString url = "http://" + m_httpUrl + "/im/createLiveRoom";
    QVariantMap  reqParm;
    QDateTime currentTime = QDateTime::currentDateTime();
    reqParm.insert("lessonId", m_lessonId.toInt());
    reqParm.insert("token", m_token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMAVEncryption::signMapSort(reqParm);
    QString sign = YMAVEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() == "success")
    {
        QString strPushUrl = dataObj.value("data").toObject().value("pushUrl").toString();
        chanel_wangyi::m_push_url = strPushUrl.toStdString();
        return true;
    }
    else
    {
        qDebug() << "====== Processing_C_channel::doGet_Push_Url failed." << dataObj;
        return false;
    }
}

// 得到用户名和密码
bool Processing_C_Channel::doGet_User_Name_pwd()
{
    QString url = "http://" + m_httpUrl + "/im/getToken";
    QVariantMap  reqParm;
    QDateTime currentTime = QDateTime::currentDateTime();
    reqParm.insert("type", 2);
    reqParm.insert("token", m_token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString signSort = YMAVEncryption::signMapSort(reqParm);
    QString sign = YMAVEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() == "success")
    {
        QString strToken = dataObj.value("data").toObject().value("token").toString();
        QString strAccid = dataObj.value("data").toObject().value("accid").toString();
        chanel_wangyi::m_account = strAccid.toStdString();
        chanel_wangyi::m_password = strToken.toStdString();
        chanel_wangyi::m_room_id = m_lessonId.toInt();
        return true;
    }
    else
    {
        qDebug() << ("Processing_C_channel::doGet_User_Name_pwd failed.") << dataObj;
        return false;
    }
}

// 初始化频道
bool Processing_C_Channel::initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                                       QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath)
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
    m_logFilePath = logFilePath;
    m_httpClient = YMHttpClientUtils::getInstance();
    m_httpUrl = m_httpClient->getRunUrl(1, m_strDllFile, m_strAppName);
    if(!doGet_User_Name_pwd())
    {
        qDebug() << "========== Processing_C_Channel doGet_User_Name_pwd() failed" <<__LINE__;
        return false;
    }
    if(m_role == TEACHER)
    {
        if(!doGet_Push_Url())
        {
            qDebug() << "========== Processing_C_Channel doGet_Push_Url() failed" <<__LINE__;
            return false;
        }
    }
    m_objChanelWangyi.slotInit(m_role, strSpeaker, strMicPhone, strCamera, m_token, m_strDllFile, m_strAppName);
    m_objChanelWangyi.slotLogin();
    return true;
}

// 进入频道
bool Processing_C_Channel::enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan)
{
    if(m_role == TEACHER)// 教师端
    {
        m_objChanelWangyi.slotCreateRoom();
    }
    else // 学生端或旁听
    {
        m_objChanelWangyi.slotJoinRoom();
    }
    return true;
}

// 离开频道
bool Processing_C_Channel::leaveChannel()
{
    m_objChanelWangyi.leaveRoom();
    return true;
}

// 打开本地视频
bool Processing_C_Channel::openLocalVideo()
{
   m_objChanelWangyi.Start_Device_Video();
   return true;
}

// 关闭本地视频
bool Processing_C_Channel::closeLocalVideo()
{
    m_objChanelWangyi.Stop_Device_Video();
    return true;
}

// 打开本地音频
bool Processing_C_Channel::openLocalAudio()
{
    m_objChanelWangyi.Start_Device_Audio();
    return true;
}

// 关闭本地音频
bool Processing_C_Channel::closeLocalAudio()
{
    m_objChanelWangyi.Stop_Device_Audio();
    return true;
}
