/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  controlcenter.h
 *  Description: control center class
 *
 *  Author: ccb
 *  Date: 2019/06/20 11:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H
#include <QObject>
#include <QMutex>
#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <QQmlContext>
#include <QtCore/qglobal.h>
#include "datamodel.h"
#include"imageprovider.h"
#include "getoffsetimage.h"

#if defined(CONTROLCENTER_LIBRARY)
#  define CONTROLCENTERSHARED_EXPORT Q_DECL_EXPORT
#else
#  define CONTROLCENTERSHARED_EXPORT
#endif
enum TEA_OPERATION;
class HttpClient;
class AnswerCenter;
class TrophyCenter;
class RedPacketsCenter;
class CoursewareCenter;
class AudioVideoCenter;
class WhiteBoardCenter;
class SocketManagerCenter;
class HandsUpCenter;
class DeviceTestCenter;
class CONTROLCENTERSHARED_EXPORT ControlCenter : public QObject
{
    Q_OBJECT
public:
    ~ControlCenter();
    static ControlCenter* getInstance();
    //初始化控制中心
    //classType: 0=小组课，1=大班课 ,2=1对1
    //userRole: 0=老师，1=学生，2=助教
    int initControlCenter(const QString &appId, const QString &appKey, const QString &classroomId, int groupId, const QString &userId, const QString &nickName, int userRole, int classType);
    //初始化控制中心
    void initControlCenter(const QString &pluginDirPath, const QString &configFilePath, int screenWidth, int screenHeight);
    //反初始化控制中心
    void uninitControlCenter(); 
    //开始上课
    void beginClass();
    //结束上课
    void endClass();

    void exitClassRoom();
    // 用户授权
    void setUserAuth(QString userId, int up, int trail,int audio,int video);

    ImageProvider* getImageProvider();
    GetOffsetImage* getGetOffsetImageInstance();

public:
    /************************WhiteBoard***********************************************/
    //设置鼠标形状
    void selectShape(int shapeType);
    //设置画笔尺寸
    void setPaintSize(double size);
    //设置画笔颜色
    void setPaintColor(int color);
    //设置橡皮大小
    void setErasersSize(double size);
    //绘制图像
    void drawImage(const QString &image);
    //绘制图形
    void drawGraph(const QString &graph);
    //绘制表情
    void drawExpression(const QString &expression);
    //绘制教鞭位置
    void drawPointerPosition(double xpoint, double  ypoint);
    //回撤
    void undoTrail();
    //清屏
    void clearTrails();
    //绘制整屏轨迹
    void drawTrails();

    /************************IM****************************************************/
    void setServerAddr(const QVariantList &goodIpList, int httpPort, const QString &imIp, int imPort);
    //消息异步推送
    void asynSendMessage(const QString &message);
    //消息同步推送
    void syncSendMessage(const QString &message);

    /************************课件****************************************************/
    void insertCourseWare(QJsonArray imgUrlList, QString fileId, QString h5Url, int coursewareType);// 加载课件
    void goCourseWarePage(int type, int pageNo, int totalNumber);// 跳转课件页,type 1翻页 2加页 3减页
    void getOffsetImage(QString imageUrl, double offsetY);
    void setCurrentImageHeight(int height); // 设置当前图片高度
    void updataScrollMap(double scrollY);// 滚动长图
    void sendH5PlayAnimation(int step);// H5动画播放
    void drawCoursewarePage();      // 画一页
    void setAVCourseware(QString types, QString state, QString times, QString address, QString fileId, QString suffix);// 音视频课件
    QString downLoadAVCourseware(QString mediaUrl);// 下载音视频课件
    /************************音视频****************************************************/
    void initVideoChancel();// 初始化频道
    void changeChanncel();// 切换频道
    void closeAudio(QString status);// 关闭音频
    void closeVideo(QString status);// 关闭视频
    void setStayInclassroom();// 设置留在教室
    void exitChannel();// 退出频道
    void allMute(int muteStatus);// 全体禁音
    void enableBeauty(bool isBeauty);// 设置美颜
    bool getBeautyIsOn();// 得到美颜状态
    int setUserRole(int role);// 设置用户角色
    int setVideoResolution(int resolution);// 设置视频分辨率
    int setAudioVideoInfo(const QString &channelKey,const QString &channelName,const QString &token,
          const QString &uid, const QString &chatRoomId);

   /************************互动工具****************************************************/
    //初始化红包雨信息
    void setRedPackets(int sumCredit = 1000, int redCount = 100, int normalRange = 40, int limitRange = 20, int creditMax = 300, int redTime = 10, int countDownTime = 3);
    void sendTimer(int timerType, int flag, int timesec);
    /************************举手****************************************************/
    int initHandsUp(QJsonObject json);
    int raiseHandForUp(QString userId, QString groupId);
    int cancelHandsUp(QString userId, QString groupId);
    int processResponse(QString userId, int operation);
    int processHandsUp(QString userId, uint groupId, TEA_OPERATION operation);
    int parseHandsUpMsg(const QJsonObject& msg);// 解析上台消息

    /************************设备检测*************************************************/
    QJsonArray getUserDeviceList(int type);// 获取用户设备的摄像头、播放器、录音设备信息,根据type 1摄像头 2扬声器 3录音设备
    void setCarmerDevice(QString deviceName);// 设置摄像设备
    void setPlayerDevice(QString deviceName);// 设置播放设备
    void setRecorderDevice(QString deviceName);// 设置录音设备
    void startOrStopAudioTest(bool isStart);// 开始或停止声音测试
    void startOrStopVideoTest(bool isStart); // 开始或停止视频测试
    void startOrStopNetTest(bool isStart);// 开始或停止网络测试
    void releaseDevice();// 释放设备

    /************************其他****************************************************/
    void processMsg(const QString &command, const QJsonObject &jsonMsg, const QString& message);
    void processHttpMsg(const QString &command, const QJsonObject &jsonMsg);
    void sendLocalMessage(QString message, bool asynSend, bool drawPage);
    void sendHttpMsg(const QString &url, const QString &message);
    int getUid(QString UserId);// 由userId得到对应的uid
    void setUserInfo(QJsonObject userInfo);// 设置用户信息
    QJsonObject getUserInfo();// 获取用户信息

private:
    ControlCenter(QObject *parent = 0);

    void doSocketAck(const QJsonObject &jsonObj);
    void doSocketEnterRoom(const QJsonObject & jsonMsg);
    void doSocketExitRoom(const QJsonObject & jsonObj);
    void doSocketDrawTrails(const QString &command, const QJsonObject &jsonObj, QString &msg);    //及时通讯信息-需要重绘画板
    void doSocketUsersStatus(QJsonValue &contentValue);
    void doBeginRedPackets();
    void doEndRedPackets(QJsonObject &contentObj);
    void doAnswerCancel();
    void doAnswerForceFin();
    void doAnswerStatistics(const QJsonObject &contentObj);
    void doDrawAnswer(QJsonObject &contentObj);


    //获取指定目录及其子目录下文件的全路径
    QStringList getFilePathNameOfSplAndChildDir(QString dirPath);
    //获取在指定目录下的目录的路径
    QStringList getDirPathOfSplDir(QString dirPath);
    // 获取指定目录下的文件路径+名称
    QStringList getFilePathNameOfSplDir(const QString &dirPath);
    //获取配置文件信息
    int getConfigFileInfo(const QString &configFilePath);

    //确认退出房间
    void finishRespExitRoom(void);
    //更新用户状态
    void updateUserState(QJsonValue content);
    //同步历史记录
    bool syncUserHistroyReq(QJsonArray& userHistroyData);
    //同步完成
    void syncUserHistroyComplete(void);
    //解析命令
    void processUserCommandOp(const QString& command, const QJsonObject &jsonMsg, QString& message);
    QString getMessageCommand(const QJsonObject &jsonMsg);
    QString getMessageUid(const QJsonObject &jsonMsg);
    quint32 getMessageSN(const QJsonObject &jsonMsg);
    int getCurrentPage(QString docId);// 通过docId得到当前页
    int getCurrentCoursewarePage();// 获取当前页码

    QString parseMessageDockId(QString& message);
    QString parseMessagePageId(QString& message);
    void parseDocMessage(QString& fromUid, QString& message);
    void parseOperationMessage(QString& fromUid, QString& message);
    void parseTrailMessage(QString& fromUid, QString& message);
    void parsePageMessage(QString& fromUid, QString& message);
    void parseAnimationMessage(QString message);
    bool parseCoursewareInfo(QString& message);

    void cachePonitMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheAVMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheAuthMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheMuteAllMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheZoomMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheStartClass(void);
    void cacheReward(QString& fromUid, QString& message);
    void cacheTimer(QString& fromUid, QString& message);

    quint64 createTimeStamp(void);    //毫秒级别时间邮戳
    void initRectInfo(int width, int height);
    QJsonObject stringToJsonParse(const QString &message);

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);// 传送视频图片帧的信号
    void hideBeautyButton();// 隐藏美颜按钮
    void sigJoinroom(unsigned int uid, QString userId, int status);
    void sigAudioVolumeIndication(unsigned int uid, int totalVolume );// 测试音量信号
    void sigExitRoom();
    void sigCurrentImageHeight(double imageHeight);
    void reShowOffsetImage(int width, int height);
    void sigPlayAv(QJsonObject avData);// 播放音视频文件
    void sigLoadingAV();// 下载音视频课件提醒信号
    void sigDowloadAVSuccess();// 下载音视频课件成功信号
    void sigDowloadAVFail();// 下载音视频课件失败信号

    void sigEnterOrSync(int  sync);
    void sigSendUserId(QString userId);
    void sigIsCourseWare(bool isCourseware);
    void sigUserAuth(QString userId,int up,int trail,int audio,int video,bool isSynStatus);

    void updateStuList(QString userId, uint groupId, int reqOrCancel);// 更新学生发言列表信号,0-cancel,1-req
    void sigHandsUpResponse(QString userId, uint groupId, QString type);// 学生处理老师的回应

    void sigJoinClassroom(QString userId, QString userType, QJsonObject extraInfoObj);// 学生动态加入教室
    void sigLeaveClassroom(QString userId, QString userType, QJsonObject extraInfoObj);// 学生动态离开教室
    void sigkickOutClassroom();
    void sigResetTimerView(QJsonObject timerData);//重设计时器界面
    void sigBeginClassroom();//开始上课信号
    void sigEndClassroom();//下课信号
    void sigClearScreen();//清屏信号
    void sigExitClassroom();//退出教室信号
    void sigNoBeginClass();//未开课

    void netQuailty(int quality);// 网络质量
    void renderVideoImage(QString fileName);// 图片改变信号
    void carmeraReady();// 摄像头准备就绪
    void noCarmerDevices();// 无可用摄像设备
    void speakerVolume(int volume, int speakerId); // 当前音量

private:
    static QMutex m_instanceMutex;
    static ControlCenter* m_controlCenter;

    HttpClient* m_httpClient;
    AnswerCenter* m_answerCenter;
    TrophyCenter* m_trophyCenter;
    RedPacketsCenter* m_redPacketsCenter;    
    CoursewareCenter* m_coursewareCenter;
    AudioVideoCenter* m_audioVideoCenter;
    WhiteBoardCenter* m_whiteBoardCenter;
    SocketManagerCenter* m_socketManagerCenter;
    HandsUpCenter* m_HandsUpCenter;
    DeviceTestCenter* m_DeviceTestCenter;
    QJsonObject m_userInfo;// 用户信息
    QMutex m_mutex;
    QTimer *m_timerOut;
};

#endif // CONTROLCENTER_H
