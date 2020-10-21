#include "externalcallchanncel.h"
#include "debuglog.h"

ExternalCallChanncel::ExternalCallChanncel(QObject *parent): QObject(parent)
{
    connect(AudioVideoManager::getInstance(), SIGNAL(sigAudioVolumeIndication(unsigned int, int)), this, SIGNAL(sigAudioVolumeIndication(unsigned int, int)));
    connect(AudioVideoManager::getInstance(), SIGNAL(sigAisleFinish()), this, SIGNAL(sigAisleFinished()));
    connect(AudioVideoManager::getInstance(), SIGNAL(sigCreateClassroom()), this, SIGNAL(sigCreateClassroom()));
    connect(AudioVideoManager::getInstance(), SIGNAL(wayBCreateRoomFail()), this, SIGNAL(createRoomFail()));
    connect(AudioVideoManager::getInstance(), SIGNAL(sigJoinOrLeaveRoom(uint,int)),this,SLOT(sloJoinroom(uint,int)));
}

ExternalCallChanncel::~ExternalCallChanncel(){}

//初始化频道
void ExternalCallChanncel::initVideoChancel()
{
    changeChanncel();
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
    QString strSpeaker = AudioVideoManager::getInstance()->getDefaultDevicesId("player_device_name");
    QString strMicPhone = AudioVideoManager::getInstance()->getDefaultDevicesId("recorder_device_name");;
    QString strCamera = AudioVideoManager::getInstance()->getDefaultDevicesId("carmer");
    QString m_strDllFile = StudentData::gestance()->strAppFullPath;
    QString m_strAppName = StudentData::gestance()->strAppName;
    QString channelKey = StudentData::gestance()->m_agoraChannelKey;
    QString channelName = StudentData::gestance()->m_agoraChannelName;
    int videoSpan = 0;
    AudioVideoManager::getInstance()->changeChanncel(currentChannel, videoType, microphoneState, cameraState,
                                                        role, userId, lessonId, apiVersion, appVersion, token, m_strDllFile, m_strAppName, StudentData::gestance()->strAgoraFullPath_LogFile,
                                                        strSpeaker, strMicPhone, strCamera, StudentData::gestance()->m_cameraPhone,videoSpan,channelKey,channelName, SMALL_GROUP);
}

//关闭所有界面
void ExternalCallChanncel::closeAlllWidget()
{
    qDebug() << "ExternalCallChanncel::closeAlllWidget";
    //================================
    //先上传日志, 再退出所有通道(防止退出通道的时候, 程序出错, 导致日志没有上传)
    DebugLog::GetInstance()->doUpgrade_LocalLogInfo_To_Server(); //关闭进程前, 需要上传日志文件
    AudioVideoManager::getInstance()->exitChannel(); //关闭进程前, 需要是否音视频的资源, 不然下次进去, 可能有问题, 尤其是C通道
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

void ExternalCallChanncel::sloJoinroom(unsigned int uid, int status)
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
