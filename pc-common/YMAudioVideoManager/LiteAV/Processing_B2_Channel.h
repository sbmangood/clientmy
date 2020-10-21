#ifndef PROCESSING_B2_CHANNEL_H
#define PROCESSING_B2_CHANNEL_H
#include <QCamera>
#include <QVector>
#include "../AudioVideoBase.h"
#include "CameraCapture.h"
#include "../AudioVideoUtils.h"
#include "include/TXLiteAVBase.h"
#include "include/TXLiteAVCode.h"
#include "include/ITXLiteAVNetworkProxy.h"
#include "include/TRTC/ITRTCCloud.h"
#include "include/TRTC/TRTCCloudCallback.h"
#include "include/TRTC/TRTCCloudDef.h"
#include "include/TRTC/TRTCStatistics.h"
#include "LiteAVVideoRenderCallback.h"

// 定义TRTC的导出函数指针
typedef ITRTCCloud* (*getTRTCShareInstanceMtd)();
typedef void(*destroyTRTCShareInstanceMtd)();

class Processing_B2_Channel : public AudioVideoBase, public ITRTCCloudCallback
{
    Q_OBJECT
private:
    explicit Processing_B2_Channel();
    static Processing_B2_Channel *m_Processing_B2_Channel;

public:
    virtual ~Processing_B2_Channel();

    static  Processing_B2_Channel *getInstance();

    virtual bool initChannel(COURSE_TYPE courseType, ROLE_TYPE role, QString userId, QString lessonId, QString camera, QString microphone, QString strSpeaker, QString strMicPhone, QString strCamera,
                             QString apiVersion, QString appVersion, QString token, QString strDllFile, QString strAppName, QString &logFilePath);// 初始化频道
    virtual bool enterChannel(const char *channelKey,const char *channelName, const char *info, unsigned int uid, QMap<QString, QPair<QString, QString>>& cameraPhone, int videoSpan = 0);// 进入频道
    virtual bool leaveChannel();// 离开频道
    virtual bool openLocalVideo();// 打开本地视频
    virtual bool closeLocalVideo();// 关闭本地视频
    virtual bool openLocalAudio();// 打开本地音频
    virtual bool closeLocalAudio();// 关闭本地音频

    // 重写父类ILiteAVCloudCallback的事件回调函数
    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* arg) override;
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg) override;
    virtual void onEnterRoom(uint64_t elapsed) override;
    virtual void onExitRoom(int reason) override;
    virtual void onUserEnter(const char* userId) override;
    virtual void onUserExit(const char* userId, int reason) override;

private:
    void receiveData(QImage image);// 抓取摄像头图片
    QString getDefaultDevicesId(QString deviceKey);

    LiteAVVideoRenderCallback *m_LiteAVVideoRenderCallback;

    bool getQQSign();
    QString m_trtcUserSig;// UserSig
    QString m_trtcRoomId;// RoomId
    QString m_trtcAppId;// AppId
    QString m_qqSign;

private:
    QTimer *m_cameraImageTimes;
    CameraCapture * cam;
    QCamera *ca;
    YMHttpClientUtils* m_httpClient;
    int m_dateTime;
    QString m_httpUrl;
    QString m_audioName;

    QVector<QString> v_userId;// 存储远端用户ID

    // TRTC
    HMODULE m_hLiteAV = nullptr;
    getTRTCShareInstanceMtd m_pGetTRTCShareInstance = nullptr;
    destroyTRTCShareInstanceMtd m_pDestroyTRTCShareInstance = nullptr;
    ITRTCCloud *m_pTrtcCloud = nullptr;

    int m_nWidth = 640;
    int m_nHeight = 368;
    int m_nLenYUV;
    unsigned char* m_lpBufferYUV;
    TRTCVideoFrame videoFrame;

public slots:
    void openCameraError(QCamera::Status err);
    void onUploadImage();// 上传图片到服务器

//    void slotUserEnter(QString userId);
//    void slotUserExit(QString userId);

signals:
    void wayBCreateRoomFail();
    void sigUserEnter(QString userId);
};
#endif
