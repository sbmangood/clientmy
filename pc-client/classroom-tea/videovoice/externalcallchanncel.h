#ifndef EXTERNALCALLCHANNCEL_H
#define EXTERNALCALLCHANNCEL_H

#include <QObject>
#include <QProcess>
#include "../../../pc-common/AudioVideoSDKs/AudioVideoManager.h"
#include "../../../pc-common/AudioVideoSDKs/AudioVideoUtils.h"
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

    private:
        QString getJoinChannelKey();
        YMHttpClientUtils * m_httpClient;
        QString m_httpUrl;


    signals:
        //测试音量
        void sigAudioVolumeIndication(unsigned int uid, int totalVolume );
        void sigAisleFinished(bool isSuccess);
        void sigCreateClassroom();
        void createRoomFail();//加入音视频通道失败
        void createRoomSucess();// 加入音视频通道成功信号
        void sigRequestVideoSpan();// 发送腾讯V2 videoSpan请求


    public slots:
        void sigAudioName(QString audioName);// 录播
        void slotAisleFinished(bool isSuccess);
        void getAudioVideoStatus(QString channel, QString audioLost, QString audioDelay, QString audioQuality);
    public:
        Q_INVOKABLE void enterChannelV2(QString videoSpan);// 进入V2

    private:
        // 用户ID
        QString m_userId;
        // 课程ID
        QString m_lessonId;
        QString m_apiVersion;
        QString m_appVersion;
        QString m_token;
        QString m_strSpeaker;
        QString m_strMicPhone;
        QString m_strCamera;
        QString m_strDllFile;
        QString m_strAppName;
        QString m_channelKey;
        QString m_channelName;
        bool m_isStartClass;
        CHANNEL_TYPE m_currentChannel;
        bool m_isChangeSuccess;

};

#endif // EXTERNALCALLCHANNCEL_H
