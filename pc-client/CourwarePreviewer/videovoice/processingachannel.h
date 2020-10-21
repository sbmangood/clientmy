#ifndef PROCESSINGACHANNEL_H
#define PROCESSINGACHANNEL_H

/*
 * 处理a通道的视频
 */
#include <QObject>
#include <QDebug>

#include <QString>
#include <QEventLoop>
#include <IAgoraMediaEngine.h>
#include <IAgoraRtcEngine.h>
#include "agora/agoraengineeventhandler.h"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QApplication>
#include <QDebug>
#include "../dataconfig/datahandl/datamodel.h"
#include "./agora/agorapacketobserver.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"

using namespace agora::rtc;
using namespace agora::media;
using namespace agora::util;


class ProcessingAchannel : public QObject
{
        Q_OBJECT
    public:
        explicit ProcessingAchannel(QObject *parent = 0);
        virtual ~ProcessingAchannel();

    signals:
        void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);
        //测试音量
        void sigAudioVolumeIndication(unsigned int uid, int totalVolume );

    public slots:

    public:
        //是否开课
        void setInitStartClass(bool status);
        void setAgoraLogFile();

        //进入频道
        bool joinChannel(const char *channelName, const char *info, uid_t uid);
        //离开频道
        bool leaveChannel();
        //切换到wayA
        void exchangeToWaysA();
        /*
         * 打开与关闭本地音频
         *   @stsuts: true为关闭 false为打开
         *
         */
        bool disableOrEnableAudio(bool stsuts);
        /*
         * 打开与关闭本地视频
         *   @stsuts: true为关闭 false为打开
         *
         */
        bool disableOrEnableVideo(bool stsuts);

        //设置音频
        void setAudioMode();
        //设置视频
        void setVideoMode();


    private:
        //设置默认属性
        void setDefaultDevice();

        QString getDefaultDevicesId(QString deviceKey);
        //获取加入频道时的key
        const char * getJoinChannelKey(const char * channelName, uid_t userId);


    private:
        AgoraEngineEventHandler m_handler;
        IRtcEngine * m_rtcEngine;
        AAudioDeviceManager * m_audioDevicemanager;
        IAudioDeviceCollection * m_recordDeviceCollection;
        IAudioDeviceCollection * m_audioPlayDeviceCollection;

        AVideoDeviceManager * m_videoDeviceManger;
        IVideoDeviceCollection * m_videoDeviceCollect;

        AgoraPacketObserver m_observer;
        bool m_currentModeVideo;
        bool m_isInitStartClass;//初始化状态

        YMHttpClient * m_httpClient;
        QString m_httpUrl;
};

#endif // PROCESSINGACHANNEL_H
