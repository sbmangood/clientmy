#ifndef YMDEVICETESTMANAGER_H
#define YMDEVICETESTMANAGER_H
#include <QImage>
#include <QTime>
#include <QCoreApplication>
#include <QFile>
#include <QJsonArray>
#include <QStandardPaths>
#include <QDir>
#include <QSettings>
#include <QMutex>
#include "IDeviceTestCtrl.h"
#include "agora/agoraengineeventhandler.h"
#include "agora/agorapacketobserver.h"
#include "VideoFrameCapture.h"

class YMDeviceTestManager : public IDeviceTestCtrl
{
    Q_OBJECT
#if QT_VERSION >= 0x050000
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.IDeviceTestCtrl/1.0" FILE "YMDeviceTestManager.json")
    Q_INTERFACES(IDeviceTestCtrl)
#endif // QT_VERSION >= 0x050000
public:
    explicit YMDeviceTestManager();
    virtual ~YMDeviceTestManager();
    static YMDeviceTestManager *getInstance();
    static void release();

    virtual QJsonArray getUserDeviceList(int type);// 获取用户设备的摄像头、播放器、录音设备信息,根据type 1摄像头 2扬声器 3录音设备
    virtual void setCarmerDevice(QString deviceName);// 设置摄像设备
    virtual void setPlayerDevice(QString deviceName);// 设置播放设备
    virtual void setRecorderDevice(QString deviceName);// 设置录音设备
    virtual void startOrStopAudioTest(bool isStart);// 开始或停止声音测试
    virtual void startOrStopVideoTest(bool isStart); // 开始或停止视频测试
    virtual void startOrStopNetTest(bool isStart);// 开始或停止网络测试
    virtual void releaseDevice();// 释放设备

private:
    static YMDeviceTestManager* m_YMDeviceTestManager;
    QString getDocumentDir();
    void saveDeviceInformation(int type, QString value, QString strDeviceName);// 记录用户当前选择的设备
    VideoFrameCapture videoFrameCapture;
    QMutex m_mutex;

private:
    IRtcEngine *engine;
    AgoraEngineEventHandler handler;
    AgoraPacketObserver observer;
    agora::util::AutoPtr<agora::media::IMediaEngine> mediaEngine;
    AVideoDeviceManager *videoDeviceManger;
    IVideoDeviceCollection *videoDeviceCollect;
    AAudioDeviceManager *audioDeviceManger;
    IAudioDeviceCollection *audioDeviceCollection;
    QImage m_image;
    QVector<uchar> arr;
    QString tempName;
    QString fileDir;
    QString bufferFilePath;

public slots:
    void renderVideoFrame(unsigned int uid, int w, int h, int y, void *yb, int u, void *ub, int v, void *vb);
    void onRenderVideoFrame(QImage image);
};

#endif // YMDEVICETESTMANAGER_H
