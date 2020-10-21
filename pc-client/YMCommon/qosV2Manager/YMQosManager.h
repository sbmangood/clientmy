#ifndef YMQOSMANAGER_H
#define YMQOSMANAGER_H

#include <QObject>
#include <Windows.h>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include<QFile>
#include<QDir>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include<QTimer>
#include<QThread>
#include<QNetworkAccessManager>
#include<QNetworkReply>
#include<QNetworkRequest>
#include<QNetworkInterface>
#include<QSysInfo>


class YMQosManager
        : public QObject
{
    Q_OBJECT
public:
    YMQosManager(QObject *parent = 0);
    ~YMQosManager();

    static YMQosManager * gestance()
    {
        static YMQosManager * qosManager = new YMQosManager();
        return qosManager;
    }
signals:


public slots:
    void onPushMsgToServerReply(QNetworkReply *reply);
    //检测是否有消息要发送到服务器
    void checkPushMsgToServe();

public:
    //传入基础数据初始化 该类的共有数据
    void initQosManager(QString initData,QString userType);

    //添加需要被推到服务器的消息 msgHeaderType 消息头类型  msgData 消息数据
    void addBePushedMsg(QString msgHeaderType,QJsonObject msgData);

    //记录要上报的信息到本地 直接将数据整理好之后 存到本地 下次程序启动之后直接读取上报
    void writeMsgToLocalBuffer(QString msgHeaderType,QJsonObject msgData);

    qint64 getTimeDifference();//获取服务端时间差

    bool getIsChangeChannel();
    void setChangeChannelValue(bool isChangeChannels);
    void registerClassroomEventInfo();//注册教室埋点所有信息
    void registerClassroomInfo(const QString& socketIp);//注册教室内课程信息

public:
    const static QString kXBK_Click_class;
    const static QString kXBK_Click_pointer;
    const static QString kXBK_Click_remove_pointer;
    const static QString kXBK_Click_timer;
    const static QString kXBK_Click_selection;
    const static QString kXBK_Click_responder;
    const static QString kXBK_Click_countdown;
    const static QString kXBK_Click_reward;
    const static QString kXBK_Click_authorization;
    const static QString kXBK_Click_mute;
    const static QString kXBK_Click_allmute;
    const static QString kXBK_Click_onStage;
    const static QString kXBK_Click_downStage;
    const static QString kXBK_Click_stu_responder;
    const static QString kXBK_Click_stu_responderResult;
    const static QString kXBK_HearTable_networkQuality;
    const static QString kXBK_Click_enterClassroom;
    const static QString kXBK_Click_enterClassroomFInish;
    const static QString kXBK_Click_camera;
    const static QString kXBK_Click_cameraCall;
    const static QString kXBK_HearTable_socketDisconnect;
    const static QString kXBK_HearTable_audioQuality;
    const static QString kXBK_Click_courseware;
    const static QString kXBK_Click_tea_feedback;
    const static QString kXBK_Click_stu_feedback;
    const static QString kXBK_Click_SwitchRole;

private:
    //当前班级所有成员信息 ，本成员自己的信息
    QJsonObject roomMemberInformationObj;
    QJsonObject selfInformationObj;
    //推送消息时共用的参数
    QJsonObject commonMsgData;
    //缓存要发送的所有的信息
    QStringList msgBufferList;

    QTimer * timeoutTimer;//请求超时计时器
    QString pushUrl = "https://galaxy.yimifudao.com.cn/client";//推送到的网址

    QTimer * findDataTimer;//定时刷是否有要发送的数据

    QNetworkAccessManager *httpAccessmanger;

    QString currentBePushedMsg;//缓存当前正在被发送的数据

    QString currentUserType;//当前的用户类型

    QString deviceInfo,osVersion;//本机设备类型及系统版本

    QString httpUrl = "api.yimifudao.com.cn/v2.4";
    QNetworkAccessManager *m_accessManager;
    QNetworkRequest m_request;
    QNetworkReply *m_reply;
    qint64 timeDifference = 0;//本地时间和服务器时间差

    QMap<QString,QString> basicJsonData;//缓存通用json数据

    bool isChangeChannel = false;//切换通道标示
    int serverErrorTimes = 0;//错误次数
    QString m_lessonId;//课程ID
private:
    //消息推送
    void pushMsgToServer(QByteArray msg);

    //获取上次退出之前没有发送的消息数据 缓存进队列里 后边做
    void getLastExitMsgInfo();

    //整理出发送出去的信息格式
    QString getPushMsg(QString msgHeaderType,QJsonObject msgData);

    QString getMacString();//获取mac地址
    QString getCurrentNetWorkType();//当前网络状态类型获取

    void getLocalBufferMsg();//从本地缓存的文件中获取上次退出之前没有被发送出去的msg

    void getBePushedUrl();//获取被推送到的url

    void getDeviceInfo();//获取本机设备类型

    void getServerDateTime();//获取服务器时间

    QString getSessionId();//获取sessionId

    QMap<QString,QString> getBasicJsonData();//获取上报时的公用的基础数据

};

#endif // YMQOSMANAGER_H
