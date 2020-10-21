#ifndef PROCESSING_B_CHANNEL_H
#define PROCESSING_B_CHANNEL_H

#include "../AudioVideoBase.h"
#include <QCamera>
#include "CameraCapture.h"
#include "include/iLive.h"
#include "include/iLiveCommon.h"
#include "../AudioVideoUtils.h"

using namespace ilive;

class SignalClass : public QObject
{
    Q_OBJECT
public:
    SignalClass(QObject *parent = 0): QObject(parent) {}
    virtual ~SignalClass() {}

    static  SignalClass * getInstance()
    {
        static SignalClass * signalClass = new SignalClass();
        return signalClass;
    }
signals:
    void sigEventLoop();
};

class Processing_B_Channel : public AudioVideoBase
{
    Q_OBJECT
private:
    explicit Processing_B_Channel();
    static Processing_B_Channel *m_processing_B_Channel;

public:
    virtual ~Processing_B_Channel();

    static  Processing_B_Channel *getInstance();

    virtual bool initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                             QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath, ENVIRONMENT_TYPE enType);// 初始化频道
    virtual bool enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone,int videoSpan = 0);// 进入频道
    virtual bool leaveChannel();// 离开频道
    virtual bool openLocalVideo();// 打开本地视频
    virtual bool closeLocalVideo();// 关闭本地视频
    virtual bool openLocalAudio();// 打开本地音频
    virtual bool closeLocalAudio();// 关闭本地音频
    virtual int setUserRole(CLIENT_ROLE role);// 设置用户角色
    virtual int setVideoResolution(VIDEO_RESOLUTION resolution);// 设置视频分辨率

    static void oniLiveCreateRoomSuc(void *data); // 创建房间成功
    static void oniLiveCreateRoomErr(int code, const char *desc, void *data);// 创建房间失败
    static void oniLiveQuitRoomSuc(void *data);// 退出房间成功
    static void oniLiveQuitRoomErr(int code, const char *desc, void *data); // 退出房间失败
    static void oniLiveLoginSuccess(void *data);// 登录成功
    static void oniLiveLoginError(int code, const char *desc, void *data);// 登录错误
    void login();// 登录
    static void exitBLoginUserName();// 退出登录
    static void oniLiveLiveLogoutSuc(void *data);// 退出登录成功
    static void oniLiveLiveLogoutErr(int code, const char *desc, void *data);// 退出登录失败

    QString getDefaultDevicesId(QString deviceKey);
    static void onRemoteVideo(const LiveVideoFrame *video_frame, void *data);
    static void deviceOpraCallBack(E_DeviceOperationType oper, int retCode, void *data);

    //房间断开
    static void onRoomDisconnect(int reason, const char *errorInfo, void* data);
    static void onMemStatusChange(E_EndpointEventId event_id, const Vector<String> &ids, void *data);
    void receiveData(QImage image);// 抓取摄像头图片

private:
    QTimer *m_cameraImageTimes;
    CameraCapture * cam;
    QCamera *ca;
    int m_dateTime;
    Vector<Pair<String, String> > m_micList;
    QString m_qqSign;
    YMHttpClientUtils* m_httpClient;
    QString m_httpUrl;
    QString m_audioName;

public slots:
    void openCameraError(QCamera::Status err);
    void onUploadImageTime();
};
#endif
