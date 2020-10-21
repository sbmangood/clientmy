#ifndef PROCESSING_A_CHANNEL_H
#define PROCESSING_A_CHANNEL_H

#include "../AudioVideoBase.h"
#include <QObject>
#include <QDebug>
#include <QString>
#include <QEventLoop>
#include "./include/IAgoraMediaEngine.h"
#include "./include/IAgoraRtcEngine.h"
#include "agoraengineeventhandler.h"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QApplication>
#include <QDebug>
#include "agorapacketobserver.h"

using namespace agora::rtc;
using namespace agora::media;
using namespace agora::util;

class Processing_A_Channel : public AudioVideoBase
{
    Q_OBJECT
private:
    explicit Processing_A_Channel();
    static Processing_A_Channel *m_processing_A_Channel;

public:
    virtual ~Processing_A_Channel();

    static  Processing_A_Channel *getInstance();

    virtual bool initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                             QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath);// 初始化频道
    virtual bool enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan = 0);// 进入频道
    virtual bool leaveChannel();// 离开频道
    virtual bool openLocalVideo();// 打开本地视频
    virtual bool closeLocalVideo();// 关闭本地视频
    virtual bool openLocalAudio();// 打开本地音频
    virtual bool closeLocalAudio();// 关闭本地音频

    QString Processing_A_Channel::getDefaultDevicesId(QString deviceKey);

private:
    void setDefaultDevice();// 设置默认设备属性
    const char* getJoinChannelKey(); // 获取加入频道时的key
    bool SetVideoCaptureType(int nType);// 声网的技术支持Nick推荐使用nType为3的设置 Capture Type  Windows平台设置成3
    int setFECParameters(bool preferSetFEC);// 是否开启FEC增强弱网对抗
    AgoraEngineEventHandler m_handler;
    AAudioDeviceManager * m_audioDevicemanager;
    IAudioDeviceCollection * m_recordDeviceCollection;
    IAudioDeviceCollection * m_audioPlayDeviceCollection;

    AVideoDeviceManager * m_videoDeviceManger;
    IVideoDeviceCollection * m_videoDeviceCollect;

    AgoraPacketObserver *m_observer;
    YMHttpClientUtils * m_httpClient;
    QString m_httpUrl;



public:
    static IRtcEngine * m_rtcEngine;
    QString m_channelKey;
    QString setAgoraLogFile();// 设置声网日志上传路径
};

#endif //PROCESSING_A_CHANNEL_H
