#include "agoraengineeventhandler.h"
#include <QDebug>

AgoraEngineEventHandler::AgoraEngineEventHandler(QObject *parent) : QObject(parent)
{


}

void AgoraEngineEventHandler::onJoinChannelSuccess(const char *channel, uid_t uid, int elapsed)
{
    //qDebug()<<"onJoinChannelSuccess"<<channel<<uid;
    QVariantList data;
    data << channel << uid << elapsed;
    //qDebug()<<data.at(1).toString()<<"onJoinChannelsuccess emit data test";
    //emit joinChannelSuccess(data);
}

void AgoraEngineEventHandler::onRejoinChannelSuccess(const char *channel, uid_t uid, int elapsed)
{
    //qDebug()<<"onReJoinChannelSuccess"<<channel<<uid;
}

void AgoraEngineEventHandler::onWarning(int warn, const char *msg)
{
    //qDebug() << "warn:" << warn << *msg;
}

void AgoraEngineEventHandler::onError(int err, const char *msg)
{
    //qDebug() << "err:" << err << *msg;
}

void AgoraEngineEventHandler::onAudioQuality(uid_t uid, int quality, unsigned short delay, unsigned short lost)
{
    QString ids = QString("%1").arg(uid);
    QString contents = QString("%1,%2,%3").arg(quality).arg(delay).arg(lost);

    TemporaryParameter::gestance()->m_ipContents[ids] = contents;
    // QString str = QString("%1  , %2 , %3 , %4 ").arg(uid).arg(quality).arg(delay).arg(lost);
    //  qDebug()<<str;
}

void AgoraEngineEventHandler::onAudioVolumeIndication(const AudioVolumeInfo *speakers, unsigned int speakerNumber, int totalVolume)
{

    //  qDebug()<<"speakers->uid  == "<<speakers->uid << "speakerNumber =="<<speakerNumber<<"totalVolume =="<<totalVolume;
    int lens = totalVolume * 8 / 255 ;
    emit sigAudioVolumeIndication(speakers->uid, lens);
}

void AgoraEngineEventHandler::onLeaveChannel(const RtcStats &stat)
{
    //qDebug()<<"leave channel"<<stat.users;
    emit onLeaveChannelSignal();
}

void AgoraEngineEventHandler::onRtcStats(const RtcStats &stat)
{
    TemporaryParameter::gestance()->bitRate = QString::number(stat.rxKBitRate);
}

void AgoraEngineEventHandler::onMediaEngineEvent(int evt)
{

}

void AgoraEngineEventHandler::onAudioDeviceStateChanged(const char *deviceId, int deviceType, int deviceState)
{

}

void AgoraEngineEventHandler::onVideoDeviceStateChanged(const char *deviceId, int deviceType, int deviceState)
{

}

void AgoraEngineEventHandler::onLastmileQuality(int quality)
{

}

void AgoraEngineEventHandler::onFirstLocalVideoFrame(int width, int height, int elapsed)
{

}

void AgoraEngineEventHandler::onFirstRemoteVideoDecoded(uid_t uid, int width, int height, int elapsed)
{

}

void AgoraEngineEventHandler::onFirstRemoteVideoFrame(uid_t uid, int width, int height, int elapsed)
{

}

void AgoraEngineEventHandler::onUserJoined(uid_t uid, int elapsed)
{
    QVariantList data;
    data << uid << elapsed;
    //qDebug()<<"uids =onUserJoined="<<uid;
    //qDebug()<<QString("Student %1 JoinChannel").arg(QString::number(uid));
    //emit studentJoinChannelsuccess(data);
    TemporaryParameter::gestance()->insertIntoOnlineId(uid);
}

void AgoraEngineEventHandler::onUserOffline(uid_t uid, USER_OFFLINE_REASON_TYPE reason)
{
    //qDebug()<<"uid =onUserOffline="<<uid;
    TemporaryParameter::gestance()->removeOnlineId(uid);


}

void AgoraEngineEventHandler::onUserMuteAudio(uid_t uid, bool muted)
{

}

void AgoraEngineEventHandler::onUserMuteVideo(uid_t uid, bool muted)
{

}

void AgoraEngineEventHandler::onApiCallExecuted(const char *api, int error)
{

}

void AgoraEngineEventHandler::onStreamMessage(uid_t uid, int streamId, const char *data, size_t length)
{

}

void AgoraEngineEventHandler::onLocalVideoStats(const LocalVideoStats &stats)
{
    //qDebug()<<"AgoraEngineEventHandler::onLocalVideoStats";
}

void AgoraEngineEventHandler::onRemoteVideoStats(const RemoteVideoStats &stats)
{
    //qDebug()<<"AgoraEngineEventHandler::onRemoteVideoStats";
}

void AgoraEngineEventHandler::onCameraReady()
{
    //qDebug()<<"carmer ready";
}

void AgoraEngineEventHandler::onVideoStopped()
{

}

void AgoraEngineEventHandler::onConnectionLost()
{

}

void AgoraEngineEventHandler::onConnectionInterrupted()
{

}

void AgoraEngineEventHandler::onUserEnableVideo(uid_t uid, bool enabled)
{

}

void AgoraEngineEventHandler::onStartRecordingService(int error)
{

}

void AgoraEngineEventHandler::onStopRecordingService(int error)
{

}

void AgoraEngineEventHandler::onRefreshRecordingServiceStatus(int status)
{

}
