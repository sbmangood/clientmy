#ifndef YMAUDIOVIDEOMANAGER_H
#define YMAUDIOVIDEOMANAGER_H

#include <QtCore/qglobal.h>
#include <QObject>
#include <QTextCodec>
#include <QImage>
#include <QFile>
#include <QCoreApplication>
#include "iaudiovideoctrl.h"
#include "agora/Processing_A_Channel.h"
#include "iLiveSDK/Processing_B_Channel.h"
#include "LiteAV/Processing_B2_Channel.h"
#include "wangyi_163/Processing_C_Channel.h"
#include "beautyManager/Beautymanager.h"

class YMAudioVideoManager : /*public QObject, */public IAudioVideoCtrl
{
    Q_OBJECT
#if QT_VERSION >= 0x050000
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.IAudioVideoCtrl/1.0" FILE "audiovideomanager.json")
    Q_INTERFACES(IAudioVideoCtrl)
#endif // QT_VERSION >= 0x050000
public:
    explicit YMAudioVideoManager();
    virtual ~YMAudioVideoManager();
    static YMAudioVideoManager *getInstance();
    static void release();

    void changeChanncel(CHANNEL_TYPE currentChannel, QString videoType, QString microphoneState, QString cameraState,
                        ROLE_TYPE role, QString userId, QString lessonId, QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath,
                        QString strSpeaker, QString strMicPhone, QString strCamera, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan,QString channelKey,QString channelName,
                        COURSE_TYPE courseType = ONE_TO_ONE, ENVIRONMENT_TYPE enType = API);// 切换频道
    void openLocalVideo();// 打开本地视频
    void closeLocalVideo();// 关闭本地视频
    void openLocalAudio();// 打开本地音频
    void closeLocalAudio();// 关闭本地音频
    void exitChannel();// 退出频道
    void setStayInclassroom();// 设置留在教室

    void enableBeauty(bool isBeauty);// 设置美颜
    bool getBeautyIsOn();// 获取美颜开关状态

    int setUserRole(CLIENT_ROLE role);// 设置用户角色
    int setVideoResolution(VIDEO_RESOLUTION resolution);// 设置视频分辨率

    MICROPHONE_STATE microphoneState;// 麦克风状态
    CAMERA_STATE cameraState;// 摄像头状态
    QString m_supplier; // 当前通道
    QString m_videoType; // 当前音频
    QString m_tempSupplier = "1";

    QString getDefaultDevicesId(QString deviceKey);

private:
    static YMAudioVideoManager *m_YMAudioVideoManager;

    AudioVideoBase *m_processingchannel;
    QString m_httpUrl;
    CHANNEL_TYPE m_preChannel = CHANNEL_0; // 记录上一个channnel id,切换通道的时候, 只关闭上一个的channel，默认是0,因为第一次进来的时候, 原来的通道是0保证和当前的通道, 不一样

    ROLE_TYPE m_role;// 用户类型：0学生，1教师，2旁听
    QString m_userId;// 用户ID
    QString m_lessonId;// 课程ID
    QString m_apiVersion;// apiVersion
    QString m_appVersion;// appVersion
    QString m_token;// token
    QString m_logFilePath;// 日志文件路径
    QString m_audioName;

    // 美颜管理
    BeautyManager *beautyManager;
    QImage m_imge;

signals:

public slots:
    void slotCreateRoomFail();
    void slotCreateRoomSuccess();
    void onRenderVideoFrameImage(unsigned int uid, QImage image, int rotation);
private:
    bool m_isSuccess;// 是否切换成功
};

#endif // YMAUDIOVIDEOMANAGER_H
