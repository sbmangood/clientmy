#ifndef AGORAENGINEEVENTHANDLER_H
#define AGORAENGINEEVENTHANDLER_H

#include <QObject>
#include <QStringList>
#include <QVariant>
#include <QVariantList>
#include <QDebug>
#include <QFile>
#include <QCoreApplication>
#include <QIODevice>
#include <QStandardPaths>
#include "include/IAgoraRtcEngine.h"

using namespace agora::rtc;

class AgoraEngineEventHandler : public QObject, public IRtcEngineEventHandler
{
        Q_OBJECT
    public:
        explicit AgoraEngineEventHandler(QObject *parent = 0);

        virtual void onJoinChannelSuccess(const char* channel, uid_t uid, int elapsed);
        virtual void onAudioQuality(uid_t uid, int quality, unsigned short delay, unsigned short lost);     
        virtual void onAudioVolumeIndication(const AudioVolumeInfo* speakers, unsigned int speakerNumber, int totalVolume);
        virtual void onLeaveChannel(const RtcStats& stat); 
        virtual void onRtcStats(const RtcStats& stat);
        virtual void onFirstRemoteVideoFrame(uid_t uid, int width, int height, int elapsed);
        virtual void onUserJoined(uid_t uid, int elapsed);
        virtual void onUserOffline(uid_t uid, USER_OFFLINE_REASON_TYPE reason);
        virtual void onRemoteVideoStats(const RemoteVideoStats &stats);
    signals:
        void onLeaveChannelSignal();// 离开频道信号
        void sigAudioVolumeIndication(unsigned int uid, int totalVolume );// 测试音量信号

    public slots:

};

#endif // AGORAENGINEEVENTHANDLER_H
