#ifndef OPERATIONCHANNEL_H
#define OPERATIONCHANNEL_H

/*
 * 操作通道
 */
#include <QObject>
#include <iLive.h>
#include <QFile>
#include <QCoreApplication>
#include <QTimer>
#include <QCamera>
#include "cameracapture.h"
#include "./processingachannel.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"

using namespace ilive;

class SignalClass : public QObject
{
        Q_OBJECT
    public:
        SignalClass(QObject *parent = 0): QObject(parent) {}
        virtual ~SignalClass() {}

        static  SignalClass * gestance()
        {
            static SignalClass * signalClass = new SignalClass();
            return signalClass;
        }
    signals:
        void sigEventLoop();

    protected slots:


};

class OperationChannel : public QObject
{
        Q_OBJECT
    public:
        explicit OperationChannel(QObject *parent = 0);
        virtual ~OperationChannel();

        static OperationChannel * gestance();

    signals:
        void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);
        //测试音量
        void sigAudioVolumeIndication(unsigned int uid, int totalVolume );

        //通道切换完成信号
        void sigAisleFinish();

        //创建房间成功
        void sigCreateClassroom();

        //wayB creatRoomFail 腾讯创建加入房间失败
        void wayBCreateRoomFail();

    public slots:
        void openCameraError(QCamera::Status err);
        void onUploadImageTime();
    protected:
        //远程摄像头
        static void onRemoteVideo(const LiveVideoFrame *video_frame, void *data);

        //为了手动推送
        static void deviceOpraCallBack(E_DeviceOperationType oper, int retCode, void *data);
        //退出房间成功
        static void oniLiveQuitRoomSuc( void* data );
        //退出房间失败
        static void oniLiveQuitRoomErr( int code, const char * desc, void* data );

        //房间断开
        static void onRoomDisconnect(int reason, const char *errorInfo, void* data);
        static void onMemStatusChange(E_EndpointEventId event_id, const Vector<String> &ids, void *data);
        //创建房间成功
        static void oniLiveCreateRoomSuc(void* data);
        //创建房间失败
        static void oniLiveCreateRoomErr(int code, const char * desc, void* data);
        //离开教室
        static void oniLiveLoginSuccess(void* data);
        //离开教室错误
        static void oniLiveLoginError(int code, const char * desc, void* data);

        //退出登录成功
        static void oniLiveLiveLogoutSuc( void* data );
        //退出登录失败
        static void oniLiveLiveLogoutErr( int code, const char * desc, void* data );


    public:
        //初始化频道状态
        void initChannelStatus();

        //视频线路A初始化
        void initializeVideoViewWayA( );
        //视频线路A的退出
        void exitVideoViewWayA();
        //切换到wayA
        void exchangeToWayA();

        //初始化线路B
        bool initializeVideoViewWayB();
        //视频线路B的退出
        void exitVideoViewWayB();
        //切换到线路B
        void exchangeToWayB();
        //创建、加入房间
        void wayBCreateRoom();

        //设置b通道音频
        void setAudioModeWayB();
        //设置b通道视频显示模式
        void setVideoModeWayB();

        //改变频道
        void changeChanncel();

        //改变音频
        void changeAudio();

        //关闭音频
        void closeAudio(QString status);

        //关闭视频
        void closeVideo(QString status);
        //设置留在教室
        void  setStayInclassroom();

        //抓取摄像头图片
        void receiveData(QImage image);

        //旋转画面
        void doRender(QImage image);

    private:
        //退出教室 b
        void exitBLoginUserName();

        QString getDefaultDevicesId(QString deviceKey);

    private:
        ProcessingAchannel * m_processingAchannel;
        //Vector< Pair<String/*id*/, String/*name*/> >  m_cameraList;
        Vector< Pair<String/*id*/, String/*name*/> > m_micList;

    public:
        QTimer *m_cameraImageTimes;
        CameraCapture * cam;
        QCamera *ca;
        int m_dateTime;

    public:
        static  OperationChannel * m_operationChannel;
        static bool m_wayBIsVideoMode;
        bool m_isInitStartClass;//初始化状态
        bool m_isWaysA;//是否是a通道
        Vector< Pair<String/*id*/, String/*name*/> >  m_cameraList;
        YMHttpClient *m_httpClient;
        QString m_httpUrl;
};

#endif // OPERATIONCHANNEL_H
