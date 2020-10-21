#include <QPluginLoader>
#include "HandsUpCenter.h"
#include "messagepack.h"

HandsUpCenter::HandsUpCenter(QObject *parent) : QObject(parent), m_IHandsUpCtrl(NULL)
{
    m_controlCenter = ControlCenter::getInstance();
}

HandsUpCenter::~HandsUpCenter()
{

}

int HandsUpCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("YMHandsUpManager.dll", Qt::CaseInsensitive))
    {
        QObject* instance = loadPlugin(pluginPathName);
        if(instance)
        {
            m_IHandsUpCtrl = qobject_cast<IHandsUpCtrl *>(instance);
            if(nullptr == m_IHandsUpCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(instance);
                return -1;
            }
            connect(m_IHandsUpCtrl, SIGNAL(sigMsgContent(QJsonObject)), this, SLOT(handsUpReqMsg(QJsonObject)));
            qDebug()<< "qobject_cast is success, pluginPathName is" << pluginPathName;
            return 0;
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
    return -1;
}

int HandsUpCenter::uninit()
{
    return 0;
}

int HandsUpCenter::initHandsUp(QJsonObject json)
{
    int ret = -1;
    if(NULL != m_IHandsUpCtrl)
    {
        ret = m_IHandsUpCtrl->initHandsUp(json);
    }
    return ret;
}

int HandsUpCenter::raiseHandForUp(QString userId, QString groupId)
{
    int ret = -1;
    if(NULL != m_IHandsUpCtrl)
    {
        ret = m_IHandsUpCtrl->raiseHandForUp(userId, groupId);
    }
    return ret;
}

int HandsUpCenter::cancelHandsUp(QString userId, QString groupId)
{
    int ret = -1;
    if(NULL != m_IHandsUpCtrl)
    {
        ret = m_IHandsUpCtrl->cancelHandsUp(userId, groupId);
    }
    return ret;
}

int HandsUpCenter::processResponse(QString userId, int operation)
{
    int ret = -1;
    if(NULL != m_IHandsUpCtrl)
    {
        ret = m_IHandsUpCtrl->processResponse(userId, operation);
    }
    return ret;
}

int HandsUpCenter::processHandsUp(QString userId, uint groupId, TEA_OPERATION operation)
{
    if(NULL != m_IHandsUpCtrl)
    {
        m_IHandsUpCtrl->processHandsUp(userId, groupId, operation);
    }
    return 0;
}

int HandsUpCenter::parseHandsUpMsg(const QJsonObject& msg)
{
    QJsonObject contentJsonObj;
    if(msg.contains("content"))
    {
        contentJsonObj = msg["content"].toObject();
    }
    QString Uid = "";
    if(contentJsonObj.contains("uid"))
    {
        Uid = contentJsonObj.take("uid").toString();
    }
    else
    {
        return -1;
    }
    uint groupId = 0;
    if(contentJsonObj.contains("groupId"))
    {
        groupId = contentJsonObj.take("groupId").toInt();
    }

    QString type;
    if(contentJsonObj.contains("type"))
    {
        type = contentJsonObj.take("type").toString();
    }
    else
    {
        return -1;
    }
    int reqOrCancel = 0;
    if(type == "req")
    {
        reqOrCancel = 1;
    }
    else if(type == "cancel")
    {
        reqOrCancel = 0;
    }
    else if(type == "forceUp" || type == "agree" || type == "forceDown" || type == "refused")
    {
        emit sigHandsUpResponse(Uid, groupId, type);
        return 0;
    }
    emit updateStuList(Uid, groupId, reqOrCancel);
    return 0;
}

void HandsUpCenter::handsUpReqMsg(QJsonObject content)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();
    QString msg = MessagePack::getInstance()->createMessageTemplate("speak", lid, uid, content);
    if(NULL != m_controlCenter)
    {
        m_controlCenter->sendLocalMessage(msg, true, false);
    }
}

QObject* HandsUpCenter::loadPlugin(const QString &pluginPath)
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

void HandsUpCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}
