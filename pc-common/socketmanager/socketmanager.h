/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  socketmanager.h
 *  Description: socket manager class
 *
 *  Author: ccb
 *  Date: 2019/07/01 11:10:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/01    V4.5.1       创建文件
*******************************************************************************/

#ifndef SOCKETMANAGER_H
#define SOCKETMANAGER_H

#include <QObject>
#include <QTimer>
#include <QMutex>
#include <QJsonObject>

#include "isocketmessagectrl.h"
#include "isocketmessgaecallback.h"

class TcpSocket;
class SocketManager : public QObject, public ISocketMessageCtrl
{
    Q_OBJECT
#if QT_VERSION >= 0x050000
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.ISocketMessageCtrl/1.0" FILE "socketmanager.json")
    Q_INTERFACES(ISocketMessageCtrl)
#endif // QT_VERSION >= 0x050000

public:
    explicit SocketManager(QObject *parent = 0);
    ~SocketManager();

    //设置IM回调
    virtual void setSocketMessageCallBack(ISocketMessageCallBack *instantMessageCallBack = 0);
    //初始化socket message
    virtual void initSocketMessageCtrl(const QVariantList &goodIpList);
    //反初始化socket message
    virtual void uninitSocketMessageCtrl();

    //检查服务器回复
    virtual bool checkServerResponse(QString target, bool bConfirmFinish);
    //消息异步推送
    virtual void asynSendMessage(const QString message);
    //消息同步推送
    virtual void syncSendMessage(const QString &message);

public slots:
    //判断自动切换ip的结果
    void justChangeIp(bool isSuccess);
    void autoChangeIp();
    void interNetworkChange();

private slots:
    void readMessage(QString message);//接收消息
    void sendMessage(QString message);
    void onTimerSendMessage(void);
    void reSendMessage(void);

private:

    void startSendMsg();
    void stopSendMsg(QTimer* pTimer);
    void deleteQTimer(QTimer* pTimer);
    void cleanMessageQue(void);//清空队列

    //重设优选ip列表
    void restGoodIpList();
    //毫秒级别时间戳
    quint64 createTimeStamp(void);
    //断开Socket连接
    void disconnectSocket(bool reconnect);

private:

    QTimer *m_netTimer;
    QTimer *m_sendMsgTask;
    QTimer* m_tReSendMessageTimer;

    TcpSocket* m_tcpSocket;
    ISocketMessageCallBack* m_socketMessageCallBack;

    QList<QString> m_qListMsgsQue;
    QMutex m_mSendMsgsQueMutex;//消息发送队列锁

    bool m_response;        //服务端是否给消息响应
    bool m_bCanSend;        //是否能发送消息
    bool m_bServerResp;     //服务器是否已回复
    bool m_isAutoChangeIping;//是否正在自动切换ip

    quint64 m_uLastSendTimeStamp;   //毫秒级别
    int m_currentReloginTimes;      //记录当前重新登录的次数
    int m_currentAutoChangeIpTimes;//记录当前的链接次数  便于切换ip

    QString m_lastSendMsg;//上一次发送的消息
    QVariantList m_goodIpList;      //优化Ip列表

};

#endif // SOCKETMANAGER_H
