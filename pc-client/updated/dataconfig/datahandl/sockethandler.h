#ifndef SOCKETHANDLER_H
#define SOCKETHANDLER_H

#include <QObject>
#include <QAbstractSocket>
#include <QMutex>
#include <QTime>
#include <QMap>
#include <QDebug>
#include "./messagemodel.h"
#include "./datamodel.h"
#include "./ymtcpsocket.h"
#include "./././cloudclassroom/cloudclassManager/YMCloudClassManagerAdapter.h"
#include"../YMCommon/qosManager/YMQosManager.h"

#ifdef USE_OSS_AUTHENTICATION
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#endif

class QTcpSocket;
class QTimer;

class SocketHandler : public QObject
{
    Q_OBJECT
public:
    explicit SocketHandler(QObject *parent = 0);
    void sendLocalMessage(QString cmd, bool append, bool drawPage);
    int getCurrentPage(QString docId);

    void excuteMsg(QString &msg, QString &fromUser);

    void excuteMsgForNew(QString &msg, QString &fromUser);

    void clearRecord();

    //ip切换
    void onChangeOldIpToNew();

    void setFirstPage(int pages);
    void disconnectSocket(bool reconnect);

    //重设优选ip列表
    void restGoodIpList();
signals:
    void sigEnterOrSync(int  sync);
    void sigExitRoomIds(QString ids);//退出教室的id
    void sigDroppedRoomIds(QString ids); //掉线
    void sigSendUserId(QString userId);
    void sigUserIdExitClassroom(QString userId);
    void sigEnterRoomRequest(QString userId);
    void sigIsCourseWare();
    void sigSendHttpUrl(QString urls);
    //处理结束课程
    void sigStudentEndClass( QString usrid);
    void sigStartClassTimeData(QString times);

    void sigVideoSpan(QString videoSpan);

    //关闭摄像头操作
    void  sigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone);

    //允许操作权限
    void sigAuthtrail(QMap<QString, QString>);

    //教鞭坐标
    void sigPointerPosition(double xPoint, double yPoint);

    //网络状态：有线、无线
    void sigInterNetChange(int netWorkStatus);

    void sigCouldUseNewBoard(bool could);//是否可以使用16:9的画板来上课 true 可以 false 不可以
    void sigTeaChangeVersionToOld();//老师之前用新版本上课 后来换成老版本 弹窗提示学生老师版本过低

public slots:
    void undo();
    void addPage();
    void deletePage();
    void goPage(int pageIndex);
    void picture(QString url, double width, double height);
    void clearScreen();
    //判断自动切换ip的结果
    void justChangeIp(bool isSuccess);

    //自动切换ip 频繁掉线是三次自动切换Ip
    void autoChangeIp();

private slots:
    void readMessage(QString line);//接收消息
    void sendMessage(QString message);
    void sendMessage();
    void sendAudioQuality();

    //再次提交当前答案数据
    void reSubmitAnswer();

    void interNetworkChange();
    void sendC2cDelay(long long tea_s,long long server_s,long long timeDifference);

signals:
    void sigUsersInRoom(QList<QString> users);
    void sigBrushPermisions(QMap<QString, QString> brushPermisions);
    void sigPagePermisions(QMap<QString, QString> pagePermisions);
    void sigSupplier(QString supplier);
    void sigVideoType(QString videoType);
    void sigDrawPage(MessageModel model);
    void sigDrawLine(QString command);
    // void sigAuthtrail(QMap<QString, QString>);
    void sigEnterFailed();
    //视频控制
    void sigAvUrl( QString avType, QString startTime, QString controlType, QString avUrl );

    //没有网络
    void justNetConnect( bool hasNetConnect);

    //自动切换线路结果
    // autoChangeIpStatus 自动切换IP状态 showAutoChangeIpview 显示网络不好; autoChangeIpSuccess 自动切换ip 成功; autoChangeIpFail 自动切换ip失败
    void autoChangeIpResult(QString autoChangeIpStatus);



    //*** ******************************
    //加载新的讲义课件
    void sigShowNewCourseware(QJsonValue coursewareData);
    //加载新课件的对应的栏目
    void sigShowNewCoursewareItem(QJsonValue coursewareItemData);
    //开始练习
    void sigStarAnswerQuestion(QJsonValue questionData);
    //停止练习
    void sigStopAnswerQuestion(QJsonValue questionData);

    //打开答案解析 questionData 包含题目所在的 讲义id 对应的栏目 以及对应的 题的id
    void sigOpenAnswerParsing(QJsonValue questionData);
    //关闭答案解析
    void sigCloseAnswerParsing(QJsonValue questionData);
    //打开批改面板 /**/
    void sigOpenCorrect(QJsonValue questionData, bool isVisible);
    //关闭批改面板
    void sigCloseCorrect(QJsonValue questionData);
    //开始批改界面
    void sigCorrect(QJsonValue questionData);

    //转图后的讲义图片
    void sigAutoPicture(QJsonValue questionData);
    //滚动长图命令
    void sigZoomInOut(double offsetX, double offsetY, double zoomRate);

    //获取课件列表失败
    void sigGetLessonListFail();
public:
    int m_currentPage;//当前页

    //当前显示的课件类型 1 老课件 2 新课件
    int currentCourwareType = 1;

    QString currentPlanId = "";//当前新讲义id
    QString currentColumnId = "";//当前的栏目id
    QJsonValue currentPlanContent;//当前讲义的content内容 开始上课的时候 发送出去这个信息
    QJsonValue currentColumnContent;//当前栏目的 content内容

    double offsetX, offsetY, zoomRate; //保存当前长图的位置和偏移量

    bool correctViewIsOpen = false;//批改面板的 状态

    QJsonValue openCorrectData;//记录打开批改面板的数据
    QList < QJsonObject > correctViewData ;//根据课件id 存储批改界面数据

    bool isFirstgGoPage = true;
    QJsonValue stopOrBeginAnswerQuestonData;//保存开始答题或停止答题时数据 便于在开始上课时同步命令

private:
    YMTCPSocket *m_socket;
    QString m_message;//接收的消息
    QTimer *m_sendMsgTask;
    QTimer *m_netTimer;
    QTimer *m_sendAudioQualityTask;//发送语音质量
    QList<QString> m_sendMsgs;
    QMutex m_sendMsgsMutex;
    bool m_response;//服务端是否给消息响应
    QString m_lastSendMsg;//上一次发送的消息
    int m_sendMsgNum;//发送的消息编号
    QString m_lastRecvNum;
    QString m_lastRecvMsg;
    QTime m_lastHBTime;//上次心跳时间
    QString m_enterRoomMsg;
    bool m_canSend;//是否已经成功进入教室可发送其他消息
    QMap<QString, QList<MessageModel> > m_pages; //每个课件每一页的内容 <课件id,课件每页内容[]>
    QMap<QString, int> m_pageSave;//每个课件的当前显示页码

    //QMap<QString, QString> m_newSave;//新讲义当前的 栏目索引

    QMap<QString, QString> m_userBrushPermissions;//每个用户的书写权限
    QMap<QString, QString> m_userPagePermissions;//每个用户的翻页权限
    QString m_supplier;//音视频供应商 1 声网 2 QQ
    QString m_videoType;//音视频状态 1 仅音频 2 音视频

    QString m_currentCourse;//当前课件
    QString m_includeSelfMsg;

    bool m_isInit;//是不是第一次上课
    int m_firstPage;//是不是第一次翻页

    bool hasChangeAudio = false;//是否收到过 changeVideo 命令
    bool hasReciveFinishedClass = false;//是否收到结束课程命令

    int currentReloginTimes;//记录当前重新登录的次数
    bool isAutoChangeIping = false;//是否正在自动切换ip
    bool isFirstConnect = true;
    bool isDisconnectBySelf = true;
    //记录当前的链接次数  便于切换ip
    int currentAutoChangeIpTimes = 0;

    QString synchronousForNewHomeWorkString = "";

    //提交答案定时器  为了生成截图（有时候老师截图会不成功）
    //如果十秒内没有收到回复在发送一次 提交答案命令 questionAnswer

    QString currentAnswerSumitData = "";//当前提交批改的答案数据

    QTimer *anserSubmitTimer;

    bool currentIsAnswing = false;//当前是否在做题  若果正在做题不响应翻页命令

    bool currentIsDrawCloum = false;//当前是不是进行了切换栏目操作

    QString oldRecordVersion = "2.3.2";//录播的旧版本号
    QString newRecorderVersion = "3.10.19";//录播的新版本号
    int lowestNewBoardCode = 31135;//支持新画板的最低版本号

    int currentNetWorkType = -1;//当前连接的网络类型

#ifdef USE_OSS_AUTHENTICATION
    YMHttpClient * m_httpClient;
    QString m_httpUrl;
#endif

private:
    void parseMsg(QString &num, QString &fromUser, QString &msg);
    void newConnect();
    void startSendMsg();
    void stopSendMsg();
    void startSendAudioQuality();
    void stopSendAudioQuality();
    void checkTimeOut();

    //同步新课件里的命令
    void synchronousForNewHomeWork(QString &msg);

    //获取 课程的所有的新老课件信息
    YMCloudClassManagerAdapter * getAllLessonCoursewareList;
    //获取当前显示栏目的内容是否有 baseImage
    QJsonObject getCurrentItemBaseImage(QJsonObject dataObjecte, int pageIndex);

    //在发消息出去的时候重设当前课件页的 model 数据 为了新讲义的数据
    MessageModel resetMessageModel(MessageModel model);

#ifdef USE_OSS_AUTHENTICATION
    QString getOssSignUrl(QString key);//获取OSS重新签名的URL
    QString checkOssSign(QString imgUrl);//检查是否需要验签
#endif

    ~SocketHandler();

};

#endif // SOCKETHANDLER_H
