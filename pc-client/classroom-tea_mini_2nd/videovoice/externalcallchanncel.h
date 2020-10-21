#ifndef EXTERNALCALLCHANNCEL_H
#define EXTERNALCALLCHANNCEL_H

#include <QObject>
#include <QProcess>
#include "../YMCommon/qosV2Manager/YMQosManager.h"
#include "..\dataconfig\datahandl\datamodel.h"

class ExternalCallChanncel : public QObject
{
    Q_OBJECT
public:
    explicit ExternalCallChanncel(QObject *parent = 0);
    virtual ~ExternalCallChanncel();

    Q_INVOKABLE void initVideoChancel();// 初始化频道
    Q_INVOKABLE void changeChanncel();// 切换频道
    Q_INVOKABLE void closeAudio(QString status);// 关闭音频
    Q_INVOKABLE void closeVideo(QString status);// 关闭视频
    Q_INVOKABLE void setStayInclassroom();// 设置留在教室
    Q_INVOKABLE void exitChannel();// 退出频道
    Q_INVOKABLE void closeAlllWidget();

signals:
    void sigAudioVolumeIndication(unsigned int uid, int totalVolume);// 测试音量
    void sigAisleFinished(bool);
    void createRoomFail();// 加入音视频通道失败
    void createRoomSucess();// 加入音视频通道成功
    void sigJoinroom(unsigned int uid, QString userId, int status);// 有用户加入或离开

public slots:
    //void sloJoinroom(unsigned int uid,int status);
    void sloAudioQuality(QString channel, QString frameValue, QString audioDelay, QString audioQuality);
};

#endif // EXTERNALCALLCHANNCEL_H
