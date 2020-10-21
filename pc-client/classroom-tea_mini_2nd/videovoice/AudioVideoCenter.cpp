#include <QPluginLoader>
#include <QQmlContext>
#include "audiovideocenter.h"
#include "VideoRender.h"

AudioVideoCenter* AudioVideoCenter::m_audiovideocenter = NULL;

AudioVideoCenter::AudioVideoCenter(QObject *parent) :QObject(parent), m_IAudioVideoCtrl(nullptr)
{
    qmlRegisterType<VideoRender>("VideoRender", 1, 0, "VideoRender");
}

AudioVideoCenter* AudioVideoCenter::getInstance()
{
    if(NULL == m_audiovideocenter)
    {
        m_audiovideocenter = new AudioVideoCenter();
    }
    return m_audiovideocenter;
}

AudioVideoCenter::~AudioVideoCenter()
{
    uninit();
}

void AudioVideoCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("YMAudioVideoManager.dll", Qt::CaseInsensitive))
    {
        QObject* instance = loadPlugin(pluginPathName);
        if(instance)
        {
            m_IAudioVideoCtrl = qobject_cast<IAudioVideoCtrl *>(instance);
            if(nullptr == m_IAudioVideoCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(instance);
                return;
            }
            connect(m_IAudioVideoCtrl, SIGNAL(renderVideoFrameImage(uint, QImage, int)), this, SIGNAL(renderVideoFrameImage(uint, QImage, int)));
            connect(m_IAudioVideoCtrl, SIGNAL(hideBeautyButton()), this, SIGNAL(hideBeautyButton()));
            connect(m_IAudioVideoCtrl, SIGNAL(sigJoinOrLeaveRoom(uint, int)), this, SLOT(slotJoinroom(uint, int)));
            connect(m_IAudioVideoCtrl, SIGNAL(sigAudioVolumeIndication(unsigned int, int)), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int)));
            connect(m_IAudioVideoCtrl, SIGNAL(sigAisleFinish(bool)), this, SIGNAL(sigAisleFinished(bool)));
            connect(m_IAudioVideoCtrl, SIGNAL(createRoomFail()), this, SIGNAL(createRoomFail()));
            connect(m_IAudioVideoCtrl, SIGNAL(createRoomSucess()), this, SIGNAL(createRoomSucess()));
            connect(m_IAudioVideoCtrl, SIGNAL(pushAudioQualityToQos(QString, QString, QString, QString)), this, SIGNAL(pushAudioQualityToQos(QString, QString, QString, QString)));
            qDebug()<< "qobject_cast is success, pluginPathName is" << pluginPathName;
        }
        else
        {
            qCritical()<< "load plugin is failed, pluginPathName is" << pluginPathName;
        }
    }
    else
    {
        qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
    }
}

void AudioVideoCenter::uninit()
{
    if(m_IAudioVideoCtrl)
    {
        //        unloadPlugin((QObject*)m_IAudioVideoCtrl);
        //        m_IAudioVideoCtrl = nullptr;
    }
}

void AudioVideoCenter::initVideoChancel()// 初始化频道
{
    changeChanncel();
}

void AudioVideoCenter::changeChanncel()// 切换频道
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
        currentChannel = CHANNEL_B;
    }
    else if(supplier == "3")
    {
        currentChannel = CHANNEL_C;
    }
    // 视频类型：视频或音频
    QString videoType =  TemporaryParameter::gestance()->m_videoType;
    //bool isStartClass = TemporaryParameter::gestance()->m_isStartClass;
    // 麦克风状态
    QString microphoneState =  StudentData::gestance()->getUserPhone(StudentData::gestance()->m_selfStudent.m_studentId);
    // 摄像头状态
    QString cameraState = StudentData::gestance()->m_camera;
    // 角色：教师、学生、旁听
    QString plat = "T";
    ROLE_TYPE role;
    if(plat == "T")
    {
        role = TEACHER;
    }
    else if(plat == "L")
    {
        role = AUDITOR;
    }
    else
    {
        role = STUDENT;
    }
    // 用户ID
    QString userId = StudentData::gestance()->m_agoraUid;//.m_studentId;
    // 课程ID
    QString lessonId = StudentData::gestance()->m_lessonId;
    QString apiVersion = StudentData::gestance()->m_apiVersion;
    QString appVersion = StudentData::gestance()->m_appVersion;
    QString token = StudentData::gestance()->m_token;
    QString strSpeaker = getDefaultDevicesId("player_device_name");
    QString strMicPhone = getDefaultDevicesId("recorder_device_name");;
    QString strCamera = getDefaultDevicesId("carmer");
    QString m_strDllFile = StudentData::gestance()->strAppFullPath;
    QString m_strAppName = StudentData::gestance()->strAppName;
    QString channelKey = StudentData::gestance()->m_agoraChannelKey;
    QString channelName = StudentData::gestance()->m_agoraChannelName;
    int videoSpan = 0;
    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->changeChanncel(currentChannel, videoType, microphoneState, cameraState,
                                          role, userId, lessonId, apiVersion, appVersion, token, m_strDllFile, m_strAppName, StudentData::gestance()->strAgoraFullPath_LogFile,
                                          strSpeaker, strMicPhone, strCamera, StudentData::gestance()->m_cameraPhone,videoSpan,channelKey,channelName, SMALL_GROUP);
    }
}

void AudioVideoCenter::closeAudio(QString status)// 关闭音频
{
    if(NULL != m_IAudioVideoCtrl)
    {
        if(status == "0")
        {
            m_IAudioVideoCtrl->closeLocalAudio();
        }
        else
        {
            m_IAudioVideoCtrl->openLocalAudio();
        }
    }
}

void AudioVideoCenter::closeVideo(QString status)// 关闭视频
{
    if(NULL != m_IAudioVideoCtrl)
    {
        if(status == "0")
        {
            m_IAudioVideoCtrl->closeLocalVideo();
        }
        else
        {
            m_IAudioVideoCtrl->openLocalVideo();
        }
    }
}

void AudioVideoCenter::setStayInclassroom()// 设置留在教室
{
    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->setStayInclassroom();
    }
}

void AudioVideoCenter::exitChannel()
{
    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->exitChannel();
    }
}

void AudioVideoCenter::enableBeauty(bool isBeauty)// 设置美颜
{
    qDebug()<<"========AudioVideoCenter::enableBeauty======="<<isBeauty;
    if(NULL != m_IAudioVideoCtrl)
    {
        m_IAudioVideoCtrl->enableBeauty(isBeauty);
    }
}

bool AudioVideoCenter::getBeautyIsOn()// 得到美颜状态
{
    if(NULL != m_IAudioVideoCtrl)
    {
        return m_IAudioVideoCtrl->getBeautyIsOn();
    }
    return false;
}

void AudioVideoCenter::slotJoinroom(unsigned int uid, int status)
{
    qDebug() << "===sloJoinroom==" << uid << status;
    for(int i = 0; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(StudentData::gestance()->m_student.at(i).m_uid == uid)
        {
            StudentData::gestance()->m_student[i].m_isVideo = "1";
            QString userId = StudentData::gestance()->m_student[i].m_studentId;
            StudentData::gestance()->insertIntoOnlineId(userId);
            emit sigJoinroom(uid,userId,status);
            qDebug() << "=====uids=====" << uid << userId << StudentData::gestance()->m_student[i].m_isVideo;
            break;
        }
    }
}

QString AudioVideoCenter::getDefaultDevicesId(QString deviceKey)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString systemPublicFilePath;
    QDir dir;
    if (docPath == "" || !dir.exists(docPath)) //docPath是空, 或者不存在
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "/YiMi/temp/";
    QDir isDir;
    // 设置顶端配置路径
    if (!isDir.exists(systemPublicFilePath))
    {
        isDir.mkpath(systemPublicFilePath);
        return "";
    }
    QSettings deviceSetting(systemPublicFilePath + "deviceInfo.dll", QSettings::IniFormat);
    deviceSetting.setIniCodec(QTextCodec::codecForName("UTF-8"));
    deviceSetting.beginGroup("Device");
    return deviceSetting.value(deviceKey).toString();
}


QObject* AudioVideoCenter::loadPlugin(const QString &pluginPath)
{
    QObject *plugin = nullptr;
    QFile file(pluginPath);
    if (!file.exists())
    {
        qWarning()<< pluginPath<< "file is not file";
        return plugin;
    }

    QPluginLoader loader(pluginPath);
    plugin = loader.instance();
    if (nullptr == plugin)
    {
        qCritical()<< pluginPath<< "failed to load plugin" << loader.errorString();
    }

    return plugin;
}

void AudioVideoCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}

