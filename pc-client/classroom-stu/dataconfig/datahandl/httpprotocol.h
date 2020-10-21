#ifndef HTTPPROTOCOL_H
#define HTTPPROTOCOL_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>
#include <QByteArray>
#include <QVariant>
#include <QUrl>
#include <QDateTime>
#include <QCryptographicHash>
#include <QMap>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QSslConfiguration>
#include<QEventLoop>
#include<QTimer>
#include "./dataconfig/datahandl/datamodel.h"

class HttpProtocol : public QObject
{
        Q_OBJECT
    public:
        explicit HttpProtocol(QObject *parent = 0);
        ~HttpProtocol();
    signals:

        //发送出去 处理过的消息
        void readMessage(QString message);

        void timeOut(QString timeOutMsg);

        //网络链接信号
        void hasNetConnects(bool hasNetConnect);

    public slots:
        void heartBeat();
        void httpDealDataContral();

        //接收需要通过 http协议发送的数据
        void sendMessage(QString message);


    private:
        QNetworkAccessManager *httpProtocolManager;
        QTimer * timeoutTimer;//请求超时计时器

        //缓存的所有的 需要发送的消息集合
        QStringList allBufferMessageList;
        //当前正在发送的消息
        QString currentMessage;
        //在线人员的id集合
        QStringList onlineUserList;

        int brokenNetTimes = 0; //记录里断网请求的次数

        bool hasSendNetConnect = false;//是否发送过 已经链接网络了
    public:
        //获取服务器存在的消息数据
        QByteArray getServerData(QString message);
        //    //处理获取下来的消息数据
        //    void dealMeaasgeContral(QString message);

        //判断发送数据的定时器  有本地消息 发送本地消息 没有就 发送心跳数据包  进行http请求时停掉定时器
        QTimer *getMessageTimer;

        //当前发送的消息编号
        int currentMessageNumber = 0;//

        int currentServerMessageNUmber = 0;//当前服务器的消息编号

        int currentMessageTimeLength = 0;//当前检测消息发送的时长  超过十次 就是 一秒没有要发送的消息 就发心跳

        QString httpAddress = "";//http的ip地址 避免 changecmd 命令时切换了 ip地址 使用第一次的地址
};

#endif // HTTPPROTOCOL_H
