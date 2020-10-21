#ifndef EXTERNALCALLCHANNCEL_H
#define EXTERNALCALLCHANNCEL_H

#include <QObject>
#include <QProcess>

#include "../../pc-common/AudioVideoSDKs/AudioVideoManager.h"
#include "..\dataconfig\datahandl\datamodel.h"

class ExternalCallChanncel : public QObject
{
        Q_OBJECT

    public:
        explicit ExternalCallChanncel(QObject *parent = 0);
        virtual ~ExternalCallChanncel();

        //初始化频道
        Q_INVOKABLE void initVideoChancel();

        //切换频道
        Q_INVOKABLE void changeChanncel();

        //关闭所有界面
        Q_INVOKABLE  void closeAlllWidget();

        //关闭音频
        Q_INVOKABLE void closeAudio(QString status);

        //关闭视频
        Q_INVOKABLE void closeVideo(QString status);

        //设置留在教室
        Q_INVOKABLE void  setStayInclassroom();

    signals:
        //测试音量
        void sigAudioVolumeIndication(unsigned int uid, int totalVolume );
        void createRoomFail();//加入音视频通道失败
        void sigAisleFinished();
        void sigCreateClassroom();
        void sigJoinroom(unsigned int uid,QString userId,int status);

    public slots:
        void sloJoinroom(unsigned int uid,int status);
};

#endif // EXTERNALCALLCHANNCEL_H
