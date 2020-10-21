#ifndef AUDIOVIDEO_H
#define AUDIOVIDEO_H

#include <QObject>
#include <QDebug>
#include <QTextCodec>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QDir>
#include <QStandardPaths>
#include "AudioVideoUtils.h"

// 角色类型
enum ROLE_TYPE
{
    STUDENT = 0,// 学生
    TEACHER = 1,// 教师
    AUDITOR = 2,// 旁听者
    ROLE_DEFAULT = STUDENT// 默认类型：学生
};

// 麦克风状态
enum MICROPHONE_STATE
{
    MICROPHONE_OFF = 0,// 麦克风关闭状态
    MICROPHONE_ON = 1,// 麦克风打开状态
    MICROPHONE_DEFAULT = MICROPHONE_OFF
};

// 摄像头状态
enum CAMERA_STATE
{
    CAMERA_OFF = 0,// 摄像头关闭状态
    CAMERA_ON = 1,// 摄像头打开状态
    CAMERA_DEFAULT = CAMERA_OFF
};

// 视频类型
enum VIDEO_TYPE
{
    VIDEO_OFF = 0,// 视频关闭
    VIDEO_OPEN = 1,// 视频打开
    VIDEO_DEFAULT = VIDEO_OFF
};

// 课程类型
enum COURSE_TYPE
{
    ONE_TO_ONE = 0,// 一对一
    SMALL_GROUP = 1,// 小组课
    AUDITION_LESSON = 2,// 试听课
    BIG_CLASS = 3,// 大班课
    COURSE_DEFAULT = ONE_TO_ONE
};

// 客户身份
enum CLIENT_ROLE
{
    BROADCASTER = 1,// 主播
    AUDIENCE = 2,// 观众
    CLIENT_DEFAULT = BROADCASTER
};

// 视频分辨率
enum VIDEO_RESOLUTION
{
    STANDARD_DEFINITION = 1,// 标清
    HIGH_DEFINITION = 2,// 高清
    SUPER_DEFINITION = 3,// 超清
    RESOLUTION_DEFAULT = STANDARD_DEFINITION
};

class AudioVideoBase: public QObject
{
    Q_OBJECT
public:
    AudioVideoBase(){}
    virtual ~AudioVideoBase(){}

    virtual bool initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                             QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath, ENVIRONMENT_TYPE enType) = 0;// 初始化频道

    virtual bool enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan = 0) = 0;// 进入频道
    virtual bool leaveChannel() = 0;// 离开频道
    virtual bool openLocalVideo() = 0;// 打开本地视频
    virtual bool closeLocalVideo() = 0;// 关闭本地视频
    virtual bool openLocalAudio() = 0;// 打开本地音频
    virtual bool closeLocalAudio() = 0;// 关闭本地音频
    virtual int setUserRole(CLIENT_ROLE role) = 0;// 设置用户角色
    virtual int setVideoResolution(VIDEO_RESOLUTION resolution) = 0;// 设置视频分辨率

protected:
    COURSE_TYPE m_courseType;// 课程类型
    ROLE_TYPE m_role;// 用户类型：0学生，1教师，2旁听
    QString m_userId;// 用户ID
    QString m_lessonId;// 课程ID
    QString m_apiVersion;// apiVersion
    QString m_appVersion;// appVersion
    QString m_token;// token
    QString m_logFilePath;// 日志文件路径
    QString m_camera;// 摄像头状态
    QString m_microphone;// 麦克风状态
    QString m_strDllFile;
    QString m_strAppName;

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);// 传送视频图片帧
    void sigAudioVolumeIndication(unsigned int uid, int totalVolume );// 测试音量
    void sigAudioName(QString audioName);
    void pushFrameRateToQos(QString channel, QString receivedFrameRate);// 发送帧率信息
    void pushAudioQualityToQos(QString channel, QString audioLost, QString audioDelay, QString audioQuality);// 发送音频质量信息
    void sigJoinOrLeaveRoom(unsigned int uid, int behavior);// behavior 1 进入，0离开
    void createRoomSucess();// 加入音视频通道成功信号
    void createRoomFail();// 加入音视频通道失败信号
};
#endif
