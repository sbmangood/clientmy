#include "sockethandler.h"
#include <QtNetwork>
#include <QPluginLoader>
#include <QTimer>
#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#include "../YMCommon/qosV2Manager/YMQosApiMannager.h"

//通讯协议版本
const quint8 COMMUNICATION_PROTOCOL_VER = 1;

//协议指令管理--begin
const QString kSocketCmd = "cmd";
const QString kSocketSn = "sn";
const QString kSocketMn = "mn";
const QString kSocketVer = "v";
const QString kSocketLid = "lid";
const QString kSocketUid = "uid";
const QString kSocketName = "name";
const QString kSocketTs = "ts";
const QString kSocketHb = "hb";
const QString kSocketAck = "ack";
const QString kSocketContent = "content";
const QString kSocketEnterRoom = "enterRoom";
const QString kSocketExitRoom = "exitRoom";
const QString kSocketEnterFailed = "enterFailed";
const QString kSocketFinish = "finish";
const QString kSocketUsersStatus = "usersStatus";
const QString kSocketSynFin = "synFin";
const QString kSocketTrail = "trail";
const QString kSocketPoint = "point";
const QString kSocketDoc = "doc";
const QString kSocketAV = "av";
const QString kSocketAVPath = "path";
const QString kSocketAVSuffix = "suffix";
const QString kSocketPage = "page";
const QString kSocketPageId = "pageId";
const QString kSocketAuth = "auth";
const QString kSocketMuteAll = "muteAll";
const QString kSocketKickOut = "kickOut";
const QString kSocketZoom = "zoom";
const QString kSocketTk = "tk";
const QString kSocketRwnd = "rwnd";
const QString kSocketAppVersion = "appVersion";
const QString kSocketSysInfo = "sysInfo";
const QString kSocketDevInfo = "deviceInfo";
const QString kSocketUserType = "userType";
const QString kSocketPlat = "plat";
const QString kSocketIsOnline = "isOnline";
const QString kSocketCode = "code";
const QString kSocketIncludeSelf = "includeSelf";
const QString kSocketSynMn = "synMn";
const QString kSocketHttpData = "data";
const QString kSocketHttpMsgs = "msgs";
const QString kSocketDocPageNo = "pageNo";
const QString kSocketDocTotalNum = "totalNum";
const QString kSocketDocDockId = "dockId";
const QString kSocketDocUrls = "urls";
const QString kSocketAVFlag = "flag";
const QString kSocketTime = "time";
const QString kSocketPageOpType = "type";
const QString kSocketAuthUp = "up";
const QString kSocketAuthAudio = "audio";
const QString kSocketAuthVideo = "video";
const QString kSocketMuteAllRet = "ret";
const QString kSocketTEA = "TEA";
const QString kSocketTPC = "T";
const QString kSocketSPC = "S";
const QString kSocketSTU = "STU";
const QString kSocketPointX = "x";
const QString kSocketPointY = "y";
const QString kSocketOnlineState = "isOnline";
const QString kSocketDockDefault = "DEFAULT";
const QString kSocketDockDefaultZero = "000000";
const QString kSocketSuccess = "success";
const QString kSocketImages = "images";
const QString kSocketRatio = "ratio";
const QString kSocketOffsetX = "offsetX";
const QString kSocketOffsetY = "offsetY";
const QString kSocketOperation = "operation";
const QString kSocketReward = "reward";
const QString kSocketRoll = "roll";
const QString kSocketResponder = "responder";
const QString kSocketTimer = "timer";
const QString kSocketFlag = "flag";
const QString kSocketType = "type";
const QString kSocketIsHavingClass = "isHavingClass";
const QString kSocketIsAlreadyClass = "isAlreadyClass";
const QString kSocketStartClass = "startClass";
const QString kSocketH5Url = "h5Url";
const QString kSocketDocType = "docType";
const QString kSocketPlayAnimation = "playAnimation";
const QString kSocketStep = "step";
const QString kSocketPageNo = "pageNo";
const QString kSocketNetType = "netType";
//协议指令管理--end

SocketHandler::SocketHandler(QObject *parent) : QObject(parent)
    , m_canSend(false)
    , m_lastRecvNum("0")
    , m_lastRecvMsg("")
    , m_includeSelfMsg("1")
    , m_currentCourse("DEFAULT")
    , m_currentPage(0)
    , m_isInit(false)
    , m_firstPage(0)
    , m_sendMsgNum(1)
    , m_isGotoPageRequst(false)
    , currentReloginTimes(0)
    , m_sysnStatus(false)
    ,m_socketMessageCtrl(nullptr)
{
    QList<MessageModel> list;
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
    m_pages.insert("DEFAULT", list);

    m_uLastSendTimeStamp = 0;
    m_miniWhiteBoardCtrl = new MiniWhiteBoardCtrl(this);

    QString socketPath = QCoreApplication::applicationDirPath() + "/socketmanager.dll";
     qDebug() << "=====SocketHandler::inlit====="<< socketPath;
    init(socketPath);

    QString netTypeStr = TemporaryParameter::gestance()->m_netWorkMode;
    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        netType = 3;
        m_netType = "wifi";
    }
    else
    {
        netType = 4;
        m_netType = "cable";
    }

    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;

    //startSendAudioQuality();

    m_uServerSn = 0;
    m_uMessageNum = 1;

    m_currentPlanId = "";
    m_currentColumnId = "";
    m_currentQuestionId = "";

}

//发送本地消息
void SocketHandler::sendLocalMessage(QString message, bool append, bool drawPage)
{
//    qDebug() << "SocketHandler::sendLocalMessage:" << cmd << append << drawPage << m_isInit << m_currentPage;
    if(message.contains("courware")) //如果课件默认值是1则改为总页数
    {
        if(m_pages.contains("DEFAULT"))
        {
            message.replace("\"pageIndex\":\"1\"", "\"pageIndex\":\"" + QString::number(m_pages.value("DEFAULT").size()) + "\"");
            //qDebug() << "default" << m_pages.value("DEFAULT").size();
        }
    }

    QString command = parseMessageCommand(message);
    if(!command.isEmpty())
    {
        parseUserCommandOp(command, message); //本地缓存
    }

    if (drawPage)
    {
        if(m_pages[m_currentCourse].size() < 1)  //画一页
        {
            sigEnterOrSync(18);
            return;
        }
        //qDebug()  << "-----------SocketHandler::sendLocalMessage------------" << m_pages[m_currentCourse].size();
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
        emit sigDrawPage(model);
    }

    if(!command.isEmpty() && m_socketMessageCtrl != nullptr)
    {
        if(m_isRemoverPage)
        {
            return;
        }
        if(append) //仅且需要服务器回执的消息加入队列中
        {
            m_socketMessageCtrl->asynSendMessage(message);
        }
        else
        {
            m_socketMessageCtrl->syncSendMessage(message); //直接发送至服务器, 不需要服务器ack的协议信息
        }
    }
}

int SocketHandler::getCurrentPage(QString docId)
{
    int cuttents = 1;
    cuttents = (m_currentPage >= m_pages[docId].size() ? m_pageSave.value(docId, 1) : m_currentPage);
    qDebug() << "===cuttents::old=====" << cuttents << m_pages[docId].size() << m_pageSave.value(docId, 1);
    return cuttents;
}

void SocketHandler::sendAudioQuality()
{
    if( TemporaryParameter::gestance()->m_ipContents.size() > 0 )
    {
        QMap<QString, QString>::Iterator  it = TemporaryParameter::gestance()->m_ipContents.begin();
        while(it != TemporaryParameter::gestance()->m_ipContents.end())
        {
            //拼接数据   QString contents = QString("%1,%2,%3").arg(quality).arg(delay).arg(lost);
            if( QString(it.value()).split(",").size() == 3)
            {
                QString tempString = QString("0#SYSTEM{\"command\":\"audioQuality\",\"content\":{\"userId\":\"%1\",\"delay\":\"%2\",\"lost\":\"%3\",\"quality\":\"%4\",\"bitrate\":\"%5\",\"supplier\":\"%6\",\"videoType\":\"%7\"},\"domain\":\"system\"}").arg(it.key()).arg(QString(it.value()).split(",").at(1)).arg(QString(it.value()).split(",").at(2)).arg(QString(it.value()).split(",").at(0)).arg(TemporaryParameter::gestance()->bitRate).arg(TemporaryParameter::gestance()->m_supplier).arg(TemporaryParameter::gestance()->m_videoType);
                //sendMessage(tempString);
                //qDebug()<<QStringLiteral("TemporaryParameter::gestance()->m_ipContents.size() 语音质量数据")<<tempString<<TemporaryParameter::gestance()->m_ipContents.size() ;
            }
            ++it;
        }
    }
    else
    {
        //qDebug()<<QStringLiteral("TemporaryParameter::gestance()->m_ipContents.size() 语音质量数据为空");
    }
}

void SocketHandler::onRecvMessage(const QJsonObject &jsonMsg, const QString& message)
{
    //解析必要信息
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,与服务器联合检查!").toLatin1();
        return;
    }

    QJsonObject jsonObj = document.object();

    QString qsUid = "";
    if(jsonObj.contains(kSocketUid))
    {
        qsUid = QString::number(jsonObj.take(kSocketUid).toVariant().toLongLong());
        qDebug() << "qsUid=" << qsUid;
    }

    //非法用户(不是我自己)
    QString qsCurrUid = StudentData::gestance()->m_currentUserId;
    if(qsUid != qsCurrUid)
    {
        //非法用法,断开连接
       // m_socket->DisconnectWithServer();
        //return;
    }

    quint64 uSn = 0;
    if(jsonObj.contains(kSocketTs))
    {
        uSn = jsonObj.take(kSocketTs).toVariant().toLongLong();
    }

    TemporaryParameter::gestance()->avPlaySetting.currentTime = uSn;

    //解析命令

    QString recvNum("-1");
    QString fromUser(qsCurrUid);
    QString msgJson(message);

    qDebug() << "==SocketHandler::readMessage==" << recvNum << fromUser << msgJson;

    parseMsg(recvNum, fromUser, msgJson);
}

void SocketHandler::onAutoChangeIpResult(const QString & result)
{
    emit autoChangeIpResult(result);
    if ("autoChangeIpSuccess" == result)
    {
        QString enterRoomMessage = enterRoomReqMsgTemplate();
        if(nullptr != m_socketMessageCtrl)
        {
            m_socketMessageCtrl->asynSendMessage(enterRoomMessage);
        }
    }

}

void SocketHandler::onNetWorkMode(const QString &netWorkMode)
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

void SocketHandler::onAutoConnectionNetwork()
{
    //自动连接网络
    emit sigAutoConnectionNetwork();
}

void SocketHandler::onPersonData(const QString &address, int port)
{
    StudentData::gestance()->m_address = address;
    StudentData::gestance()->m_port = port;
}

QString SocketHandler::getNetWorkMode()
{
    return TemporaryParameter::gestance()->m_netWorkMode;
}

void SocketHandler::init(const QString &pluginPathName)
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
            qDebug()<<"%%%%%%%%%%%%%"<<TemporaryParameter::gestance()->goodIpList<<StudentData::gestance()->m_address<<
                    StudentData::gestance()->m_port<<StudentData::gestance()->m_currentServerDelay<<StudentData::gestance()->m_currentServerLost;
            m_socketMessageCtrl->initSocketMessageCtrl(TemporaryParameter::gestance()->goodIpList, StudentData::gestance()->m_address,
                StudentData::gestance()->m_port, StudentData::gestance()->m_currentServerDelay, StudentData::gestance()->m_currentServerLost);
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

void SocketHandler::uninit()
{
    if(m_socketMessageCtrl)
    {
        m_socketMessageCtrl->uninitSocketMessageCtrl();
        unloadPlugin((QObject*)m_socketMessageCtrl);
        m_socketMessageCtrl = nullptr;
    }
}

QObject* SocketHandler::loadPlugin(const QString &pluginPath)
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

void SocketHandler::unloadPlugin(QObject* instance)
{
    if (nullptr == instance)
    {
        qWarning()<< "plugin is failed!";
        return;
    }
    delete instance;
}


void SocketHandler::startSendAudioQuality()
{
    m_sendAudioQualityTask->start(120000);
}

void SocketHandler::stopSendAudioQuality()
{
    if(m_sendAudioQualityTask->isActive())
    {
        m_sendAudioQualityTask->stop();
    }
}

//主动断开 不再重连
void SocketHandler::disconnectSocket(bool reconnect)
{
    Q_UNUSED(reconnect);
}

//时间邮戳
quint64 SocketHandler::createTimeStamp()
{
    quint64 timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
    return timestamp;
}

//通用消息创建模板
QString SocketHandler::createMessageTemplate(QString command, quint64 lid, quint64 uid, QJsonObject content)
{
    QJsonObject messageTemplate;
    if(kSocketAck == command || kSocketEnterRoom == command || kSocketHb == command || kSocketSynFin == command || kSocketPoint == command)
    {
        QMutexLocker locker(&m_mMessageNumMutex);
        messageTemplate[kSocketSn] = 0;
    }
    else
    {
        QMutexLocker locker(&m_mMessageNumMutex);
        messageTemplate[kSocketSn]  = (qint32)(m_uMessageNum++);
    }

    messageTemplate[kSocketVer] = COMMUNICATION_PROTOCOL_VER;
    messageTemplate[kSocketCmd] = command;

    QString qsLid = QString::number(lid);
    QString qsUid = QString::number(uid);

    messageTemplate.insert(kSocketLid, qsLid);
    messageTemplate.insert(kSocketUid, qsUid);

    //协议中的content内容
    if(!content.isEmpty())
    {
        messageTemplate[kSocketContent] = content;
    }

    QJsonDocument doc(messageTemplate);
    return QString(doc.toJson(QJsonDocument::Compact));
}

//回执服务器请求消息模板
QString SocketHandler::ackServerMsgTemplate(quint32 serverSn)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    //协议中的content内容
    content.insert(kSocketSn, (qint32)serverSn);
    content.insert(kSocketRwnd, 1);//暂时滑动窗口为1

    QString msg = createMessageTemplate(kSocketAck, lid, uid, content);
    return msg;
}

//客户端心跳信息模板
QString SocketHandler::keepAliveReqMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    QString msg = createMessageTemplate(kSocketHb, lid, uid, content);
    return msg;
}

//进入房间请求消息模板
QString SocketHandler::enterRoomReqMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    qDebug() << "UID:" << StudentData::gestance()->m_currentUserId << StudentData::gestance()->m_lessonId <<  uid;

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketTk, StudentData::gestance()->m_token);
    content.insert(kSocketAppVersion, StudentData::gestance()->m_appVersion);
    content.insert(kSocketSysInfo, StudentData::gestance()->m_sysInfo);
    content.insert(kSocketDevInfo, YMUserBaseInformation::system);
    content.insert(kSocketUserType, kSocketTEA);
    content.insert(kSocketPlat, kSocketTPC);
    content.insert(kSocketNetType,m_netType);

    //进入房间-第一条信息
    m_bServerResp = true;

    //进入房间-结束课程设置为false
    m_bConfirmFinish = false;

    QString msg = createMessageTemplate(kSocketEnterRoom, lid, uid, content);
    return msg;
}

void SocketHandler::finishRespExitRoom()
{
    uninit();
    //结束进程
    QProcess process;
    process.execute(QString("TASKKILL /IM %1 /F") .arg(StudentData::gestance()->strAppName));
    process.close();
}

QString SocketHandler::syncUserHistroyReqMsgTemplate(quint8 self)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    //fix: 新协议lid,uid使用string
    QString qsLid = QString::number(lid);
    QString qsUid = QString::number(uid);

     //协议中的content内容
    content.insert(kSocketLid, qsLid);
    content.insert(kSocketUid, qsUid);
    content.insert(kSocketSynMn,(qint32)m_uServerSn);
    content.insert(kSocketIncludeSelf, self);

    QJsonDocument doc(content);
    return QString(doc.toJson(QJsonDocument::Compact));
}

QString SocketHandler::syncUserHistroyFinMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    QString msg = createMessageTemplate(kSocketSynFin, lid, uid, content);
    return msg;
}

 QString SocketHandler::trailReqMsgTemplate(QJsonObject content)
 {
     if(!content.isEmpty())
     {
         quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
         quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

         //fix: 协议中新增dockId pageId
         QString dockId = m_currentCourse;
         if(dockId == kSocketDockDefault)
         {
             dockId = "000000"; //fix: 本地有kSocketDockDefault, 则设置为QString("0")
         }

         QString pageId = QString::number(m_currentPage);

         content.insert(kSocketDocDockId, dockId);
         content.insert(kSocketPageId, pageId);

         QString msg = createMessageTemplate(kSocketTrail, lid, uid, content);
         return msg;
     }
     else
     {
         return "";
     }
 }

 QString SocketHandler::pointReqMsgTemplate(qint32 x, qint32 y)
 {
     quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
     quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

     QJsonObject content;

      //协议中的content内容
     content.insert(kSocketPointX, x);
     content.insert(kSocketPointY, y);

     QString msg = createMessageTemplate(kSocketPoint, lid, uid, content);
     return msg;
 }

 QString SocketHandler::docReqMsgTemplate(int currPageNo, int pageTotal, QString coursewareId,QJsonArray imgUrlList,QString h5Url,int docType)
 {
     quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
     quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

     QJsonObject content;

      //协议中的content内容
     content.insert(kSocketDocPageNo, currPageNo);
     content.insert(kSocketDocTotalNum, pageTotal);
     content.insert(kSocketDocDockId, coursewareId);
     content.insert(kSocketDocUrls,imgUrlList);
     content.insert(kSocketH5Url,h5Url);
     content.insert(kSocketDocType,docType);
     QString msg = createMessageTemplate(kSocketDoc, lid, uid, content);
     return msg;
 }

 QString SocketHandler::avReqMsgTemplate(int playStatus, int timeSec, QString coursewareId,QString path,QString suffix)
  {
      quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
      quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

      QJsonObject content;

       //协议中的content内容
      content.insert(kSocketAVFlag, playStatus);
      content.insert(kSocketTime, timeSec);
      content.insert(kSocketDocDockId, coursewareId);
      content.insert(kSocketAVPath,path);
      content.insert(kSocketAVSuffix,suffix);
      QString msg = createMessageTemplate(kSocketAV, lid, uid, content);
      return msg;
  }

QString SocketHandler::pageReqMsgTemplate(int opType, int currPageNo, int pageTotal, QString coursewareId)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketPageOpType, opType);
    content.insert(kSocketDocPageNo, currPageNo);
    content.insert(kSocketDocTotalNum, pageTotal);
    content.insert(kSocketDocDockId, coursewareId);

    //fix: 协议中新增pageId
    QString pageId = QString::number(m_currentPage);
    content.insert(kSocketPageId, pageId);

    QString msg = createMessageTemplate(kSocketPage, lid, uid, content);
    return msg;
}

QString SocketHandler::authReqMsgTemplate(QString whoUid, qint8 upState, qint8 trailState, qint8 audioState, qint8 videoState)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    //fix: 新协议lid,uid使用string
    QString qsWhoUid = whoUid;

     //协议中的content内容
    content.insert(kSocketUid, qsWhoUid);
    content.insert(kSocketAuthUp, upState);
    content.insert(kSocketTrail, trailState);
    content.insert(kSocketAuthAudio, audioState);
    content.insert(kSocketAuthVideo, videoState);
    QString msg = createMessageTemplate(kSocketAuth, lid, uid, content);
    return msg;
}

//清屏、撤销操作
QString SocketHandler::operationMsgTemplate(int opType, int pageNo, int totalNum,QString coursewareId)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketPageOpType,opType);
    content.insert(kSocketDocPageNo, pageNo);
    content.insert(kSocketDocTotalNum, totalNum);
    QString pageId = QString::number(m_currentPage);
    content.insert(kSocketPageId,pageId);
    content.insert(kSocketDocDockId,coursewareId);

    QString msg = createMessageTemplate(kSocketOperation, lid, uid, content);
    return msg;
}

QString SocketHandler::rewardMsgTemplate(QString whoUid, int rewardType, int millisecond, QString userName)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketUid, whoUid);
    content.insert(kSocketType, rewardType);
    content.insert(kSocketTime, millisecond);
    content.insert(kSocketName, userName);

    QString msg = createMessageTemplate(kSocketReward, lid, uid, content);
    return msg;
}

QString SocketHandler::rollMsgTemplate(QString whoUid, int rollType, QString userName)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketUid, whoUid);
    content.insert(kSocketType, rollType);
    content.insert(kSocketName, userName);

    QString msg = createMessageTemplate(kSocketRoll, lid, uid, content);
    return msg;
}

QString SocketHandler::responderMsgTemplate(int respType, int timesec)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketType, respType);
    content.insert(kSocketTime, timesec);

    QString msg = createMessageTemplate(kSocketResponder, lid, uid, content);
    return msg;
}

QString SocketHandler::timerMsgTemplate(int timerType, int flag, int timesec)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketType, timerType);
    content.insert(kSocketFlag, flag);
    content.insert(kSocketTime, timesec);

    QString msg = createMessageTemplate(kSocketTimer, lid, uid, content);
    return msg;
}

QString SocketHandler::startClassMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    QString msg = createMessageTemplate(kSocketStartClass, lid, uid, content);
    return msg;
}

QString SocketHandler::muteAllReqMsgTemplate(int muteAllState)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketMuteAllRet, muteAllState);

    QString msg = createMessageTemplate(kSocketMuteAll, lid, uid, content);
    return msg;
}

QString SocketHandler::kickOutReqMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    QString msg = createMessageTemplate(kSocketKickOut, lid, uid, content);
    return msg;
}

QString SocketHandler::exitRoomReqMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    //退出房间-设置为true
    m_bConfirmFinish = true;

    QString msg = createMessageTemplate(kSocketExitRoom, lid, uid, content);
    return msg;
}

QString SocketHandler::finishMsgTemplate()
{
    quint64 lid = StudentData::gestance()->m_lessonId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;//空内容

    //退出房间-结束课程设置为true
    m_bConfirmFinish = true;

    QString msg = createMessageTemplate(kSocketFinish, lid, uid, content);
    return msg;
}

QString SocketHandler::zoomMsgTemplate(QString coursewareId, double ratio, double offsetX, double offsetY)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

    QString pageId = QString::number(m_currentPage);

    //调节精度
    int  factor = 1000000;

    qint32 factorRatio = qint32(ratio * factor);
    qint32 factorOffsetX = qint32(offsetX * factor);
    qint32 factorOffsetY = qint32(offsetY * factor);

     //协议中的content内容
    content.insert(kSocketDocDockId, coursewareId);
    content.insert(kSocketPageId, pageId);
    content.insert(kSocketRatio, factorRatio);
    content.insert(kSocketOffsetX, factorOffsetX);
    content.insert(kSocketOffsetY, factorOffsetY);

    QString msg = createMessageTemplate(kSocketZoom, lid, uid, content);
    return msg;
}

//清屏、撤销数据解析
void SocketHandler::cacheOperationMessage(QString &fromUid, QString &message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    int currPageOp = 0;
    int currPageNo = 0;
    int currPageTotalNum = 0;

    if(contentJsonObj.contains(kSocketPageOpType))
    {
        currPageOp = contentJsonObj.take(kSocketPageOpType).toVariant().toLongLong();
    }

    if(contentJsonObj.contains(kSocketDocPageNo))
    {
        currPageNo = contentJsonObj.take(kSocketDocPageNo).toVariant().toLongLong();
    }

    if(contentJsonObj.contains(kSocketDocTotalNum))
    {
        currPageTotalNum = contentJsonObj.take(kSocketDocTotalNum).toVariant().toLongLong();
    }

    //安全性检查
    m_currentPage = (m_currentPage >= m_pages[m_currentCourse].size()) ? (m_pages[m_currentCourse].size() - 1) : m_currentPage;

    switch(currPageOp)
    {
        case 1: //清屏
        {
            m_pages[m_currentCourse][m_currentPage].clear(fromUid);
        }
        case 2: //撤销
        {
            qDebug() << "=====undo===" << m_currentCourse << fromUid;
            m_pages[m_currentCourse][m_currentPage].undo(fromUid);
        }
        default:
        {
            qDebug() << QString("翻页/加页/删页操作类型不在范围内!").toLatin1();
        }
    }

    if(m_pages[m_currentCourse].size() > m_currentPage)
    {
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
        emit sigDrawPage(model);
    }
}

void SocketHandler::cacheReward(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    QString whoUid  = "";
    if(contentJsonObj.contains(kSocketUid))
    {
        whoUid = contentJsonObj.take(kSocketUid).toString();
    }

    qint32 rewardType = 0;
    if(contentJsonObj.contains(kSocketType))
    {
        rewardType = contentJsonObj.take(kSocketType).toInt();
    }

    qint32 millisecond = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        millisecond = contentJsonObj.take(kSocketTime).toInt();
    }

    //缓存奖励累计信息
    StudentData::gestance()->addReward(whoUid);
}

void SocketHandler::cacheResponder(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();

    QString whoUid  = "";
    if(jsonObj.contains(kSocketUid))
    {
        whoUid = jsonObj.take(kSocketUid).toString();
    }

    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    if(!contentJsonObj.isEmpty())
    {
       contentJsonObj.insert("userId",whoUid);
       sigStartResponder(contentJsonObj);
    }

    qint32 responderType = 0;
    if(contentJsonObj.contains(kSocketType))
    {
        responderType = contentJsonObj.take(kSocketType).toInt();
    }

    qint32 timeSec = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        timeSec = contentJsonObj.take(kSocketTime).toInt();
    }

    //缓存抢答信息
}

void SocketHandler::cacheStartClass()
{
    //第一次开始上课清除所有操作
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString saveFilePath = bufferFilePath + "/teaClassBegin.dll";
    QFile file(saveFilePath);
    QTextStream textOpera(&file);
    qDebug() << "==cacheStartClass::saveUserInfo==" << saveFilePath;
    if(file.open(QFile::ReadWrite))
    {
        if(file.exists())
        {
            QString  liveRoom = textOpera.readAll();
            if(liveRoom.contains(StudentData::gestance()->m_lessonId))
            {
                textOpera.flush();
                return;
            }
        }
        textOpera.seek(0);
        textOpera << StudentData::gestance()->m_lessonId;
        textOpera.flush();
    }
    m_pages.clear();
    m_pageSave.clear();
    TemporaryParameter::gestance()->m_pageSave.clear();
    StudentData::gestance()->m_reward.clear();
    StudentData::gestance()->m_userAuth.clear();
    StudentData::gestance()->m_userUp.clear();
    StudentData::gestance()->m_cameraPhone.clear();
    QList<MessageModel> list;
    list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false));
    m_pages.insert("DEFAULT", list);
    m_currentPage = 0;
    m_currentCourse = "DEFAULT";
    MessageModel model = m_pages[m_currentCourse][m_currentPage];
    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
    emit sigDrawPage(model);
    emit sigClearScreen();
}

void SocketHandler::cacheDocInfo(QJsonArray coursewareUrls, QString coursewareId,int coursewareType)
{
    qDebug()<< "====cacheDocInfoAA===" << coursewareUrls<<coursewareId << m_sysnStatus
            <<  coursewareType << m_pages.contains("DEFAULT") << m_pages.contains(coursewareId);
    if (m_pages.contains("DEFAULT"))
    {
        m_pages.insert(coursewareId, m_pages.value("DEFAULT"));
        m_pages.remove("DEFAULT");
        m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
        m_currentPage = m_pages[m_currentCourse].size();//coursewareType == 3 ? 0 : m_pages[m_currentCourse].size();
        QString qustionId = coursewareType == 3 ? "h5" : "1";
        for (int i = 0; i < coursewareUrls.size(); ++i)
        {
            m_pages[m_currentCourse].append(MessageModel(1, coursewareUrls.at(i).toString(), 1.0, 1.0,qustionId, "0", 0, false));
        }
        qDebug() << "===111111111===" << m_currentPage << m_currentCourse;
    }
    else if (!m_pages.contains(coursewareId))
    {
        QList<MessageModel> list;
        list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
        m_pages.insert(coursewareId, list);
        m_pageSave.insert(m_currentCourse, m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
        m_currentPage = 1;//(coursewareType == 3) ? 0 : 1;
        QString qustionId = coursewareType == 3 ? "h5" : "1";
        for (int i = 0; i < coursewareUrls.size(); ++i)
        {
            m_pages[m_currentCourse].append(MessageModel(1, coursewareUrls.at(i).toString(), 1.0, 1.0,qustionId,"", 0, false));
        }
        qDebug() << "===222222222===" << m_currentPage << m_currentCourse;
    }
    else
    {
        m_pageSave.insert(m_currentCourse, m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
        //m_currentPage = m_pageSave.value(m_currentCourse, 0);
        qDebug() << "===3333333333===" << m_currentPage << m_currentCourse;
    }
    if(coursewareType == 3 && m_sysnStatus)
    {
        m_currentDocType = coursewareType;
        updateH5SynCousewareInfo();
    }
    m_currentPlanId = coursewareId;
}

bool SocketHandler::updateCoursewareInfo(QString& coursewareId,QString& coursewareMsg)
{
    if(m_pages.contains(coursewareId))
    {
        return true;
    }

    QJsonObject couldDiskFileInfo = QJsonDocument::fromJson(coursewareMsg.toUtf8().data()).object();
    QJsonObject data = couldDiskFileInfo.take(kSocketContent).toObject();
    int docType = data.take(kSocketDocType).toInt();

    if(data.contains(kSocketDocUrls))
    {
        QJsonArray coursewareUrls;
        QJsonArray arrUrls = data.take(kSocketDocUrls).toArray();
        for(int i = 0; i < arrUrls.size(); ++i)
        {
            coursewareUrls.append(arrUrls.at(i).toString());
        }
        cacheDocInfo(coursewareUrls, coursewareId,docType);

        if(m_pages.contains(coursewareId))
        {
            return true;
        }
    }

    return false;
}

//解析课件信息
bool SocketHandler::cacheCoursewareInfo(QString& message)
{
    QString dockId = parseMessageDockId(message);
    if(dockId == kSocketDockDefaultZero)
    {
        dockId = kSocketDockDefault;
    }
    QString pageId = parseMessagePageId(message);

    if(m_currentCourse != dockId)
    {
        if(!m_pages.contains(dockId))
        {
            quint64 startTimeStamp = createTimeStamp();
            bool bSuccess = updateCoursewareInfo(dockId,message); //http 请求失败
            if(!bSuccess)
            {
                //http 请求失败
                return false;
            }
            quint64 endTimeStamp = createTimeStamp();
            quint64 timeStampDiff = endTimeStamp  - startTimeStamp;
            qDebug() << QString("TIME:") << QString::number(timeStampDiff);
        }
    }
    else
    {
        QString qsCurrPageId(m_currentPage);
        if(qsCurrPageId != pageId)
        {
            if(!m_pages.contains(dockId))
            {
                QJsonArray qsStringList;

                qsStringList.append(pageId);
                cacheDocInfo(qsStringList, dockId,1);
            }
        }
    }
    return true;
}

void SocketHandler::cacheTrailMessage(QString& fromUid, QString& message)
{
    QString coursewareId = parseMessageDockId(message);
    if(!coursewareId.isEmpty() && cacheCoursewareInfo(message))
    {
        m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;
        m_pages[m_currentCourse][m_currentPage].addMsg(fromUid, message);
    }
}

void SocketHandler::cachePonitMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    qint32 xPos = -1, yPos = -1;

    if(contentJsonObj.contains(kSocketPointX))
    {
        xPos = contentJsonObj.take(kSocketPointX).toInt();
    }

    if(contentJsonObj.contains(kSocketPointY))
    {
        yPos = contentJsonObj.take(kSocketPointY).toInt();
    }

    //调节精度
    double  factor = 1000000.000000;

    double factorX = (xPos / factor);
    double factorY = (yPos / factor);

    //同步教鞭位置信息
}

void SocketHandler::cacheDocMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    qint32 nPageNo = 0;
    qint32 nPageTotalNum = 0;
    QString coursewareId = "";
    QString coursewareH5Url = "";
    int docType = 0;

    if(contentJsonObj.contains(kSocketDocPageNo))
    {
        nPageNo = contentJsonObj.take(kSocketDocPageNo).toInt();
    }

    if(contentJsonObj.contains(kSocketDocTotalNum))
    {
        nPageTotalNum = contentJsonObj.take(kSocketDocTotalNum).toInt();
    }

    if(contentJsonObj.contains(kSocketDocDockId))
    {
        coursewareId = contentJsonObj.take(kSocketDocDockId).toString();
    }

    if(contentJsonObj.contains(kSocketH5Url))
    {
       coursewareH5Url =  contentJsonObj.take(kSocketH5Url).toString();
    }
    if(contentJsonObj.contains(kSocketDocType))
    {
        docType =  contentJsonObj.take(kSocketDocType).toInt();
    }
    m_currentDocType = docType;
    m_currentCourseUrl = coursewareH5Url;
    qDebug() << "===kSocketDocType::h5URL==" << docType << coursewareH5Url << coursewareId;
    emit sigSynCoursewareType(docType,coursewareH5Url);
    //同步课件状态
    if(!coursewareId.isEmpty())
    {
        if(!m_pages.contains(coursewareId))
        {
            cacheCoursewareInfo(message);
        }
        else
        {
            m_currentPage = nPageNo;
            m_currentCourse = coursewareId;

            QJsonArray coursewareUrls;
            cacheDocInfo(coursewareUrls, coursewareId,docType);
        }
    }
}

void SocketHandler::cacheAVMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    int flagState = -1;
    int playTimeSec = -1;
    QString coursewareId = "";

    if(contentJsonObj.contains(kSocketAVFlag))
    {
        flagState = contentJsonObj.take(kSocketAVFlag).toInt();
    }

    if(contentJsonObj.contains(kSocketTime))
    {
        playTimeSec = contentJsonObj.take(kSocketTime).toInt();
    }

    if(contentJsonObj.contains(kSocketDocDockId))
    {
        coursewareId = contentJsonObj.take(kSocketDocDockId).toString();
    }

    if((flagState != -1) && (playTimeSec != -1) && !coursewareId.isEmpty())
    {
        //有值时, 才发信号更新AV播放状态
         m_avFlag = flagState;
         m_avPlayTime = playTimeSec;
         m_avId = coursewareId;
    }
}

//翻页处理
void SocketHandler::cachePageMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    int currPageOp = 0;
    int currPageNo = 0;
    int currPageTotalNum = 0;

    if(contentJsonObj.contains(kSocketPageOpType))
    {
        currPageOp = contentJsonObj.take(kSocketPageOpType).toVariant().toLongLong();
    }

    if(contentJsonObj.contains(kSocketDocPageNo))
    {
        currPageNo = contentJsonObj.take(kSocketDocPageNo).toVariant().toLongLong();
    }

    if(contentJsonObj.contains(kSocketDocTotalNum))
    {
        currPageTotalNum = contentJsonObj.take(kSocketDocTotalNum).toVariant().toLongLong();
    }
    qDebug() << "==cachePageMessage==" << currPageOp  << m_currentCourse << currPageNo << currPageTotalNum << m_currentPage;
//    if(currPageNo >= currPageTotalNum)
//    {
//        emit sigIsCourseWare(false);
//        return;
//    }
    m_isRemoverPage = false;
    switch(currPageOp)
    {
    case 1: //翻页
    {        
        int pageI = currPageNo; //默认跳转页
        if(pageI == m_currentPage + 1)
        {
            //向后翻页
            pageI = m_currentPage + 1;
        }
        if(pageI == m_currentPage - 1)
        {
            //向前翻页
            pageI = m_currentPage - 1;
        }

        pageI = pageI < 0 ? 0 : pageI;

        if (pageI > m_pages[m_currentCourse].size())
            pageI = m_pages[m_currentCourse].size();

        m_currentPage = pageI;

        QStringList strList = m_currentCourse.split("|");
        qDebug() << "========goto::page=======" << m_currentCourse << m_currentPage << strList.size();
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            if (m_pages.contains(m_currentCourse))
            {
                if (m_pages[m_currentCourse].size() > 1)
                {
                    QString questionId = m_pages[m_currentCourse].at(m_currentPage).questionId;
                    double m_offsetY = m_pages[m_currentCourse].at(m_currentPage).offsetY;
                    bool m_questionStatus = m_pages[m_currentCourse].at(m_currentPage).questionBtnStatus;

                    m_pageSave.insert(m_currentCourse, m_currentPage);
                    if (m_sysnStatus)
                    {
                        emit sigCurrentQuestionId(planId, columnId, questionId, m_offsetY, m_questionStatus);
                    }
                }
            }
        }
        break;
    }
    case 2: //加页
    {
        m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
        QStringList strList = m_currentCourse.split("|");
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            emit sigCurrentQuestionId(planId, columnId, "", 0, false);
        }
        break;
    }
    case 3: //删页
    {
        //如果是课件不能删除
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        if(model.isCourware && m_sysnStatus)
        {
            emit sigIsCourseWare(true);
            m_isRemoverPage = true;
            return;
        }

        if (m_pages[m_currentCourse].size() == 1)
        {
            m_pages[m_currentCourse][0].release();
            m_pages[m_currentCourse].removeAt(0);
            m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));

            QStringList strList = m_currentCourse.split("|");
            if (strList.size() > 1)
            {
                QString planId = strList.at(0);
                QString columnId = strList.at(1);
                emit sigCurrentQuestionId(planId, columnId, "", 0, false);
            }
            return;
        }
        m_pages[m_currentCourse][m_currentPage].release();
        m_pages[m_currentCourse].removeAt(m_currentPage);
        m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;

        QStringList strList = m_currentCourse.split("|");
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            QString docId = planId + "|" + columnId;
            if (m_pages.contains(docId))
            {
                QString questionId = m_pages[docId].at(m_currentPage).questionId;
                emit sigCurrentQuestionId(planId, columnId, questionId, 0, false);
            }
        }
        emit sigIsCourseWare(false);
        break;
    }
    default:
    {
        qDebug() << QString("翻页/加页/删页操作类型不在范围内!").toLatin1();
    }
    }
}

//同步授权、上下台、视频状态
void SocketHandler::cacheAuthMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    QString qsUid = "";
    if(contentJsonObj.contains(kSocketUid))
    {
        qsUid = contentJsonObj.take(kSocketUid).toString();
    }

    QString qsCurrUid = StudentData::gestance()->m_currentUserId;

//    if(qsUid == qsCurrUid) //谨慎处理授权状态更新, 防止误操作
//      此判断如果加了则无法同步其它学生的上下台等权限信息
//    {
        int upState = -1, trailState = -1, audioState = -1, videoState = -1;

        if(contentJsonObj.contains(kSocketAuthUp))
        {
            upState = contentJsonObj.take(kSocketAuthUp).toInt();
        }

        if(contentJsonObj.contains(kSocketTrail))
        {
            trailState = contentJsonObj.take(kSocketTrail).toInt();
        }

        if(contentJsonObj.contains(kSocketAuthAudio))
        {
            audioState = contentJsonObj.take(kSocketAuthAudio).toInt();
        }

        if(contentJsonObj.contains(kSocketAuthVideo))
        {
            videoState = contentJsonObj.take(kSocketAuthVideo).toInt();
        }

        if((upState != -1) && (trailState != -1) && (audioState != -1) && (videoState != -1))
        {
            //有值时, 才发信号更新授权状态
            TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(qsUid, QString::number(trailState));
            StudentData::gestance()->m_userAuth.insert(qsUid,QString::number(trailState));
            QPair<QString, QString> cameraPhonePair(QString::number(videoState),QString::number(audioState));
            StudentData::gestance()->m_cameraPhone.insert(qsUid,cameraPhonePair);
            StudentData::gestance()->m_userUp.insert(qsUid,QString::number(upState));
            emit sigUserAuth(qsUid,upState,trailState,audioState,videoState,m_sysnStatus);
            qDebug() << "====userAuth::data====" << qsUid << upState << trailState << audioState << videoState << TemporaryParameter::gestance()->m_userBrushPermissionsId.size();
        }
    //}
}

void SocketHandler::cacheMuteAllMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    if(contentJsonObj.contains(kSocketMuteAllRet))
    {
        int nRet = contentJsonObj.take(kSocketMuteAllRet).toInt();
        //有值时,才发信号更新全体静音状态
        QMap<QString,QString>::iterator itUserUp = StudentData::gestance()->m_userUp.begin();
        //如果是下台则不需要改变静音的状态
        for(;itUserUp != StudentData::gestance()->m_userUp.end(); itUserUp++)
        {
            if(itUserUp.value() =="0")
            {
                continue;
            }
            if(StudentData::gestance()->m_cameraPhone.contains(itUserUp.key()))
            {
                StudentData::gestance()->m_cameraPhone.find(itUserUp.key()).value().second = QString::number(nRet);
            }
        }
    }
}

void SocketHandler::cacheZoomMessage(QString& fromUid, QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    QString dockId = "";
    qint64 ratio = 0, offsetX = 0, offsetY = 0;

    if(contentJsonObj.contains(kSocketDocDockId) && contentJsonObj.contains(kSocketRatio) &&
       contentJsonObj.contains(kSocketOffsetX) && contentJsonObj.contains(kSocketOffsetY))
    {
        dockId  = contentJsonObj.take(kSocketDocDockId).toString();
        ratio = contentJsonObj.take(kSocketRatio).toVariant().toLongLong();
        offsetX = contentJsonObj.take(kSocketOffsetX).toVariant().toLongLong();
        offsetY = contentJsonObj.take(kSocketOffsetY).toVariant().toLongLong();

        //调节精度
        double  factor = 1000000.000000;

        double factorOffsetRatio = (ratio / factor);
        double factorX = (offsetX / factor);
        double factorY = (offsetY / factor);
        m_pages[m_currentCourse][m_currentPage].offsetY = factorY;
        //有值时,才发信号更新放大缩放
    }
}

QString SocketHandler::parseMessageCommand(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketCmd))
    {
        return jsonObj.take(kSocketCmd).toString();
    }

    return "";
}

QString SocketHandler::parseMessageUid(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketUid))
    {
        return QString::number(jsonObj.take(kSocketUid).toVariant().toLongLong());
    }

    return "";
}

QString SocketHandler::parseMessageDockId(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    QString coursewareId = "";
    if(contentJsonObj.contains(kSocketDocDockId))
    {
        coursewareId = contentJsonObj.take(kSocketDocDockId).toString();
    }

    return coursewareId;
}

QString SocketHandler::parseMessagePageId(QString& message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    QString pageId = "";
    if(contentJsonObj.contains(kSocketPageId))
    {
        pageId = contentJsonObj.take(kSocketPageId).toString();
    }

    return pageId;
}

int SocketHandler::parseMessageDocType(QString &message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();
    if(jsonObj.contains(kSocketContent))
    {
        contentJsonObj = jsonObj.take(kSocketContent).toObject();
    }

    int docType = 1;
    if(contentJsonObj.contains(kSocketPageId))
    {
        docType = contentJsonObj.take(kSocketDocType).toInt();
    }

    return docType;
}

//通过http请求获取历史记录
bool SocketHandler::syncUserHistroyReq(QJsonArray& userHistroyData)
{
    QNetworkRequest netRequest;
    QString qsUrl = QString("http://") + StudentData::gestance()->m_address + QString("/socks/sync");
    QUrl url(qsUrl);
    url.setPort(StudentData::gestance()->m_httpPort); //HTTP端口5251
    netRequest.setUrl(url);

    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    netRequest.setRawHeader("TOKEN", StudentData::gestance()->m_token.toUtf8());

    QNetworkReply *netReply;

    QString postData = syncUserHistroyReqMsgTemplate(1);

    QNetworkAccessManager *httpAccessMgr = new QNetworkAccessManager();
    netReply = httpAccessMgr->post(netRequest, postData.toUtf8());
    qDebug() << "==syncUserHistroyReq==" << url <<  StudentData::gestance()->m_httpPort << StudentData::gestance()->m_token.toUtf8() << postData;
    QEventLoop httploop;
    connect(netReply, SIGNAL(finished()), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray replyData = netReply->readAll();
    QJsonObject jsonObj = QJsonDocument::fromJson(replyData).object();

    if(!jsonObj.contains(kSocketCode))
    {
        return false;
    }

    int res = jsonObj.value(kSocketCode).toInt();
    if(0 == res)
    {
        if(jsonObj.contains(kSocketHttpData))
        {
            QJsonObject jsonData = jsonObj.take(kSocketHttpData).toObject();
            if(jsonData.contains(kSocketMn))
            {
                //fix: 同步历史记录(当前房间的最大mn)
                qint32 nRoomMn = jsonData.take(kSocketMn).toInt();
                if(nRoomMn > 0)
                {
                    m_uServerSn = nRoomMn;
                }

                //fix: 同步历史记录(我发送给服务器的最后sn)
                qint32 nMySn = jsonData.take(kSocketSn).toInt();
                if(nMySn > 0)
                {
                    nMySn += 1;
                    fixUserSnFromServer(nMySn);
                }
            }

            //同步历史-是否正在上课
            if(jsonData.contains(kSocketIsHavingClass))
            {
                bool isHavingClass = jsonData.take(kSocketIsHavingClass).toBool();
                qDebug() << "==isHavingClass==" << isHavingClass;
                TemporaryParameter::gestance()->m_isStartClass = isHavingClass;//是否开始上课属性
            }

            //同步历史-是否已经上过课
            if(jsonData.contains(kSocketIsAlreadyClass))
            {
                bool isAlreadyClass = jsonData.take(kSocketIsAlreadyClass).toBool();
                qDebug() << "==isAlreadyClass==" << isAlreadyClass;
                TemporaryParameter::gestance()->m_isAlreadyClass = isAlreadyClass;//isAlreadyClass;//是否上过课属性
            }

            if(jsonData.contains(kSocketHttpMsgs))
            {
                //解析:同步历史记录
                userHistroyData = jsonData.take(kSocketHttpMsgs).toArray();
                return true;
            }
        }
    }

    return false;
}

void SocketHandler::fixUserSnFromServer(qint32 nMySn)
{
    QMutexLocker locker(&m_mMessageNumMutex);
    m_uMessageNum = nMySn;
}

//解析消息
void SocketHandler::parseMsg(QString &num, QString &fromUser, QString &msg)
{
    Q_UNUSED(num);
    if(nullptr == m_socketMessageCtrl)
    {
        return;
    }
    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(msg.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError && documet.isObject())
    {
        QJsonObject jsonObj = documet.object();
        QString domain("xxxxxx"), command("xxxxxx");
        QJsonValue contentValue;

        if(jsonObj.contains(kSocketCmd))
        {
            QJsonValue typeValue = jsonObj.take(kSocketCmd);
            if(typeValue.isString())
                command = typeValue.toString();
        }

        if(jsonObj.contains(kSocketSn))
        {
            QJsonValue snValue = jsonObj.take(kSocketSn);
            quint32 nSn = snValue.toVariant().toLongLong();
            if(0 != nSn)
            {
                m_uServerSn = nSn;
            }
        }

        //来自服务器的心跳回复
        if(kSocketHb == command)
        {
            return;
        }

        //来自服务器的回执
        if(kSocketAck == command && jsonObj.contains(kSocketContent))
        {
            qint32 nMySn = 0;

            QJsonObject contentJsonObj = jsonObj.take(kSocketContent).toObject();
            if(contentJsonObj.contains(kSocketSn))
            {
                nMySn = contentJsonObj.take(kSocketSn).toVariant().toLongLong();
            }

            QString target = QString("\"") + kSocketSn + QString("\":") + QString::number(nMySn);
            bool bExitRoom = m_socketMessageCtrl->checkServerResponse(target, m_bConfirmFinish);
            if(bExitRoom)
            {
                finishRespExitRoom();
            }
            return;
        }

        if(jsonObj.contains(kSocketContent))
            contentValue = jsonObj.take(kSocketContent);

         if (command == kSocketEnterRoom)
        {
            //qDebug()<<"else if (command == enterRoom )"<<num<<StudentData::gestance()->m_selfStudent.m_studentId<<StudentData::gestance()->m_teacher.m_teacherId;
            QString userId = QString::number(jsonObj.take(kSocketUid).toVariant().toLongLong());
            qDebug() << "===enterRoom::userId===" << userId << StudentData::gestance()->m_currentUserId;
            if (userId == StudentData::gestance()->m_currentUserId)//自己进入房间 开始同步
            {
                //qDebug()<<"else if (command == \"enterRoom\")"<<"111111111111 self ";
                emit sigEnterOrSync( 1 ) ;
                StudentData::gestance()->insertIntoOnlineId(userId);

                bool bExitRoom = m_socketMessageCtrl->checkServerResponse(kSocketEnterRoom, m_bConfirmFinish);
                if(bExitRoom)
                {
                    finishRespExitRoom();
                }
                //同步历史记录
                QJsonArray userHistroyMsgs;
                if(syncUserHistroyReq(userHistroyMsgs))
                {
                    //回复服务器-同步历史记录完成
                    QString replyMessage = syncUserHistroyFinMsgTemplate();
                    qDebug() << "======replyMessage======" << replyMessage;
                    m_socketMessageCtrl->syncSendMessage(replyMessage);

                    //同步历史记录成功-深入解析对应数据
                    QString hisCommand, hisMessage;
                    int size = userHistroyMsgs.size();
                    for(int i = 0; i < size; ++i)
                    {
                        QJsonObject userHistroyMsg = userHistroyMsgs.at(i).toObject();
                        //qDebug() << "==userHistroyMsg==" << userHistroyMsgs;
                        //单条协议的全部消息
                        if(userHistroyMsg.isEmpty())
                        {
                            hisMessage = userHistroyMsgs.at(i).toString();
                        }

                        //单条协议消息的关键协议命令
                        if(hisMessage.contains(kSocketCmd))
                        {
                            hisCommand = parseMessageCommand(hisMessage);
                        }
                        qDebug() << "==hisCommand==" << hisCommand;
                        if(kSocketTrail == hisCommand || kSocketPoint == hisCommand || kSocketDoc == hisCommand || kSocketAV == hisCommand ||
                                kSocketAuth == hisCommand || kSocketMuteAll == hisCommand || kSocketPage == hisCommand || kSocketZoom == hisCommand || kSocketPlayAnimation == hisCommand ||
                               kSocketOperation == hisCommand || kSocketReward == hisCommand || kSocketStartClass == hisCommand)  //暂时同步历史记录权限全部放开, 后面与服务器协商, 垃圾消息不予通过
                        {
                            parseUserCommandOp(hisCommand, hisMessage);//执行历史记录操作
                        }

                        //临时方案-同步历史记录时每100条发一条心跳进行保活
                        if((i % 100) == 0)
                        {
                            QString keepAliveMessage = keepAliveReqMsgTemplate();
                            m_socketMessageCtrl->syncSendMessage(keepAliveMessage);
                        }
                    }
                }
                if(isOneStart == false)
                {
                    emit sigEnterOrSync(201);
                }

                isOneStart = true;
                syncUserHistroyComplete();
            }
            else
            {
                if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
                {
                    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                    {
                        if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                        {
                            emit sigSendUserId(StudentData::gestance()->m_student[i].m_studentId);
                            emit sigEnterOrSync(3);
                            //qDebug()<< "=============userId========" << userId << m_isInit;
                            break;
                        }
                    }
                    return;
                }
                StudentData::gestance()->m_dataInsertion = true;
                StudentData::gestance()->insertIntoOnlineId(userId);
                for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                {
                    if(userId == StudentData::gestance()->m_student[i].m_studentId)
                    {
                        if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                        {
                            emit sigSendUserId(userId);
                            emit sigEnterOrSync(3);
                            //qDebug()<< "=============userId========" << userId << m_isInit;
                            break;
                        }
                    }
                }
            }
        }
        else if(command == kSocketEnterFailed)
        {
           bool bExitRoom = m_socketMessageCtrl->checkServerResponse(kSocketEnterRoom, m_bConfirmFinish);
           if(bExitRoom)
           {
               finishRespExitRoom();
           }
            //提示进入房间失败
            emit sigEnterOrSync(0);
        }
        else if (command == kSocketKickOut)
        {
             emit sigEnterOrSync(88);//账号在其他地方登录 被迫下线
             qDebug() << QStringLiteral("账号在其他地方登录 被迫下线");
        }
        else if(command == kSocketFinish)
        {
            QString message = finishMsgTemplate();
            m_socketMessageCtrl->syncSendMessage(message);

            //退出教室
            StudentData::gestance()->removeOnlineId(fromUser);
            if(StudentData::gestance()->m_teacher.m_teacherId == fromUser )
            {
                TemporaryParameter::gestance()->m_isStartClass = false;
            }
            emit sigExitRoomIds(fromUser);

        }
        else if(kSocketTrail == command || kSocketDoc == command || kSocketPage == command || kSocketZoom == command ||  kSocketOperation == command) //此处为及时通讯信息-需要重绘画板
        {
            //回复服务器-发送回执信息
            QString replyMessage = ackServerMsgTemplate(m_uServerSn);
            m_socketMessageCtrl->syncSendMessage(replyMessage);

            //处理及时协议命令操作
            parseUserCommandOp(command, msg);

            MessageModel model = m_pages[m_currentCourse][m_currentPage];
            model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
            emit sigDrawPage(model);
        }
        else if(kSocketAV == command || kSocketAuth == command || kSocketMuteAll == command || kSocketResponder == command) //此处为及时通讯信息-但不需要重绘画板
        {
            //回复服务器-发送回执信息
            QString replyMessage = ackServerMsgTemplate(m_uServerSn);
            m_socketMessageCtrl->syncSendMessage(replyMessage);

            //处理及时协议命令操作
            parseUserCommandOp(command, msg);
        }
         else if(kSocketPoint == command) //实时教鞭-不需要ack服务器
         {
             //处理及时协议命令操作
             parseUserCommandOp(command, msg);
         }
        else if(kSocketUsersStatus == command)
        {
            //回复服务器-发送回执信息
            QString replyMessage = ackServerMsgTemplate(m_uServerSn);
            m_socketMessageCtrl->syncSendMessage(replyMessage);

            //更新用户状态信息
            updateUserState(contentValue);
        }
        else if(kSocketExitRoom == command) //防止服务器狂发exitRoom协议
        {
             //回复服务器-发送回执信息
             QString replyMessage = ackServerMsgTemplate(m_uServerSn);
             m_socketMessageCtrl->syncSendMessage(replyMessage);
        }
        else //防止服务器狂发垃圾协议
        {
             //回复服务器-发送回执信息
             QString replyMessage = ackServerMsgTemplate(m_uServerSn);
             m_socketMessageCtrl->syncSendMessage(replyMessage);
        }
    }
}

//解析命令
void SocketHandler::parseUserCommandOp(QString& command, QString& message)
{
    if(command.isEmpty() || message.isEmpty()) return;

    QString fromUser = parseMessageUid(message);
    if(fromUser.isEmpty()) return;

    if(kSocketTrail == command)
    {
        cacheTrailMessage(fromUser, message);
    }
    else if(kSocketPoint == command)
    {
        cachePonitMessage(fromUser, message);
    }
    else if(kSocketDoc == command)
    {
        cacheDocMessage(fromUser, message);
    }
    else if(kSocketAV == command)
    {
        cacheAVMessage(fromUser, message);
    }
    else if(kSocketPage == command)
    {
        cachePageMessage(fromUser, message);
    }
    else if(kSocketAuth == command)
    {
        cacheAuthMessage(fromUser, message);
    }
    else if(kSocketMuteAll == command)
    {
        cacheMuteAllMessage(fromUser, message);
    }

    else if(kSocketZoom == command)
    {
        cacheZoomMessage(fromUser, message);
    }
    else if(kSocketOperation == command)
    {
        cacheOperationMessage(fromUser,message);
    }
    else if(kSocketReward == command)
    {
        cacheReward(fromUser, message);
    }
    else if(kSocketResponder == command)
    {
        cacheResponder(fromUser, message);
    }
    else if(kSocketStartClass == command)
    {
        cacheStartClass();
    }
    else if(kSocketPlayAnimation == command)
    {
        cachePlayAnimation(message);
    }
    else
    {
        qDebug() << QString("Error:暂不解析此协议中的数据,") << command;
    }
}

void SocketHandler::syncUserHistroyComplete()
{
    //同步完成
    m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;

    qDebug() << "====syncUserHistroyComplete===" << m_currentPage << m_currentCourse << m_pages[m_currentCourse].size();

    MessageModel model = m_pages[m_currentCourse][m_currentPage];
    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);

    TemporaryParameter::gestance()->m_userBrushPermissionsId = m_userBrushPermissions;

    emit sigAuthtrail(m_userBrushPermissions);
    emit sigDrawPage(model);
    emit sigEnterOrSync(2) ;
    if(TemporaryParameter::gestance()->m_isAlreadyClass)
    {
        emit sigEnterOrSync(3);//同步完成发送是否已经上过课信号
    }
    if(!m_avId.isEmpty())
    {
        emit sigAvUrl(m_avFlag,m_avPlayTime,m_avId);
    }
    m_sysnStatus = true;

    qDebug() << "############m_sysnStatus##############" << m_currentPlanId << m_currentColumnId;
    updateH5SynCousewareInfo();

    if(m_currentPlanId == "" && m_currentColumnId == "")
    {
        return;
    }

    emit sigPlanChange(0, m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigCurrentQuestionId(m_currentPlanId, m_currentColumnId, m_currentQuestionId, offsetY, m_currentQuestionButStatus);
    emit sigCurrentColumn(m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigOffsetY(offsetY);
}

void SocketHandler::updateH5SynCousewareInfo()
{
    if(m_currentDocType == 3)//H5课件同步处理
    {
        QMap<QString,int> synH5dataModel;
        for(int i = 0; i < m_h5Model.size();i++)
        {
            if(m_h5Model.at(i).m_docId.contains(m_currentCourse))
            {
                synH5dataModel.insert(m_h5Model.at(i).m_pageNo,m_h5Model.at(i).m_currentAnimStep);
            }
        }
        QJsonObject h5SynObj;
        QJsonArray h5SynArray;
        h5SynObj.insert("lessonId",StudentData::gestance()->m_lessonId);
        h5SynObj.insert("h5Url",m_currentCourseUrl);
        h5SynObj.insert("courseWareId",m_currentCourse);
        h5SynObj.insert("courseWareType",m_currentDocType);
        h5SynObj.insert("currentPageNo",m_currentPage);

        for(int k = 0; k < m_pages[m_currentCourse].size(); k++)
        {
            QJsonObject pageInfosObj;
            pageInfosObj.insert("courseWareType",m_pages[m_currentCourse][k].isCourware);
            pageInfosObj.insert("pageNo",k);
            pageInfosObj.insert("url","");
            int currentAnimStep = 0;
            QMap<QString,int>::const_iterator it;
            for( it=synH5dataModel.constBegin(); it!=synH5dataModel.constEnd(); ++it)
            {
                if(it.key() == QString::number(k))
                {
                    currentAnimStep = it.value();
                    break;
                }
            }
            pageInfosObj.insert("currentAnimStep",currentAnimStep);
            h5SynArray.append(pageInfosObj);
        }
        h5SynObj.insert("pageInfos",h5SynArray);
        emit sigSynCoursewareInfo(h5SynObj);
        emit sigSynCoursewareStep(QString::number(m_currentPage),m_currentStep);
        qDebug() << "====AAAA====" << h5SynObj;
    }
}

void SocketHandler::updateUserState(QJsonValue content)
{
    QJsonArray contentArray = content.toArray();

    TemporaryParameter::gestance()->m_teacherIsOnline  = false;
    TemporaryParameter::gestance()->m_astudentIsOnline = false;
    qDebug() << "==userState::data===" <<  contentArray;
    if (contentArray.size() > 1)
    {
        foreach (QJsonValue value, contentArray)
        {
            QJsonObject userStates = value.toObject();

            QString uid  = userStates.take(kSocketUid).toString();
            QString state = QString::number(userStates.take(kSocketOnlineState).toInt());
            if("1" == state)
            {
                StudentData::gestance()->insertIntoOnlineId(uid);
            }
            else
            {
                StudentData::gestance()->removeOnlineId(uid);
            }
            emit  sigIsOnline(uid.toInt(),state);

            if(uid == StudentData::gestance()->m_teacher.m_teacherId)
            {
                TemporaryParameter::gestance()->m_teacherIsOnline = true;
            }
            //动态添加在线学生进入教室
            if(StudentData::gestance()->m_currentUserId != uid && state == "1")
            {
                emit sigJoinClassroom(uid);
            }
        }
    }
}


void SocketHandler::cachePlayAnimation(QString message)
{
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,Json解析失败!").toLatin1();
    }

    QJsonObject contentJsonObj;
    QJsonObject jsonObj = document.object();

    contentJsonObj = jsonObj.take(kSocketContent).toObject();
    int step = contentJsonObj.take(kSocketStep).toInt();
    QString pageId = contentJsonObj.take(kSocketPageId).toString();
    int pageNo = contentJsonObj.take(kSocketPageNo).toInt();
    QString dockId = contentJsonObj.take(kSocketDocDockId).toString();
    m_h5Model.append(H5dataModel(dockId,"3",QString::number(pageNo),"",step));
    m_currentStep = step;
    //qDebug() << "===cachePlayAnimation===" << step << pageId << pageNo << dockId;
}

QString SocketHandler::playAnimationMsgTemplate(int step)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketDocPageNo, m_currentPage);
    content.insert(kSocketDocDockId,m_currentCourse);
    QString pageId = QString::number(m_currentPage);
    content.insert(kSocketPageId, pageId);
    content.insert(kSocketStep, step);

    QString msg = createMessageTemplate(kSocketPlayAnimation, lid, uid, content);
    return msg;
}

void SocketHandler::clearRecord()
{
    qDebug() << "SocketHandler::clearRecord" << m_isInit;
    if(!m_isInit)
    {
        m_isInit = true;
        m_pages.clear();
        m_pageSave.clear();
        TemporaryParameter::gestance()->m_pageSave.clear();
        QList<MessageModel> list;
        list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false));

        m_pages.insert("DEFAULT", list);
        m_currentPage = 0;
        m_currentCourse = "DEFAULT";
        //画一页
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
        emit sigDrawPage(model);
        emit sigOneStartClass();

        QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        QString saveFilePath = bufferFilePath + "/oneStartLesson.dll";
        QFile file(saveFilePath);
        if(file.exists())
        {
            file.remove();
        }
        qDebug() << "******SocketHandler::clearRecord*********";
    }
}
//ip切换
void SocketHandler::onChangeOldIpToNew()
{
}

void SocketHandler::setFirstPage(int pages)
{
    m_firstPage = pages;
}

SocketHandler::~SocketHandler()
{
    uninit();
    if(m_miniWhiteBoardCtrl)
    {
        delete m_miniWhiteBoardCtrl;
        m_miniWhiteBoardCtrl = nullptr;
    }
}

//图片
void SocketHandler::picture(QString url, double width, double height)
{
    QString s("{\"domain\":\"draw\",\"command\":\"picture\",\"content\":{\"pageIndex\":\"%1\",\"url\":\"%2\",\"width\":\"%3\",\"height\":\"%4\"}}");
    sendLocalMessage(s.arg(QString::number(m_currentPage, 10).arg(url).arg(QString::number(width, 'f', 6)).arg(QString::number(height, 'f', 6))), true, true);
}

//清屏
void SocketHandler::clearScreen()
{
    QString s("{\"domain\":\"draw\",\"command\":\"clear\",\"content\":{\"page\":\"" + QString::number(m_currentPage, 10) + "\"}}");
    sendLocalMessage(s, true, true);
}

