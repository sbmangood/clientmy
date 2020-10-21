/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  iinstantmessagecallback.h
 *  Description: instantmessage callback interface
 *
 *  Author: ccb
 *  Date: 2019/06/20 15:20:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef IINSTANTMESSGAECALLBACK_H
#define IINSTANTMESSGAECALLBACK_H
#include <QString>
#include <QJsonObject>

class ISocketMessageCallBack
{
public:

    //回调接收消息
    virtual void onRecvMessage(const QJsonObject &jsonMsg, const QString& message) = 0;
    //回调IP自动调整结果
    virtual void onAutoChangeIpResult(const QString &result) = 0;
    //回调网络类型
    virtual void onNetWorkMode(const QString &netWorkMode) = 0;
    //回调自动连接服务器信号
    virtual void onAutoConnectionNetwork() = 0;
    //回调成员数据信息
    virtual void onPersonData(const QString &address, int udpPort, int port, bool isTcpProtocol) = 0;

    //获取网络类型
    virtual QString getNetWorkMode() = 0;
    //获取成员数据信息
    virtual int getPersonData(QString &address, int &udpPort, int &port, bool& isTcpProtocol) = 0;
    //获取服务网络信息
    virtual int getServerQosInfo(int &serverDelay, int &serverLost) = 0;
};


#endif // IINSTANTMESSGAECALLBACK_H
