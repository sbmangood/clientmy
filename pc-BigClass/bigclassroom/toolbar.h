#ifndef TOOLBAR_H
#define TOOLBAR_H

#include <QObject>
#include "../classroom-sdk/sdk/inc/controlcenter/controlcenter.h"

class ToolBar: public QObject
{
  Q_OBJECT
public:
    explicit ToolBar(QObject *parent = 0);
    ~ToolBar();


    //设置鼠标形状
    Q_INVOKABLE void selectShape(int shapeType);
    //设置画笔尺寸
    Q_INVOKABLE void setPaintSize(double size);
    //设置画笔颜色
    Q_INVOKABLE void setPaintColor(int color);
    //设置橡皮大小
    Q_INVOKABLE void setErasersSize(double size);

    //回撤轨迹数据
    Q_INVOKABLE void undoTrail();
    //清除多个轨迹数据
    Q_INVOKABLE void clearTrails();

    Q_INVOKABLE void uninit();

    // 加载课件
    Q_INVOKABLE void insertCourseWare(QJsonArray imgUrlList, QString fileId,QString h5Url,int coursewareType);

    // 跳转课件页,type 1翻页 2加页 3减页
    Q_INVOKABLE void goCourseWarePage(int type,int pageNo,int totalNumber);

    // 得到课件偏移量
    Q_INVOKABLE void getOffsetImage(QString imageUrl, double offsetY);

    // h5动画播放
    Q_INVOKABLE void sendH5PlayAnimation(int step);

    // 滚动长图
    Q_INVOKABLE void updataScrollMap(double scrollY);

    // 设置当前图片高度
    Q_INVOKABLE void setCurrentImageHeight(int height);

    // 音视频课件
    Q_INVOKABLE void setAVCourseware(QString types, QString state, QString times, QString address, QString fileId, QString suffix);

    // 下载音视频课件
    Q_INVOKABLE QString downLoadAVCourseware(QString mediaUrl);

    Q_INVOKABLE void initVideoChancel();// 初始化频道
    Q_INVOKABLE void changeChanncel();// 切换频道
    Q_INVOKABLE void closeAudio(QString status);// 关闭音频
    Q_INVOKABLE void closeVideo(QString status);// 关闭视频
    Q_INVOKABLE void setStayInclassroom();// 设置留在教室
    Q_INVOKABLE void exitChannel();// 退出频道
    Q_INVOKABLE int setUserRole(int role);// 设置用户角色
    Q_INVOKABLE int setVideoResolution(int resolution);// 设置视频分辨率

    //用户授权
    Q_INVOKABLE void setUserAuth(QString userId, int up, int trail,int audio,int video);

    //全体禁言
    Q_INVOKABLE void allMute(int muteStatus);

    Q_INVOKABLE void uploadLog();// 上传日志

    Q_INVOKABLE int raiseHandForUp(QString userId, QString groupId);

    Q_INVOKABLE int cancelHandsUp(QString userId, QString groupId);

    Q_INVOKABLE int processResponse(QString userId, int operation);

    Q_INVOKABLE int processHandsUp(QString userId, uint groupId, int operation);

    Q_INVOKABLE int getUid(QString UserId);// 由userId得到对应的uid

    Q_INVOKABLE QJsonObject getUserInfo();// 获取用户信息
    Q_INVOKABLE void sendTimer(int timerType, int flag, int timesec);// 发送计时器信息
    Q_INVOKABLE void beginClass();// 开始上课
    Q_INVOKABLE void endClass();// 结束上课
    Q_INVOKABLE void exitClassRoom();// 退出教室

    Q_INVOKABLE QJsonArray getUserDeviceList(int type);// 获取用户设备的摄像头、播放器、录音设备信息,根据type 1摄像头 2扬声器 3录音设备
    Q_INVOKABLE void setCarmerDevice(QString deviceName);// 设置摄像设备
    Q_INVOKABLE void setPlayerDevice(QString deviceName);// 设置播放设备
    Q_INVOKABLE void setRecorderDevice(QString deviceName);// 设置录音设备
    Q_INVOKABLE void startOrStopAudioTest(bool isStart);// 开始或停止声音测试
    Q_INVOKABLE void startOrStopVideoTest(bool isStart); // 开始或停止视频测试
    Q_INVOKABLE void startOrStopNetTest(bool isStart);// 开始或停止网络测试
    Q_INVOKABLE void releaseDevice();// 释放设备

private:
    ControlCenter* m_control;
signals:
    void sigSynCoursewareType(int courseware, QString h5Url);
    void sigPromptInterface(QString interfaces);
    void sigJoinroom(unsigned int uid, QString userId, int status);
    void sigAudioVolumeIndication(unsigned int uid, int totalVolume );// 测试音量信号

    void sigCurrentImageHeight(double imageHeight);
    void reShowOffsetImage(int width, int height);

    void updateStuList(QString userId, uint groupId, int reqOrCancel);// 更新学生发言列表信号,0-cancel,1-req
    void sigHandsUpResponse(QString userId, uint groupId, QString type);// 学生处理老师的回应

    void sigJoinClassroom(QString userId, QString userType, QJsonObject extraInfoObj);// 学生动态加入教室
    void sigLeaveClassroom(QString userId, QString userType, QJsonObject extraInfoObj);// 学生动态离开教室
    void sigResetTimerView(QJsonObject timerData);//重设计时器界面
    void sigBeginClassroom();//开始上课信号
    void sigEndClassroom();//下课信号
    void sigClearScreen();//清屏信号
    void sigExitClassroom();//退出教室信号
    void sigExitRoom();//退出程序
    void sigNoBeginClass();//未开课

    void sigDowloadAVSuccess();// 下载音视频课件成功信号
    void sigDowloadAVFail();// 下载音视频课件失败信号

    void sigPlayAv(QJsonObject avData);//播放音视频文件

    void netQuailty(int quality);// 网络质量
    void renderVideoImage(QString fileName);// 图片改变信号
    void carmeraReady();// 摄像头准备就绪
    void noCarmerDevices();// 无可用摄像设备
    void speakerVolume(int volume, int speakerId); // 当前音量
    void sigKickOutClassroom();

    void sigAutoChangeIpResult(QString autoChangeIpStatus); //网络连接状态
    void sigAutoConnectionNetwork();//自动连接服务器信号

public slots:
    void onSigEnterOrSync(int sync );//同步信息

};

#endif // TOOLBAR_H
