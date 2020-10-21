/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  tcpsocket.cpp
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

#include "tcpsocket.h"
#include <QDebug>
const int kWindowsTaskNo = 1001;
TcpSocket::TcpSocket(const QVariantList &goodIpList, const QString& address, const int& port)
{
    m_message = "";
    initMarsService(goodIpList, address, port);
}

TcpSocket::~TcpSocket()
{
    destroyMarsService();
}

void TcpSocket::sendMsg(QString msg)
{
    static int mars_taskid_ = 0;

    CommTask* pCommTask = new CommTask();
    pCommTask->cmdid_ = kWindowsTaskNo;
    pCommTask->taskid_ = mars_taskid_++;
    pCommTask->channel_select_ = ChannelType_LongConn;
    pCommTask->cgi_ = "flow/windows";
    pCommTask->text_ = msg.toStdString();
    NetworkService::Instance().startTask(pCommTask);
}

void TcpSocket::OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend)
{
    Q_UNUSED(_channel_id);
    Q_UNUSED(_cmdid);
    Q_UNUSED(_taskid);
    Q_UNUSED(_extend);

    m_message.append((const char*)_body.Ptr());
    m_message = m_message.mid(0, _body.Length());

    emit readMsg(m_message);
    m_message = "";
}

void TcpSocket::OnState(int _status)
{
    if (_status == 2) // tcp socket 建立连接成功
    {
        marsLongLinkStatus(true);
    }
    else if (_status == 3) // 断开连接
    {
        marsLongLinkStatus(false);
    }
}

bool TcpSocket::initMarsService(const QVariantList &goodIpList, const QString& address, const int& port)
{
    // 获得所有 IP 地址，将其设置为本地DNS解析数据仓库
    std::vector<std::string> allip;
    for(int i = 0; i < goodIpList.size(); ++i)
    {
        allip.push_back(goodIpList.at(i).toMap()["ip"].toString().toStdString());
    }

    NetworkService::Instance().setLongLinkAddress(address.toStdString(), port);
    NetworkService::Instance().setClientLocalDnsIPs(allip);
    NetworkService::Instance().setPushObserver(kWindowsTaskNo, this);
    NetworkService::Instance().setStateObserver(kLongLinkStateCallbackId, this);
    NetworkService::Instance().start();

    return true;
}

void TcpSocket::destroyMarsService()
{
    NetworkService::Instance().destroy();
}

