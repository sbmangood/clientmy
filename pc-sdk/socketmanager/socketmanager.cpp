/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  socketmanager.cpp
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

#include <QDebug>
#include <QtNetwork>
#include <QJsonDocument>
#include "socketmanager.h"
#include "tcpsocket.h"
//#include "../qosV2Manager/YMQosManager.h"

SocketManager::SocketManager(QObject *parent)
    :QObject(parent)
    ,m_tcpSocket(nullptr)
    ,m_netTimer(nullptr)
    ,m_sendMsgTask(nullptr)
    ,m_tReSendMessageTimer(nullptr)
    ,m_socketMessageCallBack(nullptr)
    ,m_isAutoChangeIping(false)
    ,m_bServerResp(true)
    ,m_uLastSendTimeStamp(0)
    ,m_currentReloginTimes(0)
    ,m_currentAutoChangeIpTimes(0)
{  

}

SocketManager::~SocketManager()
{
    uninitSocketMessageCtrl();
}

void SocketManager::setSocketMessageCallBack(ISocketMessageCallBack *instantMessageCallBack)
{
    m_socketMessageCallBack = instantMessageCallBack;
}

void SocketManager::initSocketMessageCtrl(const QVariantList &goodIpList, const QString &address, int port, int serverDelay, int serverLost)
{
    if(nullptr == m_socketMessageCallBack)
    {
        qWarning()<< "m_socketMessageCallBack is null , init socketMessage ctrl is failed!";
        return;
    }

    //异步消息推送定时器
    m_tcpPort = port;
    m_ipAddress = address;
    m_serverDelay = serverDelay;
    m_serverLost = serverLost;
    m_goodIpList = goodIpList;
    m_sendMsgTask = new QTimer(this);
    connect(m_sendMsgTask, SIGNAL(timeout()), this, SLOT(onTimerSendMessage()));

    //重发消息定时器
    m_uLastSendTimeStamp = 0;
    m_tReSendMessageTimer = new QTimer(this);
    connect(m_tReSendMessageTimer, SIGNAL(timeout()), this, SLOT(reSendMessage()));

    //网络状态检测定时器
    m_netTimer = new QTimer();
    m_netTimer->setInterval(60000);
    connect(m_netTimer, SIGNAL(timeout()), this, SLOT(interNetworkChange()));
    m_netTimer->start();

    //重设优选ip列表
    restGoodIpList();

    //初始化mar
    m_tcpSocket = new TcpSocket(m_goodIpList, m_ipAddress, m_tcpPort);
    connect(m_tcpSocket, &TcpSocket::readMsg, this, &SocketManager::readMessage);
    connect(m_tcpSocket, SIGNAL(marsLongLinkStatus(bool)), this, SLOT(justChangeIp(bool)));
    //    connect(m_tcpSocket, SIGNAL(marsLongLinkStatus(bool)), this, SIGNAL(sigNetworkOnline(bool)));

    startSendMsg();
}

void SocketManager::uninitSocketMessageCtrl()
{
    if(nullptr != m_tcpSocket)
    {
        m_socketMessageCallBack = nullptr;
        disconnect(m_tcpSocket, &TcpSocket::readMsg, this, &SocketManager::readMessage);
        disconnect(m_tcpSocket, SIGNAL(marsLongLinkStatus(bool)), this, SLOT(justChangeIp(bool)));
        delete m_tcpSocket;
        m_tcpSocket = nullptr;
        qDebug()<< "uninit socket message ctrl end";
    }

    deleteQTimer(m_sendMsgTask);
    deleteQTimer(m_tReSendMessageTimer);
    deleteQTimer(m_netTimer);

    m_sendMsgTask = nullptr;
    m_tReSendMessageTimer = nullptr;
    m_netTimer = nullptr;

    cleanMessageQue();
}

bool SocketManager::checkServerResponse(QString target, bool bConfirmFinish)
{
    bool bExit = false;
    if(!m_bServerResp && !m_lastSendMsg.isEmpty())
    {
        if(m_lastSendMsg.contains(target))
        {
            m_bServerResp = true;
            m_lastSendMsg = "";
            if(bConfirmFinish)
            {
                bExit = true;
            }
        }
    }
    return bExit;
}

//消息异步推送
void SocketManager::asynSendMessage(const QString message)
{

    QMutexLocker locker(&m_mSendMsgsQueMutex);
    m_qListMsgsQue.append(message);
}

//消息同步推送
void SocketManager::syncSendMessage(const QString &message)
{
    qDebug() << " syncSendMessage -----"<< message;
    if(!message.isEmpty() && NULL != m_tcpSocket)
    {
        //深度复制防止数据关联
        QString deepinCopyMsg(message.unicode(), message.length());
        m_tcpSocket->sendMsg(deepinCopyMsg.toUtf8());
    }
}

void SocketManager::justChangeIp(bool isSuccess)
{
    if(nullptr == m_socketMessageCallBack)
    {
        qWarning()<< "m_socketMessageCallBack is null , init socketMessage ctrl is failed!";
        return;
    }
    if(isSuccess)
    {
        m_sendMsgTask->stop();
        m_sendMsgTask->start(400);
        m_tReSendMessageTimer->stop();
        m_tReSendMessageTimer->start(500);
        cleanMessageQue();
        m_bCanSend = true;
        m_response = true;
        m_socketMessageCallBack->onAutoChangeIpResult("autoChangeIpSuccess");
        return;
    }

    qWarning()<< "justChangeIp connect socket is failed--"<< isSuccess<< m_ipAddress<< m_tcpPort;
    QJsonObject socketJsonObj;
    socketJsonObj.insert("currentSocketIp",m_ipAddress);
    socketJsonObj.insert("errMsg",QStringLiteral("连接失败"));
    socketJsonObj.insert("socketIp",m_ipAddress);
//    YMQosManager::gestance()->addBePushedMsg("XBKsocketDisconnect", socketJsonObj);

    //判断掉线次数 是否满足自动切换ip条件
    if(isSuccess == false)
    {
        qWarning() << QStringLiteral("掉线重连判断ing");
        if(!m_isAutoChangeIping)//正在切换的状态下 不在从发
        {
            ++m_currentReloginTimes;
            if(m_currentReloginTimes >= 3)
            {
                qWarning() << QStringLiteral("3次掉线...");
                //显示网络差界面
                m_socketMessageCallBack->onAutoChangeIpResult("showAutoChangeIpview");

                //切换服务器
                m_isAutoChangeIping = true;
                autoChangeIp();
                m_currentReloginTimes = 0;
            }
        }
    }

    //判断是否是自动ip切换
    if(m_isAutoChangeIping)
    {
        m_isAutoChangeIping = false;
        return;
    }
    else
    {
        m_socketMessageCallBack->onAutoConnectionNetwork();
    }

    //判断是否切换到 http 协议
    if(( m_serverLost >= 5 || m_serverDelay > 50  ||  m_currentReloginTimes == 2 ) /*&& TemporaryParameter::gestance()->m_isStartClass == true*/)
    {
        m_currentReloginTimes = 0;
        stopSendMsg(m_sendMsgTask);
        m_response = false;
    }
}

void SocketManager::autoChangeIp()
{
    if(nullptr == m_socketMessageCallBack)
    {
        qWarning()<< "m_socketMessageCallBack is null , auto changeIp is failed!";
        return;
    }

    //判断是否存在优选ip
    if( m_goodIpList.size() > 0 )
    {
        //判断当前Ip是不是已经被连接过
        int tempHasConnect = -1;
        for(int a = 0; a < m_goodIpList.size(); a++ )
        {
            QVariantMap tempMap = m_goodIpList.at(a).toMap();
            if(m_ipAddress == tempMap["ip"].toString())
            {
                tempHasConnect = a;//获取已经被链接的Ip位置
                qDebug() << "位置" << tempHasConnect;
                break;
            }
        }

        if(tempHasConnect == -1 )
        {
            //没有被连接过
            m_ipAddress = m_goodIpList.at(0).toMap()["ip"].toString();
            m_tcpPort = m_goodIpList.at(0).toMap()["port"].toInt();
        }
        else
        {
            //被连接过位置的下一个 或第一个
            if(tempHasConnect + 1 <= m_goodIpList.size() - 1)
            {
                m_ipAddress = m_goodIpList.at(tempHasConnect + 1).toMap()["ip"].toString();
                m_tcpPort = m_goodIpList.at(tempHasConnect + 1).toMap()["port"].toInt();
            }
            else
            {
                m_ipAddress = m_goodIpList.at(0).toMap()["ip"].toString();
                m_tcpPort = m_goodIpList.at(0).toMap()["port"].toInt();
            }
        }

        //tcp udp 全部切换完毕之后 还掉线就退出
        if(m_currentAutoChangeIpTimes == m_goodIpList.size() * 2)
        {
            if(nullptr != m_socketMessageCallBack)
                m_socketMessageCallBack->onAutoChangeIpResult("autoChangeIpFail");
            return;
        }

        m_socketMessageCallBack->onPersonData(m_ipAddress, m_tcpPort);
        ++m_currentAutoChangeIpTimes;
    }
    else
    {
        qDebug() << QStringLiteral("优选Ip列表为空 ~~~~~~~~~~~~  ");
        m_isAutoChangeIping = false;//重置ip切换标示
        if(nullptr != m_socketMessageCallBack)
            m_socketMessageCallBack->onAutoChangeIpResult("autoChangeIpFail");//
    }
}

void SocketManager::interNetworkChange()
{
    if(nullptr == m_socketMessageCallBack)
    {
        return;
    }
    int types = 0;

    QString strNetWorkMode = m_socketMessageCallBack->getNetWorkMode();
    QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface netInterface, list)
    {
        if (!netInterface.isValid())
        {
            continue;
        }

        QNetworkInterface::InterfaceFlags flags = netInterface.flags();
        if (flags.testFlag(QNetworkInterface::IsRunning)
            && !flags.testFlag(QNetworkInterface::IsLoopBack))    // 网络接口处于活动状态
        {
            if(types == 0)
            {
                strNetWorkMode = netInterface.name();//netInterface.hardwareAddress();
            }
            types++;
        }
    }

    if(!strNetWorkMode.isEmpty())
    {
        strNetWorkMode.remove("#");
        strNetWorkMode.remove("\n");
    }
    m_socketMessageCallBack->onNetWorkMode(strNetWorkMode);
}

void SocketManager::readMessage(QString message)
{
    qDebug()<< "readMessage" << message;
    if(nullptr == m_socketMessageCallBack)
    {
        qWarning()<< "m_socketMessageCallBack is null , auto changeIp is failed!";
        return;
    }

    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qWarning() << QString("Error:Json parse is failed!").toLatin1();
        return;
    }
    QJsonObject jsonMsg = document.object();
    m_socketMessageCallBack->onRecvMessage(jsonMsg, message);
}

//直接发送消息
void SocketManager::sendMessage(QString message)
{
    if(!message.isEmpty() && NULL != m_tcpSocket)
    {
        QString deepinCopyMsg(message.unicode(), message.length()); //深度复制message, 防止数据关联
        qDebug() << " sendMessage -----"<< message;
        m_tcpSocket->sendMsg(deepinCopyMsg.toUtf8());
    }
}

//定时器定时发送消息
void SocketManager::onTimerSendMessage()
{
    QMutexLocker locker(&m_mSendMsgsQueMutex);
    if (m_bCanSend /*&& m_bServerResp*/ && m_qListMsgsQue.size() > 0)
    {
        m_bServerResp = false;
        m_lastSendMsg = m_qListMsgsQue.first() ; //QString::number(m_sendMsgNum, 10) + "#" +
        m_qListMsgsQue.pop_front();

        //发送消息-更新最后发送时间
        m_uLastSendTimeStamp = createTimeStamp();
        if(!m_tReSendMessageTimer->isActive())
        {
            m_tReSendMessageTimer->start(500);
        }

        sendMessage(m_lastSendMsg);
    }
}

void SocketManager::reSendMessage()
{
    quint64 currtime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    quint64 timediff = currtime - m_uLastSendTimeStamp;

    if((timediff >= 2000) && NULL != m_tcpSocket)
    {
        if(!m_lastSendMsg.isEmpty())
        {
         //更新发送时间
         m_uLastSendTimeStamp = createTimeStamp();
         qWarning()<< "reSendMessage"<< m_lastSendMsg;
         sendMessage(m_lastSendMsg);
        }
    }
}

void SocketManager::startSendMsg()
{
    m_sendMsgTask->start(400);
}

void SocketManager::stopSendMsg(QTimer* pTimer)
{
    if (nullptr != pTimer && pTimer->isActive())
    {
        pTimer->stop();
    }
}

void SocketManager::deleteQTimer(QTimer* pTimer)
{
    if(nullptr != pTimer)
    {
        if (pTimer->isActive())
            pTimer->stop();
        delete pTimer;
    }

}

void SocketManager::cleanMessageQue()
{
    QMutexLocker locker(&m_mSendMsgsQueMutex);
    if(!m_qListMsgsQue.empty())
        m_qListMsgsQue.clear();
}

void SocketManager::restGoodIpList()
{
    if(nullptr == m_socketMessageCallBack)
    {
        qWarning()<< "m_socketMessageCallBack is null , init socketMessage ctrl is failed!";
        return;
    }

    //重设优化ip列表
    int tempHasConnect = -1;
    for(int idx = 0; idx < m_goodIpList.size(); idx++ )
    {
        QVariantMap tempMap = m_goodIpList.at(idx).toMap();
        if(m_ipAddress == tempMap["ip"].toString())
        {
            //获取已经被链接的Ip位置
            tempHasConnect = idx;
            break;
        }
    }

    if(tempHasConnect == -1)
    {
        //不包含 默认ip
        QVariantMap tempMap ;
        tempMap.insert("port", QString::number(m_tcpPort));
        tempMap.insert("ip", m_ipAddress);
        m_goodIpList.append(tempMap);
    }
    else
    {
        m_goodIpList.swap(tempHasConnect, m_goodIpList.size() - 1);
    }
}

//时间邮戳
quint64 SocketManager::createTimeStamp()
{
    quint64 timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
    return timestamp;
}

//主动断开 不再重连
void SocketManager::disconnectSocket(bool reconnect)
{
    Q_UNUSED(reconnect);
}

#if QT_VERSION < 0x050000
Q_EXPORT_PLUGIN2(socketmanager, SocketManager)
#endif // QT_VERSION < 0x050000
