#ifndef AUDIOVIDEOCENTER_H
#define AUDIOVIDEOCENTER_H
#include "..\dataconfig\datahandl\datamodel.h"
#include "../classroom-sdk/sdk/inc/YMAudioVideoManager/iaudiovideoctrl.h"

class AudioVideoCenter : public QObject
{
    Q_OBJECT
public:
    ~AudioVideoCenter();

    static AudioVideoCenter* getInstance();

    void init(const QString &pluginPathName);
    void uninit();

    void initVideoChancel();// 初始化频道
    void changeChanncel();// 切换频道
    void closeAudio(QString status);// 关闭音频
    void closeVideo(QString status);// 关闭视频
    void setStayInclassroom();// 设置留在教室
    void exitChannel();// 退出频道
    void enableBeauty(bool isBeauty);// 设置美颜
    bool getBeautyIsOn();// 得到美颜状态

private:
    explicit AudioVideoCenter(QObject *parent = 0);
    static AudioVideoCenter* m_audiovideocenter;

public slots:
    void slotJoinroom(unsigned int uid, int status);

private:
    QString getDefaultDevicesId(QString deviceKey);
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);// 传送视频图片帧的信号
    void hideBeautyButton();// 隐藏美颜按钮
    void sigJoinroom(unsigned int uid, QString userId, int status);
    void sigAudioVolumeIndication(unsigned int uid, int totalVolume );
    void sigAisleFinished(bool);
    void createRoomFail();// 加入音视频通道失败
    void createRoomSucess();// 加入音视频通道成功
    void pushAudioQualityToQos(QString channel, QString audioLost, QString audioDelay, QString audioQuality);// 发送音频质量信息到Qos
private:
    IAudioVideoCtrl *m_IAudioVideoCtrl;
};

#endif // AUDIOVIDEOCENTER_H
