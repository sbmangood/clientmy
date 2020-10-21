#include "agoraengineeventhandler.h"
#include "Processing_A_Channel.h"
#include <QDebug>

AgoraEngineEventHandler::AgoraEngineEventHandler(QObject *parent) : QObject(parent){}


void AgoraEngineEventHandler::onJoinChannelSuccess(const char *channel, uid_t uid, int elapsed){}


void AgoraEngineEventHandler::onAudioQuality(uid_t uid, int quality, unsigned short delay, unsigned short lost)
{
    emit Processing_A_Channel::getInstance()->pushAudioQualityToQos("agora", QString::number(lost),QString::number(delay),QString::number(quality));
}

void AgoraEngineEventHandler::onRemoteVideoStats(const RemoteVideoStats &stats)
{
    emit Processing_A_Channel::getInstance()->pushFrameRateToQos("agora", QString::number(stats.receivedFrameRate));
}

void AgoraEngineEventHandler::onAudioVolumeIndication(const AudioVolumeInfo *speakers, unsigned int speakerNumber, int totalVolume)
{
    int lens = totalVolume * 8 / 255 ;
    emit sigAudioVolumeIndication(speakers->uid, lens);
}

void AgoraEngineEventHandler::onLeaveChannel(const RtcStats &stat)
{
    emit onLeaveChannelSignal();
}


void AgoraEngineEventHandler::onRtcStats(const RtcStats &stat)
{

}

void AgoraEngineEventHandler::onFirstRemoteVideoFrame(uid_t uid, int width, int height, int elapsed)
{

}

void AgoraEngineEventHandler::onUserJoined(uid_t uid, int elapsed)
{
    emit Processing_A_Channel::getInstance()->sigJoinOrLeaveRoom(uid, 1);
}

void AgoraEngineEventHandler::onUserOffline(uid_t uid, USER_OFFLINE_REASON_TYPE reason)
{
    emit Processing_A_Channel::getInstance()->sigJoinOrLeaveRoom(uid, 0);
}
