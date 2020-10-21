/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  socketmanagercenter.h
 *  Description: socketmanager center class
 *
 *  Author: ccb
 *  Date: 2019/07/31 10:50:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/31    V4.5.1       创建文件
*******************************************************************************/

#ifndef SOCKETMANAGERCENTER_H
#define SOCKETMANAGERCENTER_H
#include "datacenter.h"
#include "controlcenter.h"
#include "../socketmanager/isocketmessagectrl.h"
#include "../socketmanager/isocketmessgaecallback.h"

class SocketManagerCenter : public QObject, public ISocketMessageCtrl, public ISocketMessageCallBack
{
   Q_OBJECT
public:
    SocketManagerCenter(ControlCenter* controlCenter);
    ~SocketManagerCenter();

    void init(const QString &pluginPathName);
    void uninit();

    //初始化socket message (*unrealized*)
    virtual void initSocketMessageCtrl(const QVariantList &goodIpList, const QString &address, int port, int serverDelay, int serverLost);
    //反初始化socket message (*unrealized*)
    virtual void uninitSocketMessageCtrl();
    //检查服务器回复
    virtual bool checkServerResponse(QString target, bool bConfirmFinish);
    //消息异步推送
    virtual void asynSendMessage(const QString message);
    //消息同步推送
    virtual void syncSendMessage(const QString &message);
    //设置im
    virtual void setSocketMessageCallBack(ISocketMessageCallBack *socketMessageCallBack = 0){;}

    //消息接收
    virtual void onRecvMessage(const QJsonObject &jsonMsg, const QString &message);
    virtual void onAutoChangeIpResult(const QString & result);
    virtual void onNetWorkMode(const QString &netWorkMode);
    virtual void onAutoConnectionNetwork();//自动连接服务器信号
    virtual void onPersonData(const QString &address, int port);

    virtual QString getNetWorkMode();

private:  
    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

signals:
    void sigInterNetChange(int netWorkStatus);

private:
    ControlCenter* m_controlCenter;
    ISocketMessageCtrl* m_socketMessageCtrl;
};

#endif // SOCKETMANAGERCENTER_H
