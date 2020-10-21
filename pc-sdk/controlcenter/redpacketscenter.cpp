#include <QPluginLoader>
#include "redpacketscenter.h"
#include "messagepack.h"
#include "datacenter.h"

RedPacketsCenter::RedPacketsCenter(ControlCenter* controlCenter)
    :QObject(nullptr)
    ,m_controlCenter(controlCenter)
    ,m_redPacketCtrl(nullptr)
    ,m_httpAccessMgr(nullptr)
    ,m_instance(nullptr)
{

}

RedPacketsCenter::~RedPacketsCenter()
{
    uninit();
}


void RedPacketsCenter::init(const QString &pluginPathName)
{
    if(pluginPathName.endsWith("redpacket.dll", Qt::CaseInsensitive))
    {
        m_instance = loadPlugin(pluginPathName);
        if(m_instance)
        {
            m_redPacketCtrl  = qobject_cast<IRedPacketCtrl *>(m_instance);
            if(nullptr == m_redPacketCtrl)
            {
                qWarning()<< "qobject_cast is failed, pluginPathName is" << pluginPathName;
                unloadPlugin(m_instance);
                return;
            }
            m_redPacketCtrl->setRedPacketsCallBack(this);
            m_redPacketCtrl->init(DataCenter::getInstance()->m_redPacketsId, DataCenter::getInstance()->m_redCount,
                                  DataCenter::getInstance()->m_redTime, DataCenter::getInstance()->m_countDownTime,
                                  DataCenter::getInstance()->m_enableRedPackets);
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
    m_httpAccessMgr = new QNetworkAccessManager();
}

void RedPacketsCenter::uninit()
{
    if(nullptr != m_httpAccessMgr)
    {
        delete m_httpAccessMgr;
        m_httpAccessMgr = nullptr;
    }

    if(m_redPacketCtrl)
    {
        m_redPacketCtrl->uninit();
        m_redPacketCtrl = nullptr;
    }
    if(m_instance)
    {
        unloadPlugin(m_instance);
        m_instance = nullptr;
    }
    m_controlCenter = nullptr;
}

void RedPacketsCenter::beginRedPackets()
{
    if(nullptr != m_redPacketCtrl)
    {
        m_redPacketCtrl->beginRedPackets();
    }
    else
    {
        qWarning()<< "m_redPacketCtrl is null!, begin red packets is failed" ;
    }
}

void RedPacketsCenter::endRedPackets(const QJsonObject &redPacketsDataObj)
{   
    if(nullptr != m_redPacketCtrl)
    {
        m_redPacketCtrl->endRedPackets(redPacketsDataObj);
    }
    else
    {
        qWarning()<< "m_redPacketCtrl is null!, end red packets is failed" << redPacketsDataObj;
    }
}

void RedPacketsCenter::redPacketSize(int packetId, int packetSize)
{
    if(nullptr != m_redPacketCtrl)
    {
        m_redPacketCtrl->redPacketSize(packetId, packetSize);
    }
    else
    {
        qWarning()<< "m_redPacketCtrl is null!, red packet size is failed" <<packetSize ;
    }
}

void RedPacketsCenter::queryRedPackets()
{
    QJsonObject obj;
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();
    QString qsLid = QString::number(lid);
    QString qsUid = QString::number(uid);
    obj.insert("token", StudentData::gestance()->m_token);
    obj.insert("version", "v1");
    obj.insert("redPacketNum", DataCenter::getInstance()->m_redPacketsId);
    obj.insert("lid", qsLid);
    obj.insert("uid", qsUid);
    QJsonDocument doc(obj);
    QString msg = QString(doc.toJson(QJsonDocument::Compact));
    qDebug()<< "queryRedPackets---" <<msg;

    QNetworkRequest netRequest;
    QString qsUrl = QString("http://") + StudentData::gestance()->m_address + QString("/socks/queryredpackets");
    QUrl url(qsUrl);
    url.setPort(StudentData::gestance()->m_httpPort); //HTTP端口5251
    netRequest.setUrl(url);

    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    netRequest.setRawHeader("TOKEN", StudentData::gestance()->m_token.toUtf8());

    QNetworkReply *netReply;
    QNetworkAccessManager *httpAccessMgr = new QNetworkAccessManager();
    netReply = httpAccessMgr->post(netRequest, msg.toUtf8());
    qDebug() << "==queryRedPackets==" << url <<  StudentData::gestance()->m_httpPort << StudentData::gestance()->m_token.toUtf8() << msg;
    QEventLoop httploop;
    connect(netReply, SIGNAL(finished()), &httploop, SLOT(quit()));
    QTimer* timer = new QTimer();
    timer->setInterval(5000);
    timer->setSingleShot(true);
    connect(timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    timer->start();
    httploop.exec();

    if(nullptr != timer)
    {
        if(timer->isActive())
            timer->stop();

        delete timer;
        timer = nullptr;
    }

    QByteArray replyData = netReply->readAll();
    qDebug()<< "queryRedPackets recv" << replyData;
    QJsonObject jsonObj = QJsonDocument::fromJson(replyData).object();
    qDebug()<< "queryRedPackets recv --" << jsonObj;
    endRedPackets(jsonObj);
}

bool RedPacketsCenter::onSendRedPackets()
{
    if(m_controlCenter != nullptr)
    {
        QJsonObject obj;
        obj.insert("sumCredit", DataCenter::getInstance()->m_sumCredit);
        obj.insert("redCount", DataCenter::getInstance()->m_redCount);
        obj.insert("normalRange", DataCenter::getInstance()->m_normalRange);
        obj.insert("limitRange", DataCenter::getInstance()->m_limitRange);
        obj.insert("redTime", DataCenter::getInstance()->m_redTime);
        obj.insert("max", DataCenter::getInstance()->m_max);
        obj.insert("countDownTime", DataCenter::getInstance()->m_countDownTime);
        obj.insert("redPacketNum", DataCenter::getInstance()->m_redPacketNum);

        QString msg = MessagePack::getInstance()->sendRedPacketsMsg(obj);
        m_controlCenter->asynSendMessage(msg);
    }
    else
    {
        qWarning() << "send red packet is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

bool RedPacketsCenter::onHitRedPacket(int packetId)
{
    if(m_controlCenter != nullptr)
    {    
        QJsonObject obj;
        quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
        quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();
        QString qsLid = QString::number(lid);
        QString qsUid = QString::number(uid);
        obj.insert("token", StudentData::gestance()->m_token);
        obj.insert("version", "v1");
        obj.insert("redPacketNum", DataCenter::getInstance()->m_redPacketsId);
        obj.insert("groupId", StudentData::gestance()->m_groupId);
        obj.insert("userName", DataCenter::getInstance()->m_nickName);
        obj.insert("currentPacketNum", packetId);
        obj.insert("lid", qsLid);
        obj.insert("uid", qsUid);
        QJsonDocument doc(obj);
        QString msg = QString(doc.toJson(QJsonDocument::Compact));

        QNetworkRequest netRequest;
        QString qsUrl = QString("http://") + DataCenter::getInstance()->m_redPacketURL + QString("/socks/grabredpackets");
        QUrl url(qsUrl);
        netRequest.setUrl(url);
        netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
        netRequest.setRawHeader("TOKEN", StudentData::gestance()->m_token.toUtf8());

        QNetworkReply *netReply;
        qDebug()<< "onHitRedPacket---" <<msg << url;
        netReply = m_httpAccessMgr->post(netRequest, msg.toUtf8());
        connect(m_httpAccessMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(onHttpReply(QNetworkReply*)));

    }
    else
    {
        qWarning() << " hit red packet is failed, m_controlCenter is null!";
        return false;
    }
    return true;
}

QObject* RedPacketsCenter::loadPlugin(const QString &pluginPath)
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

void RedPacketsCenter::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}

void RedPacketsCenter::onHttpReply(QNetworkReply *reply)
{
    if(nullptr != reply)
    {
        QByteArray replyData = reply->readAll();
        QJsonObject jsonObj = QJsonDocument::fromJson(replyData).object();

        if(!jsonObj.isEmpty())
        {
            DataCenter::getInstance()->m_historyCredit = jsonObj["historyCredit"].toInt();
            int packetId = jsonObj.value("currentPacketNum").toInt();
            int currentCredit = jsonObj["integral"].toInt();

            qDebug()<< "onHttpReply--"<< packetId<< currentCredit<< jsonObj;
            redPacketSize(packetId, currentCredit);
        }
        else
        {
            qWarning()<< "onHttpReply jsonMsg is not contain command!, " << replyData;
        }
        reply->deleteLater();
    }
    else
    {
        qWarning()<< "http reply is null!";
    }

}

