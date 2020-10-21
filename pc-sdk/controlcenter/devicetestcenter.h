#ifndef DEVICETESTCENTER_H
#define DEVICETESTCENTER_H
#include <QObject>
#include "controlcenter.h"
#include "../YMDeviceTestManager/IDeviceTestCtrl.h"

class DeviceTestCenter : public QObject
{
    Q_OBJECT
public:
    explicit DeviceTestCenter(ControlCenter* controlCenter);
    virtual ~DeviceTestCenter();

    void init(const QString &pluginPathName);
    void uninit();

    QJsonArray getUserDeviceList(int type);// 获取用户设备的摄像头、播放器、录音设备信息,根据type 1摄像头 2扬声器 3录音设备
    void setCarmerDevice(QString deviceName);// 设置摄像设备
    void setPlayerDevice(QString deviceName);// 设置播放设备
    void setRecorderDevice(QString deviceName);// 设置录音设备
    void startOrStopAudioTest(bool isStart);// 开始或停止声音测试
    void startOrStopVideoTest(bool isStart); // 开始或停止视频测试
    void startOrStopNetTest(bool isStart);// 开始或停止网络测试
    void releaseDevice();// 释放设备

private:
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

signals:
    void netQuailty(int quality);// 网络质量
    void renderVideoImage(QString fileName);// 图片改变信号
    void carmeraReady();// 摄像头准备就绪
    void noCarmerDevices();// 无可用摄像设备
    void speakerVolume(int volume, int speakerId); // 当前音量

private:
    ControlCenter *m_controlCenter;
    IDeviceTestCtrl *m_IDeviceTestCtrl;
};

#endif // DEVICETESTCENTER_H
