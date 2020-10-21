/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  audio video center.h
 *  Description: audio video center class
 *
 *  Author: ccb
 *  Date: 2019/07/31 13:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/31    V4.5.1       创建文件
*******************************************************************************/

#ifndef AUDIOVIDEOCENTER_H
#define AUDIOVIDEOCENTER_H
#include "datacenter.h"
#include "controlcenter.h"

class AudioVideoCenter : public QObject
{
    Q_OBJECT
public:
    AudioVideoCenter(QObject *parent = 0);
    ~AudioVideoCenter();

    void init(const QString &pluginPathName);
    void uninit();

    void initVideoChancel();// 初始化频道
    void changeChanncel();// 切换频道
    void closeAudio(QString status);// 关闭音频
    void closeVideo(QString status);// 关闭视频
    void setStayInclassroom();// 设置留在教室
    void exitChannel();// 退出频道

public slots:
    void slotJoinroom(unsigned int uid, int status);

private:
    QString getDefaultDevicesId(QString deviceKey);
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);// 传送视频图片帧的信号
    void sigJoinroom(unsigned int uid, QString userId, int status);

private:
    ControlCenter* m_controlCenter;
    IAudioVideoCtrl *m_IAudioVideoCtrl;
};

#endif // AUDIOVIDEOCENTER_H
