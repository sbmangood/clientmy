/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  socketmanagercenter.cpp
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

#include <QPluginLoader>
#include "./curriculumdata.h"
#include "getoffsetimage.h"
#include "messagepack.h"
#include "messagetype.h"
#include "datamodel.h"
#include "socketmanagercenter.h"

SocketManagerCenter::SocketManagerCenter(ControlCenter* controlCenter)
    :QObject(nullptr)
    ,m_controlCenter(controlCenter)
    ,m_socketMessageCtrl(nullptr)
{

}

SocketManagerCenter::~SocketManagerCenter()
{
    uninit();
}

void SocketManagerCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("socketmanager.dll", Qt::CaseInsensitive))
    {
        QObject* instance = loadPlugin(pluginPathName);
        if(instance)
        {
            m_socketMessageCtrl = qobject_cast<ISocketMessageCtrl *>(instance);
            if(nullptr == m_socketMessageCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(instance);
                return;
            }
            m_socketMessageCtrl->setSocketMessageCallBack(this);
            m_socketMessageCtrl->initSocketMessageCtrl(TemporaryParameter::gestance()->goodIpList);
            qDebug()<< "qobject_cast is success, pluginPathName is" << pluginPathName;
        }
        else
        {
            qCritical()<< "load plugin is failed, pluginPathName is" << pluginPathName;
        }
    }
    else
    {
        qWarning()<< "plugin is invalid, pluginPathName is" << pluginPathName;
    }
}

void SocketManagerCenter::uninit()
{
    if(m_socketMessageCtrl)
    {
        m_socketMessageCtrl->uninitSocketMessageCtrl();
        unloadPlugin((QObject*)m_socketMessageCtrl);
        m_socketMessageCtrl = nullptr;
    }
    m_controlCenter = nullptr;
}

void SocketManagerCenter::initSocketMessageCtrl(const QVariantList &goodIpList)
{


}

void SocketManagerCenter::uninitSocketMessageCtrl()
{

}

bool SocketManagerCenter::checkServerResponse(QString target, bool bConfirmFinish)
{
    if(nullptr != m_socketMessageCtrl)
    {
        m_socketMessageCtrl->checkServerResponse(target, bConfirmFinish);
    }
    else
    {
        qWarning()<< "m_socketMessageCtrl is null!, check server response is failed" << target<< bConfirmFinish;
        return false;
    }
    return true;
}

void SocketManagerCenter::asynSendMessage(const QString message)
{
    if(nullptr != m_socketMessageCtrl)
    {
        m_socketMessageCtrl->asynSendMessage(message);
    }
    else
    {
        qWarning()<< "m_socketMessageCtrl is null!, asyn send message is failed" << message;
    }
}

void SocketManagerCenter::syncSendMessage(const QString &message)
{
    if(nullptr != m_socketMessageCtrl)
    {
        m_socketMessageCtrl->syncSendMessage(message);
    }
    else
    {
        qWarning()<< "m_socketMessageCtrl is null!, sync send message is failed" << message;
    }
}

void SocketManagerCenter::onRecvMessage(const QJsonObject &jsonMsg, const QString& message)
{
    if(jsonMsg.contains(kSocketCmd))
    {
        QString command =  jsonMsg[kSocketCmd].toString();
        m_controlCenter->processMsg(command, jsonMsg, message);
    }
    else
    {
        qWarning()<< "jsonMsg is not contain command!, recv message is failed" << message;
    }
}

void SocketManagerCenter::onAutoChangeIpResult(const QString & result)
{
    if ("autoChangeIpSuccess" == result)
    {
        QString enterRoomMessage = MessagePack::getInstance()->enterRoomReqMsg(DataCenter::getInstance()->m_bServerResp, DataCenter::getInstance()->m_bConfirmFinish);
        if(nullptr != m_socketMessageCtrl)
        {
            m_socketMessageCtrl->asynSendMessage(enterRoomMessage);
        }
    }

}

void SocketManagerCenter::onNetWorkMode(const QString &netWorkMode)
{
    TemporaryParameter::gestance()->m_netWorkMode = netWorkMode;
    int netType = 3;
    if(netWorkMode.contains(QStringLiteral("wireless")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }
    emit sigInterNetChange(netType);
}

void SocketManagerCenter::onAutoConnectionNetwork()
{

}

void SocketManagerCenter::onPersonData(const QString &address, int udpPort, int port, bool isTcpProtocol)
{
    StudentData::gestance()->m_address = address;
    StudentData::gestance()->m_udpPort = udpPort;
    StudentData::gestance()->m_port = port;
    StudentData::gestance()->m_isTcpProtocol = isTcpProtocol;
}

QString SocketManagerCenter::getNetWorkMode()
{
    return TemporaryParameter::gestance()->m_netWorkMode;
}

int SocketManagerCenter::getPersonData(QString &address, int &udpPort, int &port, bool &isTcpProtocol)
{
    address = StudentData::gestance()->m_address;
    udpPort = StudentData::gestance()->m_udpPort;
    port = StudentData::gestance()->m_port;
    isTcpProtocol = StudentData::gestance()->m_isTcpProtocol;
    qDebug()<< address<<port<< udpPort;
    return 0;
}

int SocketManagerCenter::getServerQosInfo(int &serverDelay, int &serverLost)
{
    serverLost = StudentData::gestance()->m_currentServerLost;
    serverDelay = StudentData::gestance()->m_currentServerDelay;
    return 0;
}

QObject* SocketManagerCenter::loadPlugin(const QString &pluginPath)
{
    QObject *plugin = nullptr;
    QFile file(pluginPath);
    if (!file.exists())
    {
        qWarning()<< pluginPath<< "file is not file";
        return plugin;
    }

    QPluginLoader loader(pluginPath);
    plugin = loader.instance();
    if (nullptr == plugin)
    {
        qCritical()<< pluginPath<< "failed to load plugin" << loader.errorString();
    }

    return plugin;
}

void SocketManagerCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}

