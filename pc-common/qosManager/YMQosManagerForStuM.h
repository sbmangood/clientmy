#ifndef YMQOSMANAGERrFORSTUM_H
#define YMQOSMANAGERrFORSTUM_H

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


class YMQosManagerForStuM
        : public QObject
{
    Q_OBJECT
public:
    YMQosManagerForStuM(QObject *parent = 0);
    ~YMQosManagerForStuM();

    static YMQosManagerForStuM * gestance()
    {
        static YMQosManagerForStuM * qosManager = new YMQosManagerForStuM();
        return qosManager;
    }
signals:

public slots:
    //传入基础数据初始化 该类的共有数据
    void initQosManager(QString initData,QString userType);

    //添加需要被推到服务器的消息 msgHeaderType 消息头类型  msgData 消息数据
    void addBePushedMsg(QString msgHeaderType,QJsonObject msgData);
    //检测是否有消息要发送到服务器
    void checkPushMsgToServe();

    void onPushMsgToServerReply(QNetworkReply *reply);

    //记录要上报的信息到本地 直接将数据整理好之后 存到本地 下次程序启动之后直接读取上报
    void writeMsgToLocalBuffer(QString msgHeaderType,QJsonObject msgData);

    qint64 getTimeDifference();//获取服务端时间差

    bool getIsChangeChannel();
    void setChangeChannelValue(bool isChangeChannels);

    QString makeJoinMicActionId();//产生上麦动作id

    QString getJoinMicActionId();//获取上麦动作id

    QString getH5NeedBasicData();//获取h5需要的基础字段

private:
    //当前班级所有成员信息 ，本成员自己的信息
    QJsonObject roomMemberInformationObj;
    QJsonObject selfInformationObj;
    //推送消息时共用的参数
    QJsonObject commonMsgData;
    //缓存要发送的所有的信息
    QStringList msgBufferList;

    QTimer * timeoutTimer;//请求超时计时器
    QString pushUrl = "https://galaxy.yimifudao.com/client";//推送到的网址

    QTimer * findDataTimer;//定时刷是否有要发送的数据

    QNetworkAccessManager *httpAccessmanger;

    QString currentBePushedMsg;//缓存当前正在被发送的数据

    QString currentUserType;//当前的用户类型

    QString deviceInfo,osVersion;//本机设备类型及系统版本

    QString httpUrl = "api.yimifudao.com/v2.4";
    QNetworkAccessManager *m_accessManager;
    QNetworkRequest m_request;
    QNetworkReply *m_reply;
    qint64 timeDifference = 0;//本地时间和服务器时间差

    QJsonObject basicJsonData;//缓存通用json数据

    bool isChangeChannel = false;//切换通道标示
    int serverErrorTimes = 0;//错误次数

    QString joinMicActionId = "123456";//申请上麦的动作id
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

    QJsonObject getBasicJsonData();//获取上报时的公用的基础数据

};

#endif // YMQOSMANAGERrFORSTUM_H
