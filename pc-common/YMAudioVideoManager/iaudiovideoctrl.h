#ifndef IAUDIOVIDEOCTRL_H
#define IAUDIOVIDEOCTRL_H

#include <QString>
#include "AudioVideoBase.h"
#include <QObject>

// 通道类型
enum CHANNEL_TYPE
{
    CHANNEL_0 = 0,  // 待定义
    CHANNEL_A = 1,  // A通道, 声网 agora
    CHANNEL_B = 2,  // B通道, 腾讯 iLive
    CHANNEL_B2 = 3,  // B2通道, 腾讯 LiteAV
    CHANNEL_C = 4,   // C通道, 网易 wangyi_163
    CHANNEL_DEFAULT = CHANNEL_A
};

class IAudioVideoCtrl : public QObject
{
    Q_OBJECT
public:
    virtual void changeChanncel(CHANNEL_TYPE currentChannel, QString videoType, QString microphoneState, QString cameraState,
                        ROLE_TYPE role, QString userId, QString lessonId, QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath,
                        QString strSpeaker, QString strMicPhone, QString strCamera, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan,QString channelKey,QString channelName,
                        COURSE_TYPE courseType = ONE_TO_ONE) = 0;// 切换频道
    virtual void openLocalVideo() = 0;// 打开本地视频
    virtual void closeLocalVideo() = 0;// 关闭本地视频
    virtual void openLocalAudio() = 0;// 打开本地音频
    virtual void closeLocalAudio() = 0;// 关闭本地音频
    virtual void exitChannel() = 0;// 退出频道
    virtual void setStayInclassroom() = 0;// 设置留在教室
signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);// 传送视频图片帧的信号
    void sigJoinOrLeaveRoom(unsigned int uid, int behavior);// behavior 1 进入，0离开
};

Q_DECLARE_INTERFACE(IAudioVideoCtrl,"org.qt-project.Qt.Plugin.IAudioVideoCtrl/1.0")
#endif // IAUDIOVIDEOCTRL_H