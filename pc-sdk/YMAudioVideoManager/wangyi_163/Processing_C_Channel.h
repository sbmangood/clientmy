#ifndef PROCESSING_C_CHANNEL_H
#define PROCESSING_C_CHANNEL_H

#include "../AudioVideoBase.h"
#include "channel_wangyi.h"
#include <QMap>
#include <QStringList>
#include <QCryptographicHash>
#include <QIODevice>

class Processing_C_Channel : public AudioVideoBase
{
    Q_OBJECT
private:
    explicit Processing_C_Channel();
    static Processing_C_Channel *m_processing_C_Channel;

public:
    virtual ~Processing_C_Channel();

    static  Processing_C_Channel *getInstance();

    virtual bool initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                             QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath, ENVIRONMENT_TYPE enType);// 初始化频道
    virtual bool enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan = 0);// 进入频道
    virtual bool leaveChannel();// 离开频道
    virtual bool openLocalVideo();// 打开本地视频
    virtual bool closeLocalVideo();// 关闭本地视频
    virtual bool openLocalAudio();// 打开本地音频
    virtual bool closeLocalAudio();// 关闭本地音频
    virtual int setUserRole(CLIENT_ROLE role);// 设置用户角色
    virtual int setVideoResolution(VIDEO_RESOLUTION resolution);// 设置视频分辨率

public:
    bool doGet_User_Name_pwd(); // 得到网易C通道的用户名, 密码
    bool doGet_Push_Url();      // 得到网易C通道的录播推流地址
signals:
    void sigChangeChannel(QJsonObject changeChannelObj);
private:
    chanel_wangyi m_objChanelWangyi;
    YMHttpClientUtils *m_httpClient;
    QString m_httpUrl;
};

#endif
