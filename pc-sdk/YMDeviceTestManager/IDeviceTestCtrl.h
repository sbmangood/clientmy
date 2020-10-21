#ifndef IDEVICETESTCRTL_H
#define IDEVICETESTCRTL_H
#include <QObject>
#include <QJsonArray>

class IDeviceTestCtrl : public QObject
{
    Q_OBJECT
public:
    virtual QJsonArray getUserDeviceList(int type) = 0;// 获取用户设备的摄像头、播放器、录音设备信息,根据type 1摄像头 2扬声器 3录音设备
    virtual void setCarmerDevice(QString deviceName) = 0;// 设置摄像设备
    virtual void setPlayerDevice(QString deviceName) = 0;// 设置播放设备
    virtual void setRecorderDevice(QString deviceName) = 0;// 设置录音设备
    virtual void startOrStopAudioTest(bool isStart) = 0;// 开始或停止声音测试
    virtual void startOrStopVideoTest(bool isStart) = 0; // 开始或停止视频测试
    virtual void startOrStopNetTest(bool isStart) = 0;// 开始或停止网络测试
    virtual void releaseDevice() = 0;// 释放设备

signals:
    void netQuailty(int quality);// 网络质量
    void renderVideoImage(QString fileName);// 图片改变信号
    void carmeraReady();// 摄像头准备就绪
    void noCarmerDevices();// 无可用摄像设备
    void speakerVolume(int volume, int speakerId); // 当前音量
};
Q_DECLARE_INTERFACE(IDeviceTestCtrl,"org.qt-project.Qt.Plugin.IDeviceTestCtrl/1.0")
#endif // IDEVICETESTCRTL_H
