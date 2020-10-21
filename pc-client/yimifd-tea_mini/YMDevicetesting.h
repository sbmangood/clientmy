#ifndef YMDEVICETESTING_H
#define YMDEVICETESTING_H

#include <QObject>
#include "./agora/agoraengineeventhandler.h"
#include "./agora/agorapacketobserver.h"

#include<QImage>
#include<QTime>
#include<QCoreApplication>
#include<QFile>
#include<QJsonArray>
#include<QStandardPaths>
#include<QDir>
#include<QSettings>
/*
设备检测类


*/
class YMDeviceTesting : public QObject
{
        Q_OBJECT
    public:
        explicit YMDeviceTesting(QObject *parent = 0);
        ~YMDeviceTesting();

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
    signals:
        void netQuailty(int quality);//网络质量
        void imageChange(QString fileName);//图片改变信号
        void carmerReady();//摄像头准备就绪
        void noCarmerDevices();//无可用摄像设备
        void speakerVolume(int volume, int speakerId); //说话者当前的音量
    public slots:
        void renderVideoFrame(unsigned int uid, int w, int h, int y, void *yb, int u, void *ub, int v, void *vb);
        void startOrStopAudioTest(bool isStart);
        void startOrStopNetTest(bool isStart);
        void startOrStopVideoTest(bool isStart);

        void releaseDevice();

        //获取用户设备的 摄像头 播放器 录音设备 信息
        QJsonArray getUserDeviceList(int type);// 根据type 1摄像头 2扬声器 3录音设备

        //设置摄像设备
        void setCarmerDevice(QString deviceName);

        //设置播放设备
        void setPlayerDevice(QString deviceName);

        //设置录音设备
        void setRecorderDevice(QString deviceName);

    private:
        //记录用户当前选择的设备
        void saveDeviceInformation(int type, QString value);


};

#endif // YMDEVICETESTING_H
