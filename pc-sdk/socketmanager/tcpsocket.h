/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  tcpsocket.h
 *  Description: tcp socket class
 *
 *  Author: ccb
 *  Date: 2019/07/01 09:05:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/07/01    V4.5.1       创建文件
*******************************************************************************/

#ifndef TCPSOCKET_H
#define TCPSOCKET_H

#include <QObject>
#include <QVariantList>
#include <QtCore/qglobal.h>
#include "longLinkManager/NetworkService.h"

class TcpSocket: public QObject, public PushObserver, public StateObserver
{
 Q_OBJECT
public:
    /*****************************
     * 参数说明
     *  ipList: ip列表
     *  address: socket使用的IP地址
     *  port: socket使用的端口
     ****************************/
    explicit TcpSocket(const QVariantList &goodIpList, const QString& address, const int& port);
     ~TcpSocket();

signals:
    void readMsg(QString msg);
    void marsLongLinkStatus(bool status);

public:
    void sendMsg(QString msg);

public:
    // Mars Socket 推送消息(内部接口)
    virtual void OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend);
    // Mars Socket 连接状态(内部接口)
    virtual void OnState(int _status);

private:
    // Mars 初始化服务
    bool initMarsService(const QVariantList &goodIpList, const QString& address, const int& port);
    // Mars 销毁服务
    void destroyMarsService(void);

private:
    // 接收消息缓存
    QString m_message;
};

#endif // TCPSOCKET_H
