#include "sockethandler.h"
#include <QtNetwork>

#include <QTimer>
#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
#include "debuglog.h"

//通讯协议版本
const quint8 COMMUNICATION_PROTOCOL_VER = 1;

//协议指令管理--begin
const QString kSocketCmd = "cmd";
const QString kSocketSn = "sn";
const QString kSocketMn = "mn";
const QString kSocketVer = "v";
const QString kSocketLid = "lid";
const QString kSocketUid = "uid";
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
const QString kSocketDocUrls = "urls";
const QString kSocketAV = "av";
const QString kSocketPage = "page";
const QString kScoketPageId = "pageId";
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
    , currentReloginTimes(0)
    , zoomRate(0.0)
    , offsetX(0.0)
    , offsetY(0.0)
    , m_sysnStatus(false)
{

    getAllLessonCoursewareList = new YMCloudClassManagerAdapter(this);

#ifdef USE_OSS_AUTHENTICATION
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = StudentData::gestance()->apiUrl;
#endif

    QList<MessageModel> list;

#ifdef USE_OSS_AUTHENTICATION
    list.append(MessageModel(0, "", 1.0, 1.0, 1, 0));
#else
    list.append(MessageModel(0, "", 1.0, 1.0, 1));
#endif
    m_pages.insert("DEFAULT", list);

    m_sendMsgTask = new QTimer(this);
    connect(m_sendMsgTask, SIGNAL(timeout()), this, SLOT(sendMessage()));

    m_uLastSendTimeStamp = 0;

    m_tReSendMessageTimer = new QTimer(this);
    connect(m_tReSendMessageTimer, SIGNAL(timeout()), this, SLOT(reSendMessage()));

    m_sendAudioQualityTask = new QTimer(this);
    connect(m_sendAudioQualityTask, SIGNAL(timeout()), this, SLOT(sendAudioQuality()));

    restGoodIpList();

    m_socket = new YMTCPSocket(this);
    connect(m_socket, &YMTCPSocket::readMsg, this, &SocketHandler::readMessage);
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SIGNAL(justNetConnect(bool)));
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SLOT(justChangeIp(bool)));
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SLOT(socketPrepareSlot(bool)));

    //新的http协议
    //connect(m_socket, SIGNAL(httpTimeOut(QString)), this, SIGNAL(autoChangeIpResult(QString)));

    QString netTypeStr = TemporaryParameter::gestance()->m_netWorkMode;
    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }
    emit sigInterNetChange(netType);
    m_enterRoomMsg = QString("1#SYSTEM{\"command\":\"enterRoom\",\"content\":"
                             "{\"qqvoiceVersion\":\"1.8.2\",\"appVersion\":\"%1\",\"recordVersion\":\"3.10.19\","
                             "\"MD5Pwd\":\"%2\",\"agoraVersion\":\"1.8\",\"userId\":\"%3\","
                             "\"userType\":\"student_%4\",\"sysInfo\":\"%5\",\"phone\":\"%6\",\"lessonId\":\"%7\","
                             "\"deviceInfo\":\"%8\",\"lat\":\"%9\",\"lng\":\"%10\",\"netType\":\"%11\",\"appSource\":\"YIMI\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_appVersion).arg(StudentData::gestance()->m_mD5Pwd).arg(StudentData::gestance()-> m_selfStudent.m_studentId).arg(StudentData::gestance()-> m_selfStudent.m_studentType).arg(StudentData::gestance()->m_sysInfo)
                     .arg(StudentData::gestance()->m_phone).arg(StudentData::gestance()->m_lessonId).arg(StudentData::gestance()->m_deviceInfo).arg(StudentData::gestance()->m_lat).arg(StudentData::gestance()->m_lng).arg(netType);

    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
    //m_lastSendMsg = m_enterRoomMsg;
    //sendMessage(lastSendMsg);
    //m_lastHBTime.start();

    startSendAudioQuality();

    m_uServerSn = 0;
    m_uMessageNum = 1;

    startSendMsg();
    m_isOneStart = false;
    //再次提交答案 for(老师端有时候第一次无法成功生成答案) 暂时不用了
    //anserSubmitTimer = new QTimer(this);
    //anserSubmitTimer->setSingleShot(true);
    //anserSubmitTimer->setInterval(15000);
    //connect(anserSubmitTimer, SIGNAL(timeout()), this, SLOT(reSubmitAnswer()));
}

void SocketHandler::reSubmitAnswer()
{
    anserSubmitTimer->stop();//停掉计时器
    sendMessage(currentAnswerSumitData);
}

//发送本地消息
void SocketHandler::sendLocalMessage(QString message, bool append, bool drawPage)
{
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

    //excuteMsg(cmd, StudentData::gestance()->m_selfStudent.m_studentId);  历史版本解析-暂时停止使用

    if (drawPage)
    {
        //画一页
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);

        if(currentCourwareType == 2)
        {
            model = resetMessageModel(model);
        }

#ifdef USE_OSS_AUTHENTICATION
        model.bgimg = checkOssSign(model.bgimg);
#endif

        emit sigDrawPage(model);
    }

    if(!command.isEmpty())
    {
        if (append) //仅且需要服务器回执的消息加入队列中
        {
            joinMessageToQue(message);
        }
        else
        {
            sendMessage(message); //直接发送至服务器, 不需要服务器ack的协议信息
        }
    }
}

int SocketHandler::getCurrentPage(QString docId)
{
    int cuttents = 1;
    cuttents = m_pageSave.value(docId, 1);
    return cuttents;
}

void SocketHandler::readMessage(QString message)
{
    //qDebug() << ">>SocketHandler::readMessage>>" << message;

    //判断是否停掉重新提交答案的定时器
    if(message.contains("autoPicture") && !message.contains("synchronize") )
    {
        anserSubmitTimer->stop();
    }

    //解析消息
    /*int firstS = line.indexOf('#', 0);
    int secondS = line.indexOf('#', firstS + 1);
    int firstM = line.indexOf(':', 0);
    QString recvNum = line.mid(0, firstS);
    QString fromUser = line.mid(firstS + 2, firstM - firstS - 2);
    QString msgJson = line.mid(secondS + 1);

    // qDebug()<<recvNum<<fromUser<<msgJson<<line.mid(line.indexOf(":",0) + 1,line.indexOf("}",0)-1-line.indexOf(":",0));
    if (recvNum != "0")
    {
        //编号为0的消息不做应答
        //编号不为0 先回复应答
        sendMessage("0#SYSTEM{\"doamin\":\"system\",\"command\":\"response\",\"content\":{\"currentIndex\":\"" + recvNum + "\"}}");
        if (m_lastRecvNum == recvNum && m_lastRecvMsg == msgJson)
            return;
        m_lastRecvNum = recvNum;
        m_lastRecvMsg = msgJson;
    }*/

    //解析必要信息
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(message.toUtf8(), &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << QString("Error:Json错误,与服务器联合检查!").toLatin1();
        return;
    }

    QJsonObject jsonObj = document.object();
    quint64 uSn = 0;
    if(jsonObj.contains(kSocketTs))
    {
        uSn = jsonObj.take(kSocketTs).toVariant().toLongLong();
    }

    //同步服务器消息时间
    QString msgJson(message.unicode(), message.length()); //深度复制message, 防止数据关联
    TemporaryParameter::gestance()->avPlaySetting.currentTime = uSn;

    //解析命令
    qDebug() << "==SocketHandler::readMessage==" << msgJson;
    parseMsg(msgJson);
}

void SocketHandler::sendMessage(QString message)
{
    if(!message.isEmpty() && NULL != m_socket)
    {
        QString deepinCopyMsg(message.unicode(), message.length()); //深度复制message, 防止数据关联
        m_socket->sendMsg(deepinCopyMsg.toUtf8());
    }
}

void SocketHandler::sendMessage()
{
    if (m_bCanSend && m_bServerResp && m_qListMsgsQue.size() > 0)
    {
        QMutexLocker locker(&m_sendMsgsMutex);
        //m_lastHBTime.restart();
        m_bServerResp = false;
       // m_sendMsgNum++;
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

void SocketHandler::sendAudioQuality()
{
    // qDebug()<<QStringLiteral("语音质量");
    if( TemporaryParameter::gestance()->m_ipContents.size() > 0 )
    {

        QMap<QString, QString>::Iterator  it = TemporaryParameter::gestance()->m_ipContents.begin();
        while(it != TemporaryParameter::gestance()->m_ipContents.end())
        {
            //拼接数据   QString contents = QString("%1,%2,%3").arg(quality).arg(delay).arg(lost);
            if( QString(it.value()).split(",").size() == 3)
            {
                QString tempString = QString("0#SYSTEM{\"command\":\"audioQuality\",\"content\":{\"userId\":\"%1\",\"delay\":\"%2\",\"lost\":\"%3\",\"quality\":\"%4\",\"bitrate\":\"%5\",\"supplier\":\"%6\",\"videoType\":\"%7\"},\"domain\":\"system\"}").arg(it.key()).arg(QString(it.value()).split(",").at(1)).arg(QString(it.value()).split(",").at(2)).arg(QString(it.value()).split(",").at(0)).arg(TemporaryParameter::gestance()->bitRate).arg(TemporaryParameter::gestance()->m_supplier).arg(TemporaryParameter::gestance()->m_videoType);
                sendMessage(tempString);
                //  qDebug()<<QStringLiteral("TemporaryParameter::gestance()->m_ipContents.size() 语音质量数据")<<tempString<<TemporaryParameter::gestance()->m_ipContents.size() ;
            }
            ++it;
        }
    }
    else
    {
        //qDebug()<<QStringLiteral("TemporaryParameter::gestance()->m_ipContents.size() 语音质量数据为空");
    }

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
}

//解析处理消息
void SocketHandler::parseMsg(QString &num, QString &fromUser, QString &msg)
{
    qDebug() << "SocketHandler::parseMsg" << num << fromUser << msg;

    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(msg.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        if(documet.isObject())
        {
            QJsonObject jsonObj = documet.object();
            QString domain, command;
            QJsonValue contentValue;


            if(jsonObj.contains("domain"))
            {
                QJsonValue typeValue = jsonObj.take("domain");
                if(typeValue.isString())
                    domain = typeValue.toString();
            }
            if(jsonObj.contains("command"))
            {
                QJsonValue typeValue = jsonObj.take("command");
                if(typeValue.isString())
                    command = typeValue.toString();
            }
            if(jsonObj.contains("content"))
                contentValue = jsonObj.take("content");
            if (domain == "server")
            {
                if (command == "response")
                {
                    m_response = true;

                }
                else if (command == "reLogin")
                {
                    if (!m_response && m_lastSendMsg != "" && !(m_lastSendMsg.contains("\"enterRoom\"") && m_lastSendMsg.contains("\"system\"")))
                    {
                        m_sendMsgsMutex.lock();
                        if(m_lastSendMsg.split("#").size() > 1)
                        {
                            m_sendMsgs.insert(0, m_lastSendMsg.split("#")[1]);
                        }
                        m_sendMsgsMutex.unlock();
                    }
                    m_canSend = false;
                    m_lastSendMsg = m_enterRoomMsg;
                    m_response = false;
                    //m_socket->SendDataToServer(m_enterRoomMsg.toUtf8());
                }
                else if (command == "enterRoom")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    if (userId == StudentData::gestance()->m_selfStudent.m_studentId && num == "0")//自己进入房间 开始同步
                    {
                        emit sigEnterOrSync( 1 ) ;
                        m_sendMsgNum++;
                        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#SYSTEM{\"command\":\"synchronize\",\"content\":{\"currentIndex\":\"" + m_lastRecvNum
                                        + "\",\"includeSelfMsg\":\"" + m_includeSelfMsg + "\"},\"domain\":\"system\"}";
                        m_response = false;
                        sendMessage(m_lastSendMsg);
                        StudentData::gestance()->insertIntoOnlineId(userId);
                        emit sigEnterOrSync(4);
                    }
                    else
                    {
                        if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
                        {
                            return;
                        }
                        StudentData::gestance()->m_dataInsertion = true;
                        StudentData::gestance()->insertIntoOnlineId(userId);
                        emit sigEnterOrSync(4);
                    }
                }
                else if (command == "synchronize")
                {
                    QJsonArray contentArray = contentValue.toObject().take("commands").toArray();

                    for (int i = 0; i < contentArray.size(); ++i)
                    {
                        QString msgContent = contentArray[i].toString();
                        int firstS = msgContent.indexOf('#', 0);
                        int secondS = msgContent.indexOf('#', firstS + 1);
                        int firstM = msgContent.indexOf(':', 0);
                        if(msgContent.contains("startClass"))
                        {
                            QString timeLens = msgContent.mid(firstM + 1, secondS - 2 - firstM);
                            TemporaryParameter::gestance()->m_timeLens = timeLens;
                        }
                        QString msgJson = msgContent.mid(secondS + 1);
                        QString uid = msgContent.mid(firstS + 2, firstM - firstS - 2);
                        if(msgContent.contains("avControl"))
                        {
                            TemporaryParameter::gestance()->avPlaySetting.playTime = msgContent.mid(firstM + 1, secondS - firstM - 2).toLongLong();
                        }
                        excuteMsg(msgJson, uid);
                        synchronousForNewHomeWorkString = msgJson;
                        //synchronousForNewHomeWork(synchronousForNewHomeWorkString);

                    }
                    if (contentValue.toObject().take("state").toString() == "complete")
                    {
                        if(hasChangeAudio == false)
                        {
                            TemporaryParameter::gestance()->m_supplier = "1";
                            TemporaryParameter::gestance()->m_videoType = "1";
                        }
                        m_sendMsgNum++;
                        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#SYSTEM{\"command\":\"onlineState\",\"domain\":\"system\"}";
                        m_response = false;
                        sendMessage(m_lastSendMsg);
                        m_includeSelfMsg = "0";

                        if(m_currentCourse == "")
                        {
                            m_currentCourse = "DEFAULT";
                        }
                        qDebug() << m_pages.contains(m_currentCourse) << m_pages[m_currentCourse].size();
                        if(m_pages[m_currentCourse].size() - 1 < m_currentPage)
                        {
                            return;
                        }
                        qDebug() << " QString  = m_currentCourse1" << currentCourwareType << m_currentCourse << currentColumnId  << m_currentPage;
                        MessageModel model = m_pages[m_currentCourse][m_currentPage];
                        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
                        TemporaryParameter::gestance()->m_userBrushPermissionsId = m_userBrushPermissions;
                        emit sigAuthtrail(m_userBrushPermissions);
                        emit sigEnterOrSync( 52 );

                        //新课件的信号
                        if(currentCourwareType == 2)
                        {
                            if(currentPlanContent.isObject())
                            {
                                emit sigShowNewCourseware(currentPlanContent);
                            }
                            //更改modle
                            model = resetMessageModel(model);
                        }

#ifdef USE_OSS_AUTHENTICATION
                        model.bgimg = checkOssSign(model.bgimg);
#endif

                        emit sigDrawPage(model);
                        emit sigEnterOrSync( 2 );
                        if( getAllLessonCoursewareList->lessonListIsEmpty())
                        {
                            qDebug("SocketHandler::parseMsg sigGetLessonListFail: ");
                            sigGetLessonListFail();
                        }
                    }
                    else
                    {
                        m_sendMsgNum++;
                        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#SYSTEM{\"command\":\"synchronize\",\"content\":{\"currentIndex\":\"" + m_lastRecvNum
                                        + "\",\"includeSelfMsg\":\"" + m_includeSelfMsg + "\"},\"domain\":\"system\"}";
                        m_response = false;
                        sendMessage(m_lastSendMsg);
                    }
                }
                else if (command == "onlineState")
                {
                    QJsonArray contentArray = contentValue.toArray();
                    TemporaryParameter::gestance()->m_teacherIsOnline = false;
                    TemporaryParameter::gestance()->m_astudentIsOnline = false;
                    if (contentArray.size() > 1)
                    {
                        foreach (QJsonValue values, contentArray)
                        {
                            QString ids = values.toString();
                            if(ids == StudentData::gestance()->m_teacher.m_teacherId)
                            {
                                TemporaryParameter::gestance()->m_teacherIsOnline = true;
                            }
                            StudentData::gestance()->m_dataInsertion = true;
                            StudentData::gestance()->insertIntoOnlineId(ids);
                            for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                            {
                                if(ids == StudentData::gestance()->m_student[i].m_studentId)
                                {
                                    if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                                    {
                                        TemporaryParameter::gestance()->m_astudentIsOnline = true;
                                    }
                                }
                            }
                        }
                        emit sigEnterOrSync(4);
                        if(StudentData::gestance()->m_selfStudent.m_studentType == "B")
                        {
                            emit sigEnterOrSync(6);
                        }
                    }
                    m_canSend = true;
                }
                else if(command == "exitRoom")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    StudentData::gestance()->removeOnlineId(userId);
                    if(StudentData::gestance()->m_teacher.m_teacherId == userId )
                    {
                        TemporaryParameter::gestance()->m_isStartClass = false;
                    }
                    TemporaryParameter::gestance()->avPlaySetting.m_controlType = "stop";
                    emit sigAvUrl( TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );
                    if(!hasReciveFinishedClass)
                    {
                        emit sigExitRoomIds(userId);
                    }
                    emit sigEnterOrSync(4);
                }
                else if(command == "changeAudio")
                {
                    QString supplier = contentValue.toObject().take("supplier").toString();
                    QString videoType = contentValue.toObject().take("videoType").toString();
                    TemporaryParameter::gestance()->m_supplier = supplier;
                    TemporaryParameter::gestance()->m_videoType = videoType;
                    emit sigEnterOrSync(61); //改变频道跟音频 频道
                }
                else if(command == "enterFailed")
                {
                    emit sigEnterOrSync(0);
                }
                else if(command == "startClass")
                {
                    QString totalTime = contentValue.toObject().take("totalTime").toString();
                    //在同步中 读取 不在这里读取
                    // QString supplieras = contentValue.toObject().take("supplier").toString();
                    // QString videoTypeas = contentValue.toObject().take("videoType").toString();
                    // TemporaryParameter::gestance()->m_supplier = supplieras;
                    // TemporaryParameter::gestance()->m_videoType = videoTypeas;
                    TemporaryParameter::gestance()->m_isStartClass = true;

                    emit sigStartClassTimeData(totalTime);
                    if(TemporaryParameter::gestance()->avPlaySetting.isHasSynchronize == false)
                    {
                        //同步 播放时间
                        TemporaryParameter::gestance()->avPlaySetting.m_startTime = QString::number(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.playTime).secsTo(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.currentTime)) + TemporaryParameter::gestance()->avPlaySetting.m_startTime.toInt() );
                        emit sigAvUrl(TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );
                        TemporaryParameter::gestance()->avPlaySetting.isHasSynchronize = true;
                    }
                    //第一次开课
                    clearRecord();
                    qDebug() << "TemporaryParameter::gestance()->m_supplier" << TemporaryParameter::gestance()->m_supplier << TemporaryParameter::gestance()->m_videoType;
                    emit sigEnterOrSync(61); //改变频道跟音频 频道
                    //synchronousForNewHomeWork(synchronousForNewHomeWorkString);

                    //同步新课件的命令
                    //                    if(offsetY != 0.0)
                    //                    {
                    //                        qDebug()<<"offsetY != 0.0"<<offsetY;
                    //                        emit sigZoomInOut(offsetX,offsetY,zoomRate);
                    //                    }

                    //if(correctViewIsOpen)
                    //  {
                    //emit sigOpenCorrect(openCorrectData,false);
                    // }

                    if( currentIsAnswing == true )
                    {
                        sigStarAnswerQuestion(stopOrBeginAnswerQuestonData);
                    }

                }
                else if(command == "disconnect")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
                    {
                        return;
                    }
                    emit sigDroppedRoomIds(userId);
                }
                else if(command == "deviceInfos")
                {
                    TemporaryParameter::gestance()->deviceVersion.clear();
                    TemporaryParameter::gestance()->deviceSysInfo.clear();
                    QJsonArray contentArray = contentValue.toArray();
                    if (contentArray.size() > 1)
                    {
                        foreach (QJsonValue values, contentArray)
                        {
                            QString sysInfo = values.toObject().take("sysInfo").toString();
                            QString userId = values.toObject().take("userId").toString();
                            QString appVersion = values.toObject().take("appVersion").toString();
                            TemporaryParameter::gestance()->deviceVersion[userId] = appVersion;//版本号
                            TemporaryParameter::gestance()->deviceSysInfo[userId] = sysInfo;//设备信息
                            TemporaryParameter::gestance()->m_phoneType[userId] = sysInfo;
                        }
                    }
                }
                else if(command == "changeCmd") //在ERP系统中, 切换ABC通道的指令
                {
                    QString cmd = contentValue.toObject().take("cmd").toString();
                    if(cmd == "server")
                    {
                        StudentData::gestance()->m_address = contentValue.toObject().take("data").toString();
                        StudentData::gestance()->m_port = contentValue.toObject().take("port").toString().toInt();
                        TemporaryParameter::gestance()->enterRoomStatus = "C";
                        onChangeOldIpToNew();
                    }
                }
                else if(command == "kickOut")
                {
                    emit sigEnterOrSync(80);//账号在其他地方登录 被迫下线
                }
            }
            else if (domain == "draw")
            {
                excuteMsg(msg, fromUser);

                if(command == "lessonPlan" )
                {
                    qDebug() << "command == lessonPlan " << msg << "1111111111111111111" << contentValue;

                    qDebug() << "command == 2 lessonPlan" << m_currentCourse << currentColumnId;
                    if(currentColumnId == "" || m_currentCourse == "DEFAULT")
                    {
                        return;
                    }

                    int tempIndex = 1;
                    if(m_pages[m_currentCourse].size() == 1 )
                    {
                        tempIndex = 0;
                    }

                    MessageModel model = m_pages[m_currentCourse][tempIndex];
                    model.setPage(m_pages[m_currentCourse].size(), tempIndex);

#ifdef USE_OSS_AUTHENTICATION
                    model.bgimg = checkOssSign(model.bgimg);
#endif

                    emit sigShowNewCourseware(contentValue);
                    emit sigDrawPage(model);//更改页数
                }
                else if(command == "column" )
                {
                    currentIsDrawCloum = true;
                    int tempIndex = m_currentPage;
                    if(m_pages[m_currentCourse].size() == 1 || tempIndex > m_pages[m_currentCourse].size() )
                    {
                        tempIndex = 0;
                    }

                    MessageModel model = m_pages[m_currentCourse][tempIndex];
                    model.setPage(m_pages[m_currentCourse].size(), tempIndex);

                    model = resetMessageModel(model);

#ifdef USE_OSS_AUTHENTICATION
                    model.bgimg = checkOssSign(model.bgimg);
#endif

                    qDebug() << "change page number draw cloumn" << m_currentCourse << tempIndex;
                    emit sigDrawPage(model);//更改页数

                }
                else if(command == "question" )
                {
                    qDebug() << "command == question " << msg << "1111111111111111111" << contentValue;
                    currentIsAnswing = true;
                    emit sigStarAnswerQuestion(contentValue);

                }
                else if(command == "stopQuestion" )
                {
                    currentIsAnswing = false;
                    emit sigStopAnswerQuestion(contentValue);

                }
                else if(command == "autoPicture")
                {
                    currentIsAnswing = false;
                    qDebug() << "command == sigautoPicture " << msg << "1111111111111111111" << contentValue;
                    getAllLessonCoursewareList->getLessonList();//重设所有的课件数据
                    MessageModel model = m_pages[m_currentCourse][m_currentPage];
                    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);

                    m_pages[m_currentCourse][m_currentPage].bgimg = contentValue.toObject().value("imageUrl").toString();
                    m_pages[m_currentCourse][m_currentPage].width = 1;
                    m_pages[m_currentCourse][m_currentPage].height = 1;
                    model.bgimg = contentValue.toObject().value("imageUrl").toString();
                    //model = resetMessageModel(model);

#ifdef USE_OSS_AUTHENTICATION
                    model.bgimg = checkOssSign(model.bgimg);
#endif

                    //重画面板
                    emit sigDrawPage(model);
                    emit sigAutoPicture(contentValue);
                    emit sigZoomInOut(0, 0, zoomRate);
                }
                else if (command != "trail" && command != "polygon" && command != "ellipse")
                {
                    //画一页
                    MessageModel model = m_pages[m_currentCourse][m_currentPage];
                    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);

                    if(currentCourwareType == 2)//new 清屏 撤销操作重新获取图片
                    {
                        model = resetMessageModel(model);
                    }

#ifdef USE_OSS_AUTHENTICATION
                    model.bgimg = checkOssSign(model.bgimg);
#endif

                    emit sigDrawPage(model);
                }
                else
                {
                    //画一笔
                    emit sigDrawLine(msg);
                }
            }
            else if (domain == "page")
            {
                if(msg.contains("goto") && currentIsAnswing ==  true)
                {
                    return;
                }

                excuteMsg(msg, fromUser);
                qDebug() << "m_currentCourse == domain == page" << stopOrBeginAnswerQuestonData << msg.contains("goto") << currentIsAnswing;
                //画一页
                MessageModel model = m_pages[m_currentCourse][m_currentPage];
                model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
                model = resetMessageModel(model);

#ifdef USE_OSS_AUTHENTICATION
                model.bgimg = checkOssSign(model.bgimg);
#endif

                emit sigDrawPage(model);

                if(isFirstgGoPage)
                {
                    if(stopOrBeginAnswerQuestonData.isObject())
                    {
                        sigStarAnswerQuestion(stopOrBeginAnswerQuestonData);
                        currentIsAnswing = true;
                    }

                }
                isFirstgGoPage = false;

                QString auth = "0";
                if(TemporaryParameter::gestance()->m_userPagePermissions == "1" )
                {
                    if(auth == "0")
                    {
                        if(currentIsDrawCloum)
                        {
                            currentIsDrawCloum = false;
                        }
                        else
                        {
                            if(m_firstPage != 0)
                            {
                                TemporaryParameter::gestance()->m_userPagePermissions = auth;
                                emit sigEnterOrSync(72); //申请翻页收回权限
                            }
                            m_firstPage++;
                        }
                    }
                }
                else
                {
                    qDebug() << "m_currentCourse ==333333333333333333333333";
                    TemporaryParameter::gestance()->m_userPagePermissions = auth;
                }
            }
            else if (domain == "auth")
            {
                if(command == "gotoPageRequest" )
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_userId = userId ;
                    emit  sigEnterOrSync(8);
                }
                else if(command == "exitRequest")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_exitRequestId = userId;
                    emit sigEnterOrSync(10);
                }
                else if(command == "finishResp")
                {
                    QString auth = contentValue.toObject().take("auth").toString();
                    if(auth == "1")
                    {
                        emit sigEnterOrSync(56);//老师同意结束课程
                    }
                    else
                    {
                        emit sigEnterOrSync(64); // 不同意
                    }
                }
                else if(command == "enterRoomRequest")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_enterRoomRequest =  userId;
                    emit sigEnterOrSync(11);
                }
                else if(command == "enterRoom")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QString auth = contentValue.toObject().take("auth").toString();

                    // qDebug()<<"dfsddddddddddddd"<<auth <<StudentData::gestance()->m_selfStudent.m_studentId <<userId;
                    if(StudentData::gestance()->m_selfStudent.m_studentId == userId)
                    {
                        if(auth == "1")
                        {
                            emit sigEnterOrSync(66); //申请进入教室的返回 同意
                            TemporaryParameter::gestance()->m_isStartClass = true;
                            TemporaryParameter::gestance()->avPlaySetting.m_startTime = QString::number(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.currentTime).secsTo( QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.playTime) ) + TemporaryParameter::gestance()->avPlaySetting.m_startTime.toInt() );
                            emit sigAvUrl(TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );

                            // emit sigStartClassTimeData( "3767");

                        }
                        else
                        {
                            emit sigEnterOrSync(67); //申请进入教室的返回 不同意
                        }
                    }
                }
                else if(command == "control")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QString auth = contentValue.toObject().take("auth").toString();
                    m_userBrushPermissions[userId] = auth;

                    // qDebug()<<"aaaaaaaaaaaaaaaaaaaa"<<auth;
                    TemporaryParameter::gestance()->m_userBrushPermissionsId[userId] = auth;
                    TemporaryParameter::gestance()->m_uerIds = userId;
                    emit sigAuthtrail(m_userBrushPermissions);
                }
                else if(command == "exit")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QString auth = contentValue.toObject().take("auth").toString();
                    if(StudentData::gestance()->m_selfStudent.m_studentId == userId)
                    {
                        if(auth == "1")
                        {
                            emit sigEnterOrSync(63); //申请离开教室的返回 同意
                        }
                        else
                        {
                            emit sigEnterOrSync(64); //申请离开教室的返回 不同意
                        }
                    }
                }
                else if(command == "gotoPage")
                {
                    qDebug() << "dsddddddddddd 2222222222222";
                    QString userId = contentValue.toObject().take("userId").toString();
                    QString auth = contentValue.toObject().take("auth").toString();
                    qDebug() << TemporaryParameter::gestance()->m_userPagePermissions << StudentData::gestance()->m_selfStudent.m_studentId;
                    if(StudentData::gestance()->m_selfStudent.m_studentId == userId)
                    {
                        if(TemporaryParameter::gestance()->m_userPagePermissions == "1")
                        {
                            if(auth == "0")
                            {
                                TemporaryParameter::gestance()->m_userPagePermissions = auth;
                                emit sigEnterOrSync(72); //申请翻页收回权限
                            }
                            else
                            {
                                TemporaryParameter::gestance()->m_userPagePermissions = auth;
                                if(auth == "1")
                                {
                                    emit sigEnterOrSync(70); //申请翻页 同意
                                }
                                else
                                {
                                    emit sigEnterOrSync(71); //申请翻页 不同意
                                    //qDebug()<<"1";
                                }
                            }
                        }
                        else
                        {
                            TemporaryParameter::gestance()->m_userPagePermissions = auth;
                            if(auth == "1")
                            {
                                emit sigEnterOrSync(70); //申请翻页 同意
                            }
                            else
                            {
                                emit sigEnterOrSync(71); //申请翻页 不同意
                                qDebug() << "2";
                            }
                        }
                    }
                }
            }
            else if (domain == "control")
            {
                if(command.contains("magicface")  )
                {
                    QString contenturl = contentValue.toString();
                    if(contenturl.length() > 0)
                    {
                        emit sigSendHttpUrl(contenturl);
                    }
                }
                else if(command.contains("finishClass") )
                {
                    TemporaryParameter::gestance()->m_isFinishClass = true;
                    hasReciveFinishedClass = true;
                    emit sigStudentEndClass(fromUser);
                }
                else if(command.contains("settinginfo") )
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QJsonObject infos =  contentValue.toObject().take("infos").toObject();
                    QString  camera = infos.take("camera").toString();
                    QString  microphone = infos.take("microphone").toString();
                    QPair<QString, QString> pairStatus(camera, microphone);
                    StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
                    emit sigUserIdCameraMicrophone( userId, camera, microphone);
                    emit sigEnterOrSync(68); //改变频道跟音频 状态

                }
                else if(command.contains("avControl") )
                {
                    TemporaryParameter::gestance()->avPlaySetting.m_avType = contentValue.toObject().take("avType").toString();
                    TemporaryParameter::gestance()->avPlaySetting.m_startTime = contentValue.toObject().take("startTime").toString();
                    TemporaryParameter::gestance()->avPlaySetting.m_controlType = contentValue.toObject().take("controlType").toString();
                    TemporaryParameter::gestance()->avPlaySetting.m_avUrl = contentValue.toObject().take("avUrl").toString();
                    qDebug() << "avType ==" << "avPlaySetting.m_startTime" << TemporaryParameter::gestance()->avPlaySetting.m_startTime.toInt() << "avPlaySetting.playTime" << TemporaryParameter::gestance()->avPlaySetting.playTime;
                    //TemporaryParameter::gestance()->avPlaySetting.m_startTime =QString::number( TemporaryParameter::gestance()->avPlaySetting.playTime  + TemporaryParameter::gestance()->avPlaySetting.m_startTime.toInt() );
                    emit sigAvUrl(TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );
                }
                else if(command.contains("cursor") )
                {
                    QString xPoints = contentValue.toObject().take("X").toString();
                    QString  yPoints = contentValue.toObject().take("Y").toString();
                    double xPoint = xPoints.toDouble();
                    double yPoint = yPoints.toDouble();
                    emit sigPointerPosition( xPoint, yPoint);

                }
                else if(command == "openAnswerParsing" )
                {
                    emit sigOpenAnswerParsing(contentValue);
                    qDebug() << "command == sigOpenAnswerParsing " << msg << "1111111111111111111" << contentValue;
                }
                else if(command == "closeAnswerParsing" )
                {
                    emit sigCloseAnswerParsing(contentValue);
                    qDebug() << "command == sigCloseAnswerParsing " << msg << "1111111111111111111" << contentValue;
                }
                else if(command == "openCorrect" )
                {
                    getAllLessonCoursewareList->getLessonList();//重设课件列表
                    //重设批改 界面数据  为了客观题 自动批改
                    MessageModel model = m_pages[m_currentCourse][m_currentPage];
                    getCurrentItemBaseImage(currentColumnContent.toObject(), model.pageIndex);
                    correctViewIsOpen = true;
                    emit sigOpenCorrect(contentValue, true);
                    qDebug() << "sigOpenCorrect " << msg << "1111111111111111111" << contentValue;
                }
                else if(command == "correct" )
                {
                    correctViewIsOpen = true;
                    emit sigCorrect(contentValue);
                    getAllLessonCoursewareList->getLessonList();//重设课件列表
                }
                else if(command == "closeCorrect" )
                {
                    correctViewIsOpen = false;
                    emit sigCloseCorrect(contentValue);
                    qDebug() << "command == closeCorrect " << msg << "1111111111111111111" << contentValue;
                }
                else if(command == "zoomInOut")
                {
                    zoomRate = contentValue.toObject().take("zoomRate").toString().toDouble();

                    //                    if(zoomRate > 1.05)
                    //                    {
                    //                        zoomRate = 1.0;
                    //                         return;
                    //                    }

                    offsetX = contentValue.toObject().take("offsetX").toString().toDouble();
                    offsetY = contentValue.toObject().take("offsetY").toString().toDouble();

                    //重设 该页的滚动条位置
                    m_pages[m_currentCourse][m_currentPage].offSetX = offsetX;
                    m_pages[m_currentCourse][m_currentPage].offSetY = offsetY;
                    m_pages[m_currentCourse][m_currentPage].zoomRate = zoomRate;
                    emit sigZoomInOut(offsetX, offsetY, zoomRate);
                }

            }
        }
    }
    else
    {
        qDebug() << "error ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" << msg << error.error;
    }
}

void SocketHandler::reSendMessage()
{
    quint64 currtime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    quint64 timediff = currtime - m_uLastSendTimeStamp;

    if((timediff >= 2000) && NULL != m_socket)
    {
         if(!m_lastSendMsg.isEmpty())
         {
             sendMessage(m_lastSendMsg);
         }
    }
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
    content.insert(kSocketDevInfo, StudentData::gestance()->m_deviceInfo);
    content.insert(kSocketUserType, kSocketSTU);
    content.insert(kSocketPlat, kSocketSPC);

    //进入房间-第一条信息
    m_bServerResp = true;

    //进入房间-结束课程设置为false
    m_bConfirmFinish = false;

    QString msg = createMessageTemplate(kSocketEnterRoom, lid, uid, content);
    return msg;
}

void SocketHandler::checkServerResponse(QString target)
{
    if(!m_bServerResp && !m_lastSendMsg.isEmpty())
    {
        if(m_lastSendMsg.contains(target))
        {
            m_bServerResp = true;

            //服务器已确认-更新最后发送时间
            m_uLastSendTimeStamp = createTimeStamp();
            m_lastSendMsg = "";

            if(m_bConfirmFinish)
            {
                finishRespExitRoom();
            }
        }
    }
}

void SocketHandler::finishRespExitRoom()
{
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
         content.insert(kScoketPageId, pageId);

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

 QString SocketHandler::docReqMsgTemplate(int currPageNo, int pageTotal, QString coursewareId)
 {
     quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
     quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

     QJsonObject content;

      //协议中的content内容
     content.insert(kSocketDocPageNo, currPageNo);
     content.insert(kSocketDocTotalNum, pageTotal);
     content.insert(kSocketDocDockId, coursewareId);

     QString msg = createMessageTemplate(kSocketDoc, lid, uid, content);
     return msg;
 }

 QString SocketHandler::avReqMsgTemplate(int playStatus, int timeSec, qint64 coursewareId)
  {
      quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
      quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

      QJsonObject content;

       //协议中的content内容
      content.insert(kSocketAVFlag, playStatus);
      content.insert(kSocketTime, timeSec);
      content.insert(kSocketDocDockId, coursewareId);

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
    content.insert(kScoketPageId, pageId);

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
    qDebug() << "=====pageReqMsgTemplate========";
    QString msg = createMessageTemplate(kSocketAuth, lid, uid, content);
    return msg;
}

//仅且将需要服务器回执的消息加入队列中
void SocketHandler::joinMessageToQue(QString content)
{
    QString command = parseMessageCommand(content);
    if(kSocketEnterRoom == command || kSocketTrail == command || kSocketDoc == command || kSocketFinish == command || kSocketMuteAll == command ||
            kSocketAuth == command || kSocketPage == command || kSocketAV == command || kSocketExitRoom == command || kSocketZoom == command || kSocketOperation == command ||
            kSocketReward == command || kSocketRoll == command || kSocketResponder == command || kSocketTimer == command) //严格限制队列权限
    {
        QMutexLocker locker(&m_mSendMsgsQueMutex);
        m_qListMsgsQue.append(content);
    }
}

void SocketHandler::cleanMessageQue()
{
    QMutexLocker locker(&m_mSendMsgsQueMutex);
    m_qListMsgsQue.clear(); //清空队列
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
    content.insert(kScoketPageId,pageId);
    content.insert(kSocketDocDockId,coursewareId);

    QString msg = createMessageTemplate(kSocketOperation, lid, uid, content);
    return msg;
}

QString SocketHandler::rewardMsgTemplate(QString whoUid, int rewardType, int millisecond)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketUid, whoUid);
    content.insert(kSocketType, rewardType);
    content.insert(kSocketTime, millisecond);

    QString msg = createMessageTemplate(kSocketReward, lid, uid, content);
    return msg;
}

QString SocketHandler::rollMsgTemplate(QString whoUid, int rollType)
{
    quint64 lid = StudentData::gestance()->m_liveRoomId.toLongLong();
    quint64 uid = StudentData::gestance()->m_currentUserId.toLongLong();

    QJsonObject content;

     //协议中的content内容
    content.insert(kSocketUid, whoUid);
    content.insert(kSocketType, rollType);

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
    content.insert(kScoketPageId, pageId);
    content.insert(kSocketRatio, factorRatio);
    content.insert(kSocketOffsetX, factorOffsetX);
    content.insert(kSocketOffsetY, factorOffsetY);

    QString msg = createMessageTemplate(kSocketZoom, lid, uid, content);
    return msg;
}

void SocketHandler::cacheDocInfo(QJsonArray coursewareUrls, QString coursewareId)
{
    if (m_pages.contains("DEFAULT"))
    {
        m_pages.insert(coursewareId, m_pages.value("DEFAULT"));
        m_pages.remove("DEFAULT");
        m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
        m_currentPage = m_pages[m_currentCourse].size();
        for (int i = 0; i < coursewareUrls.size(); ++i)
        {
            m_pages[m_currentCourse].append(MessageModel(1, coursewareUrls.at(i).toString(), 1.0, 1.0, currentCourwareType));
        }
    }
    else if (!m_pages.contains(coursewareId))
    {
        QList<MessageModel> list;
        list.append(MessageModel(0, "", 1.0, 1.0, currentCourwareType));

        m_pages.insert(coursewareId, list);
        m_pageSave.insert(m_currentCourse, m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
        m_currentPage = 1;
        for (int i = 0; i < coursewareUrls.size(); ++i)
        {
            m_pages[m_currentCourse].append(MessageModel(1, coursewareUrls.at(i).toString(), 1.0, 1.0, currentCourwareType));
        }
    }
    else
    {
        m_pageSave.insert(m_currentCourse, m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = coursewareId;
        TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
        m_currentPage = m_pageSave.value(m_currentCourse, 0);
    }
    //m_currentPlanId = coursewareId;
}

bool SocketHandler::updateCoursewareInfo(QString& coursewareId, QString& coursewareMsg)
{
    if(m_pages.contains(coursewareId))
    {
        return true;
    }

    QJsonObject couldDiskFileInfo = QJsonDocument::fromJson(coursewareMsg.toUtf8().data()).object();
    QJsonObject data = couldDiskFileInfo.take(kSocketContent).toObject();
    qDebug()<< "==updateCoursewareInfo==" << data << couldDiskFileInfo;
    if(data.contains(kSocketDocUrls))
    {
        QJsonArray coursewareUrls;
        QJsonArray arrUrls = data.take(kSocketDocUrls).toArray();
        for(int i = 0; i < arrUrls.size(); ++i)
        {
            coursewareUrls.append(arrUrls.at(i).toString());
        }

        cacheDocInfo(coursewareUrls, coursewareId);

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
                cacheDocInfo(qsStringList, dockId);
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
    emit sigPointerPosition(factorX, factorY);
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

    //同步课件状态
    if(!coursewareId.isEmpty())
    {
        if(!m_pages.contains(coursewareId))
        {
            cacheCoursewareInfo(message);
        }
        else
        {
            QJsonArray coursewareUrls;
            cacheDocInfo(coursewareUrls, coursewareId);
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
        if(m_sysnStatus)
        {
            QJsonObject avFileInfo = m_miniLessonManager.getCloudDiskFileInfo(m_avId);
            avFileInfo = avFileInfo.value("data").toObject();
            avFileInfo.insert("flagState",m_avFlag);
            avFileInfo.insert("playTimeSec",m_avPlayTime);
            emit sigPlayAv(avFileInfo);
        }
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

        m_currentPage = pageI;
        m_pageSave.insert(m_currentCourse, m_currentPage);
        TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);

        /*QStringList strList = m_currentCourse.split("|");
        //qDebug() << "========goto::page=======" << m_currentCourse << m_currentPage << strList.size();
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            if (m_pages.contains(m_currentCourse))
            {
                if (m_pages[m_currentCourse].size() > 1)
                {
                    //QString questionId = m_pages[m_currentCourse].at(m_currentPage).questionId;
                    //double m_offsetY = m_pages[m_currentCourse].at(m_currentPage).offsetY;
                    //bool m_questionStatus = m_pages[m_currentCourse].at(m_currentPage).questionBtnStatus;

                    m_pageSave.insert(m_currentCourse, m_currentPage);
                    if (m_sysnStatus)
                    {
                        emit sigCurrentQuestionId(planId, columnId, questionId, m_offsetY, m_questionStatus);
                    }
                }
            }
        }*/
        break;
    }
    case 2: //加页
    {
        m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, 1));
        /*QStringList strList = m_currentCourse.split("|");
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            emit sigCurrentQuestionId(planId, columnId, "", 0, false);
        }*/
        break;
    }
    case 3: //删页
    {
        //如果是课件不能删除
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        if(model.isCourware)
        {
            emit sigIsCourseWare();
            return;
        }

        if (m_pages[m_currentCourse].size() == 1)
        {
            m_pages[m_currentCourse][0].release();
            m_pages[m_currentCourse].removeAt(0);

            m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, 1));

            /*QStringList strList = m_currentCourse.split("|");
            if (strList.size() > 1)
            {
                QString planId = strList.at(0);
                QString columnId = strList.at(1);
                //emit sigCurrentQuestionId(planId, columnId, "", 0, false);
            }*/
            return;
        }
        m_pages[m_currentCourse][m_currentPage].release();
        m_pages[m_currentCourse].removeAt(m_currentPage);

        m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;

        /*QStringList strList = m_currentCourse.split("|");
        if (strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            QString docId = planId + "|" + columnId;
            if (m_pages.contains(docId))
            {
                QString questionId = m_pages[docId].at(m_currentPage).questionId;
                //emit sigCurrentQuestionId(planId, columnId, questionId, 0, false);
            }
        }*/
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
        qDebug() << "=======videoState::AA========="<< upState << trailState << videoState << audioState;

        if((upState != -1) && (trailState != -1) && (audioState != -1) && (videoState != -1))
        {
            //有值时, 才发信号更新授权状态
            TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(qsUid, QString::number(trailState));
            QPair<QString, QString> cameraPhonePair(QString::number(videoState),QString::number(audioState));
            qDebug() << "=======videoState========="<< qsUid<< upState << trailState << videoState << audioState;
            StudentData::gestance()->m_cameraPhone.insert(qsUid,cameraPhonePair);
            StudentData::gestance()->m_userUp.insert(qsUid,QString::number(upState));
            emit sigAuthChange(qsUid,upState,trailState,audioState,videoState);
        }
//    }
}

//禁音数据解析
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
        QString userId = YMUserBaseInformation::id;
        sigMuteChange(userId,nRet);
    }
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
    qDebug() << "===reward::userId===" << whoUid;
    //缓存奖励累计信息
    StudentData::gestance()->addReward(whoUid);
    if(m_isInit)
    {
        emit sigTrophy(whoUid);
    }
}

void SocketHandler::cacheRoll(QString& fromUid, QString& message)
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

    if(!contentJsonObj.isEmpty())
    {
        sigStartRandomSelectView(contentJsonObj);
    }

    QString whoUid  = "";
    if(contentJsonObj.contains(kSocketUid))
    {
        whoUid = contentJsonObj.take(kSocketUid).toString();
    }

    qint32 rollType = 0;
    if(contentJsonObj.contains(kSocketType))
    {
        rollType = contentJsonObj.take(kSocketType).toInt();
    }

    //缓存随机信息
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

void SocketHandler::cacheTimer(QString& fromUid, QString& message)
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

    if(!contentJsonObj.isEmpty())
    {
        sigResetTimerView(contentJsonObj);
        return;
    }

    qint32 timerType = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        timerType = contentJsonObj.take(kSocketType).toInt();
    }

    qint32 timerFlag = 0;
    if(contentJsonObj.contains(kSocketFlag))
    {
        timerFlag = contentJsonObj.take(kSocketFlag).toInt();
    }

    qint32 timeSec = 0;
    if(contentJsonObj.contains(kSocketTime))
    {
        timeSec = contentJsonObj.take(kSocketTime).toInt();
    }

    //缓存计时信息
}

void SocketHandler::cacheStartClass()
{
    //缓存-开始上课
}

//滚动数据解析
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
    qint64 ratio = 0, offsetX = 0;
    double offsetY = 0;

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

        m_pages[m_currentCourse][m_currentPage].offSetX = factorX;
        m_pages[m_currentCourse][m_currentPage].offSetY = factorY;
        m_pages[m_currentCourse][m_currentPage].zoomRate = factorOffsetRatio;
        emit sigZoomInOut(factorX,factorY,factorOffsetRatio);
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
    if(contentJsonObj.contains(kScoketPageId))
    {
        pageId = contentJsonObj.take(kScoketPageId).toString();
    }

    return pageId;
}

//通过http请求获取历史记录
bool SocketHandler::syncUserHistroyReq(QJsonArray& userHistroyData)
{
    QNetworkRequest netRequest;
    QString qsUrl = QString("http://") + StudentData::gestance()->m_address + QString("/socks/sync");
    QUrl url(qsUrl);
    url.setPort(5251); //HTTP端口5251
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
            if(jsonData.contains(kSocketSn))
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
            }

            //同步历史-是否已经上过课
            if(jsonData.contains(kSocketIsAlreadyClass))
            {
                bool isAlreadyClass = jsonData.take(kSocketIsAlreadyClass).toBool();
            }

            if(jsonData.contains(kSocketHttpMsgs))
            {
                //解析:同步历史记录
                userHistroyData = jsonData.take(kSocketHttpMsgs).toArray();
                return true;
            }
        }
    }

    return true;
}

void SocketHandler::fixUserSnFromServer(qint32 nMySn)
{
    QMutexLocker locker(&m_mMessageNumMutex);
    m_uMessageNum = nMySn;
}

//解析消息
void SocketHandler::parseMsg(QString& msg)
{
    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(msg.toUtf8(), &error);

    if(error.error == QJsonParseError::NoError && documet.isObject())
    {
        QJsonObject jsonObj = documet.object();
        QString fromUser, command("xxxxxx");
        QJsonValue contentValue;

        if(jsonObj.contains(kSocketUid))
        {
            QJsonValue typeValue = jsonObj.take(kSocketUid);
            if(typeValue.isString())
                fromUser = typeValue.toString();
        }

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
            checkServerResponse(target);
            return;
        }

        if(jsonObj.contains(kSocketContent))
            contentValue = jsonObj.take(kSocketContent);

        if (command == kSocketEnterRoom)
        {
            //qDebug()<<"else if (command == enterRoom )"<<num<<StudentData::gestance()->m_selfStudent.m_studentId<<StudentData::gestance()->m_teacher.m_teacherId;
            QString userId = fromUser;
            qDebug() << "===enterRoom::userId===" << userId << StudentData::gestance()->m_currentUserId;
            if (userId == StudentData::gestance()->m_currentUserId)//自己进入房间 开始同步
            {
                //qDebug()<<"else if (command == \"enterRoom\")"<<"111111111111 self ";
                emit sigEnterOrSync( 1 ) ;
                StudentData::gestance()->insertIntoOnlineId(userId);

                checkServerResponse(kSocketEnterRoom);

                //同步历史记录
                QJsonArray userHistroyMsgs;
                if(syncUserHistroyReq(userHistroyMsgs))
                {
                    //回复服务器-同步历史记录完成
                    QString replyMessage = syncUserHistroyFinMsgTemplate();
                    qDebug() << "======replyMessage======" << replyMessage;
                    sendMessage(replyMessage);

                    //同步历史记录成功-深入解析对应数据
                    QString hisCommand, hisMessage;
                    int size = userHistroyMsgs.size();
                    for(int i = 0; i < size; ++i)
                    {
                        QJsonObject userHistroyMsg = userHistroyMsgs.at(i).toObject();

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

                        if(kSocketTrail == hisCommand || kSocketPoint == hisCommand || kSocketDoc == hisCommand || kSocketAV == hisCommand ||
                                kSocketAuth == hisCommand || kSocketMuteAll == hisCommand || kSocketPage == hisCommand ||
                                kSocketZoom == hisCommand || kSocketOperation == hisCommand || kSocketReward == hisCommand || kSocketStartClass == hisCommand)  //暂时同步历史记录权限全部放开, 后面与服务器协商, 垃圾消息不予通过
                        {
                            parseUserCommandOp(hisCommand, hisMessage);//执行历史记录操作
                        }

                        //临时方案-同步历史记录时每100条发一条心跳进行保活
                        if((i % 100) == 0)
                        {
                            QString keepAliveMessage = keepAliveReqMsgTemplate();
                            sendMessage(keepAliveMessage);
                        }
                    }
                }

                if(m_isOneStart == false)
                {
                    emit sigEnterOrSync(201);
                }

                m_isOneStart = true;
                syncUserHistroyComplete();

                m_isInit = true;
                TemporaryParameter::gestance()->m_isAlreadyClass = m_isInit;
            }
            else
            {
                if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
                {
                    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                    {
                        if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                        {
                            //TemporaryParameter::gestance()->m_isAlreadyClass = true;
                            emit sigSendUserId(StudentData::gestance()->m_student[i].m_studentId);
                            emit sigEnterOrSync(3);
                            //qDebug()<< "=============userId========" << userId << m_isInit << TemporaryParameter::gestance()->m_isAlreadyClass;
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
                            //TemporaryParameter::gestance()->m_isAlreadyClass = true;
                            emit sigSendUserId(userId);
                            emit sigEnterOrSync(3);
                            //qDebug()<< "=============userId========" << userId << m_isInit << TemporaryParameter::gestance()->m_isAlreadyClass;
                            break;
                        }
                    }
                }
            }
        }
        else if(command == kSocketEnterFailed)
        {
           checkServerResponse(kSocketEnterRoom);

            //提示进入房间失败
            emit sigEnterOrSync(0);
        }
        else if (command == kSocketKickOut)
        {
             emit sigEnterOrSync(80);//账号在其他地方登录 被迫下线
             qDebug() << QStringLiteral("账号在其他地方登录 被迫下线");
        }
        else if(command == kSocketFinish)
        {
            QString message = finishMsgTemplate();
            sendMessage(message);

            //退出教室
            StudentData::gestance()->removeOnlineId(fromUser);
            if(StudentData::gestance()->m_teacher.m_teacherId == fromUser )
            {
                TemporaryParameter::gestance()->m_isStartClass = false;
            }
            emit sigExitRoomIds(fromUser);

        }
        else if(kSocketTrail == command || kSocketDoc == command || kSocketPage == command || kSocketOperation == command) //此处为及时通讯信息-需要重绘画板
        {
            //回复服务器-发送回执信息
            QString replyMessage = ackServerMsgTemplate(m_uServerSn);
            sendMessage(replyMessage);

            //处理及时协议命令操作
            parseUserCommandOp(command, msg);

            //画一页
            m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;

            MessageModel model = m_pages[m_currentCourse][m_currentPage];
            model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
            emit sigDrawPage(model);
        }
        else if(kSocketAV == command || kSocketAuth == command || kSocketMuteAll == command || kSocketZoom == command ||
                kSocketReward == command || kSocketRoll == command || kSocketResponder == command || kSocketTimer == command || kSocketStartClass == command) //此处为及时通讯信息-但不需要重绘画板
        {
            //回复服务器-发送回执信息
            QString replyMessage = ackServerMsgTemplate(m_uServerSn);
            sendMessage(replyMessage);

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
            sendMessage(replyMessage);

            //更新用户状态信息
            updateUserState(contentValue);
        }
        else if(kSocketExitRoom == command) //防止服务器狂发exitRoom协议
        {
             //回复服务器-发送回执信息
             QString replyMessage = ackServerMsgTemplate(m_uServerSn);
             sendMessage(replyMessage);
        }
        else //防止服务器狂发垃圾协议
        {
             //回复服务器-发送回执信息
             QString replyMessage = ackServerMsgTemplate(m_uServerSn);
             sendMessage(replyMessage);
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
    else if(kSocketRoll == command)
    {
        cacheRoll(fromUser, message);
    }
    else if(kSocketResponder == command)
    {
        cacheResponder(fromUser, message);
    }
    else if(kSocketTimer == command)
    {
        cacheTimer(fromUser, message);
    }
    else if(kSocketStartClass == command)
    {
        cacheStartClass();
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

    qDebug() << "====syncUserHistroyComplete===" << m_currentPage << m_currentCourse;

    MessageModel model = m_pages[m_currentCourse][m_currentPage];
    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);

    emit sigAuthtrail(m_userBrushPermissions);
    emit sigDrawPage(model);
    emit sigEnterOrSync(2) ;

    if(!m_avId.isEmpty())
    {
        QJsonObject avFileInfo = m_miniLessonManager.getCloudDiskFileInfo(m_avId);
        avFileInfo = avFileInfo.value("data").toObject();
        avFileInfo.insert("flagState",m_avFlag);
        avFileInfo.insert("playTimeSec",m_avPlayTime);
        emit sigPlayAv(avFileInfo);
    }

    m_sysnStatus = true;

    //qDebug() << "############m_sysnStatus##############" << m_currentPlanId << m_currentColumnId;

    /*if(m_currentPlanId == "" && m_currentColumnId == "")
    {
        return;
    }*/

    //emit sigPlanChange(0, m_currentPlanId.toLong(), m_currentColumnId.toLong());
    //emit sigCurrentQuestionId(m_currentPlanId, m_currentColumnId, m_currentQuestionId, offsetY, m_currentQuestionButStatus);
    //emit sigCurrentColumn(m_currentPlanId.toLong(), m_currentColumnId.toLong());
    //emit sigOffsetY(offsetY);
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

            if(uid == StudentData::gestance()->m_teacher.m_teacherId)
            {
                TemporaryParameter::gestance()->m_teacherIsOnline = true;
            }
            //动态添加学生进入教室
            if(StudentData::gestance()->m_currentUserId != uid)
            {
                //emit sigJoinClassroom(uid);
            }
        }
    }
}

void SocketHandler::startSendMsg()
{
    m_sendMsgTask->start(400);
}

void SocketHandler::stopSendMsg()
{
    if (m_sendMsgTask->isActive())
        m_sendMsgTask->stop();
}

void SocketHandler::excuteMsg(QString &msg, QString &fromUser)
{
    QJsonParseError err;
    QJsonDocument document = QJsonDocument::fromJson(msg.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        QString domain = document.object().take("domain").toString();
        QString command = document.object().take("command").toString();
        QJsonValue contentVal = document.object().take("content");
        //qDebug()<<"111111111111111:::"<<domain<<command<<contentVal;
        if (domain == "draw" && command == "courware")
        {
            currentCourwareType = 1;

            QJsonObject contentObj = contentVal.toObject();
            QString docId = contentObj.take("docId").toString();
            QJsonArray arr = contentObj.take("urls").toArray();
            if (m_pages.contains("DEFAULT"))
            {
                m_pages.insert(docId, m_pages.value("DEFAULT"));
                m_pages.remove("DEFAULT");
                m_currentCourse = docId;
                TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                m_currentPage = m_pages[m_currentCourse].size();
                for (int i = 0; i < arr.size(); ++i)
                {
#ifdef USE_OSS_AUTHENTICATION
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, currentCourwareType, 0));
#else
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, currentCourwareType));
#endif
                }
            }
            else if (!m_pages.contains(docId))
            {
                QList<MessageModel> list;

#ifdef USE_OSS_AUTHENTICATION
                list.append(MessageModel(0, "", 1.0, 1.0, currentCourwareType, 0));
#else
                list.append(MessageModel(0, "", 1.0, 1.0, currentCourwareType));
#endif

                m_pages.insert(docId, list);
                m_pageSave.insert(m_currentCourse, m_currentPage);
                TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                m_currentCourse = docId;
                TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                m_currentPage = 1;
                for (int i = 0; i < arr.size(); ++i)
                {
#ifdef USE_OSS_AUTHENTICATION
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, currentCourwareType, 0));
#else
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, currentCourwareType));
#endif
                }
            }
            else
            {
                m_pageSave.insert(m_currentCourse, m_currentPage);
                TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                m_currentCourse = docId;
                TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                m_currentPage = m_pageSave.value(m_currentCourse, 0);
            }
        }
        else if(domain == "draw" && command == "lessonPlan")
        {
            //判断是否是已存在的新讲义 已存在的 直接获取新讲义上次操作的栏目位置和页数

            m_pageSave.insert(m_currentCourse, m_currentPage);
            TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
            //记录当前新讲义的栏目位置


            QJsonObject contentObj = contentVal.toObject();
            QString docId = contentObj.value("planId").toString();
            if(contentObj.value("planId").isString() == false)
            {
                docId = QString::number(contentObj.value("planId").toInt());
            }

            QJsonArray columns = contentObj.take("columns").toArray();//所有栏目的数组数据

            if(columns.size() <= 0)
            {
                return;
            }
            qDebug() << "command lessonPlan lessonPlan " << m_currentCourse << m_pages.size() << m_currentPage;
            //新课件数据存储
            currentCourwareType = 2;
            QString rCurrentColumnId;
            QString rCurrentPlanId;
            currentPlanContent = contentVal;

            //遍历 以栏目存 新讲义的数据结构 保存数组大小
            // getAllLessonCoursewareList->allNewCoursewarwList ;
            //qDebug() << "all lessonpaln column" << columns.size();
            for(int a = 0; a < columns.size(); a++ )
            {
                QJsonArray arr; //对应栏目下 数据的集合
                QString columnId = columns.at(a).toObject().value("columnId").toString();
                if(columns.at(a).toObject().value("columnId").isString() ==  false)
                {
                    columnId = QString::number(columns.at(a).toObject().value("columnId").toInt());
                }

                if(a == 0)
                {
                    rCurrentPlanId = docId + "yxt" + columnId;
                    rCurrentColumnId = columnId;
                }
                currentColumnId = columnId;
                m_currentCourse = docId + "yxt" + columnId;
                currentPlanId = docId;
                //qDebug() << "all lessonpaln column currentColumnId" << currentColumnId;

                //如果资源类型不是题目的类型 获取 该栏目下的资源数组 array  图 或者 富文本
                int columnType = columns.at(a).toObject().value("columnType").toInt();
               // qDebug() << "all lessonpaln column columnType" << columnType;
                if( columnType == 0 )
                {
                    arr = getAllLessonCoursewareList->getColumnItemNumber(docId, currentColumnId);
                }
                else
                {
                    arr = columns.at(a).toObject().value("questions").toArray();
                }
                // qDebug()<<"all lessonpaln column arr 0 "<<m_pages.contains(m_currentCourse)<<m_currentCourse<<currentColumnId<<columnType;
                if (m_pages.contains("DEFAULT"))
                {
                    m_pages.insert(m_currentCourse, m_pages.value("DEFAULT"));
                    m_pages.remove("DEFAULT");
                    //qDebug() << "all lessonpaln column arr DEFAULT " << currentColumnId << m_currentCourse << m_pages[m_currentCourse][currentColumnId].size();
                    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                    m_currentPage = m_pages[m_currentCourse].size();
                    for (int i = 0; i < arr.size(); ++i)
                    {
                        //传入 新讲义需要的数据
#ifdef USE_OSS_AUTHENTICATION
                        MessageModel msg = MessageModel(1, "", 1.0, 1.0, currentCourwareType, 0);
#else
                        MessageModel msg = MessageModel(1, "", 1.0, 1.0, currentCourwareType);
#endif

                        if(columnType == 0)
                        {
                            msg.setNewCourseware(columnId.toInt(), columnType, i, "", arr.at(i).toObject());
                        }
                        else
                        {
                            msg.setNewCourseware(columnId.toInt(), columnType, i, arr.at(i).toString(), arr.at(i).toObject());
                        }
                        m_pages[m_currentCourse].append(msg);
                    }
                    //新讲义同步到 第二页  老课件同步到第一页
                    m_pageSave.insert(m_currentCourse, m_currentPage);
                    TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                    //qDebug() << "all lessonpaln column arr DEFAULT 2 " << m_pages[m_currentCourse][currentColumnId].size() << m_currentCourse << currentColumnId;
                }
                else if (m_pages.contains(m_currentCourse) == false)//不包含这个就插进去
                {
                    //qDebug() << "!m_pages.contains(m_currentCourse)" << m_currentPage;
                    QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
                    list.append(MessageModel(0, "", 1.0, 1.0, 1, 0));
#else
                    list.append(MessageModel(0, "", 1.0, 1.0, 1));
#endif

                    m_pages.insert(m_currentCourse, list); //插入空白页
                    m_pageSave.insert(m_currentCourse, m_currentPage);
                    TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                    m_currentPage = 1;

                    //插入数据
                    for (int i = 0; i < arr.size(); ++i)
                    {
#ifdef USE_OSS_AUTHENTICATION
                        MessageModel msg = MessageModel(1, "", 1.0, 1.0, currentCourwareType, 0);
#else
                        MessageModel msg = MessageModel(1, "", 1.0, 1.0, currentCourwareType);
#endif
                        if(columnType == 0)//第一种资源类型 存入资源obj 数据
                        {
                            msg.setNewCourseware(columnId.toInt(), columnType, i, "", arr.at(i).toObject());
                        }
                        else
                        {
                            msg.setNewCourseware(columnId.toInt(), columnType, i, arr.at(i).toString(), arr.at(i).toObject());
                        }
                        m_pages[m_currentCourse].append(msg);
                    }
                    //qDebug() << "all lessonpaln column arr 33bucunzai 1 " << currentColumnId << m_currentCourse << m_pages[m_currentCourse][currentColumnId].size();
                }
                else
                {
                    //qDebug() << "all lessonpaln column arr 44" << columnId << currentColumnId << m_currentCourse << m_pages[m_currentCourse].contains(currentColumnId);
                    // m_pageSave.insert(m_currentCourse,m_currentPage);
                    //qDebug()<<"beign ::::"<<m_currentCourse<<m_currentPage;
                    //TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse,m_currentPage);
                    m_currentCourse = docId + "yxt" + columnId;
                    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                    m_currentPage = m_pageSave.value(m_currentCourse, 0);
                    //qDebug()<<"after ::::"<<m_currentCourse<<m_currentPage;
                }
            }
            //            if(columns.size() == 0)
            //            {
            //                if(m_currentCourse == "DEFAULT")
            //                {
            //                    currentColumnId = "DEFAULT";
            //                }
            //                return;
            //            }
            // m_currentCourse = rCurrentPlanId;//默认为 第一个课件id
            //  currentColumnId = rCurrentColumnId;
        }
        else if(domain == "draw" && command == "column")
        {
            m_pageSave.insert(m_currentCourse, m_currentPage);
            qDebug() << "m_currentCourse" << m_currentCourse << m_currentPage;
            TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);

            currentCourwareType = 2;
            QJsonObject contentObj = contentVal.toObject();
            currentColumnContent = contentObj;//保存当前的 content内容
            currentColumnId = contentObj.value("columnId").toString();

            if(contentObj.value("columnId").isString() == false)
            {
                currentColumnId = QString::number(contentObj.value("columnId").toInt());
            }
            //重新组合 课件id
            if(m_currentCourse.split("yxt").size() == 2)
            {
                m_currentCourse = m_currentCourse.split("yxt").at(0) + "yxt" + currentColumnId  ;
                currentPlanId = m_currentCourse.split("yxt").at(0);//记录当前讲义id
            }

            TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
            m_currentPage = contentObj.value("pageIndex").toString().toInt();

            m_pageSave.insert(m_currentCourse, m_currentPage);
            TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);


            //qDebug() << "m_currentCourse 2 " << m_currentCourse << m_currentPage;
            //qDebug() << "drag columnId" << m_pageSave.value(m_currentCourse, 0) << m_pages[m_currentCourse][currentColumnId].size();;





            //            qDebug()<<"draw first step 0"<<currentColumnId<<m_currentCourse<<m_currentPage;
            //            int pageI = contentObj.value("pageIndex").toInt();
            //            if(contentObj.value("pageIndex").isString())
            //            {
            //                pageI = contentObj.value("pageIndex").toString().toInt();
            //            }
            //            qDebug()<<"draw first step 2 "<<currentColumnId<<m_currentCourse<<m_currentPage<<pageI<<m_pages[m_currentCourse][currentColumnId].size();
            //            if (pageI > m_pages[m_currentCourse][currentColumnId].size()-1)
            //                pageI = m_pages[m_currentCourse][currentColumnId].size()-1;

            //            m_currentPage = pageI;
        }
        else if (domain == "page" && command == "goto")
        {
           if(currentCourwareType == 2)
            {
                QJsonObject tobj = currentColumnContent.toObject();
                tobj.take("pageIndex");
                tobj.insert("pageIndex", QString::number(m_currentPage));
                currentColumnContent = tobj;
            }
            int pageI = contentVal.toObject().take("page").toString().toInt();
            pageI = pageI < 0 ? 0 : pageI;
            if (pageI > m_pages[m_currentCourse].size() - 1)
            {
                pageI = m_pages[m_currentCourse].size() - 1;
            }
            m_currentPage = pageI;
            m_pageSave.insert(m_currentCourse, m_currentPage);
            TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
            //qDebug() << "goto page" << m_currentPage << currentColumnId << m_currentCourse;

        }
        else if (domain == "page" && command == "insert")
        {
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, 1, 0));
#else
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, 1));
#endif

        }
        else if (domain == "page" && command == "delete")
        {

            if (m_pages[m_currentCourse].size() == 1)
            {
                m_pages[m_currentCourse][0].release();
                m_pages[m_currentCourse].removeAt(0);
                //                model->release();
#ifdef USE_OSS_AUTHENTICATION
                m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, 1, 0));
#else
                m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, 1));
#endif
                return;
            }
            m_pages[m_currentCourse][m_currentPage].release();
            m_pages[m_currentCourse].removeAt(m_currentPage);
            //            model->release();
            m_currentPage = m_currentPage >= m_pages[m_currentCourse].size() ? m_pages[m_currentCourse].size() - 1 : m_currentPage;
        }
        else if (domain == "draw" && command == "picture")
        {
            QString url = contentVal.toObject().take("url").toString();
            double width = contentVal.toObject().take("width").toString().toDouble();
            double height = contentVal.toObject().take("height").toString().toDouble();
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, 1, 0));
#else
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, 1));
#endif
        }
        else if (domain == "auth" && command == "control")
        {
            QString uid = contentVal.toObject().take("userId").toString();
            QString auth = contentVal.toObject().take("auth").toString();
            TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(uid, auth);
            m_userBrushPermissions.insert(uid, auth);
        }
        else if (domain == "auth" && command == "gotoPage")
        {
            //qDebug() << "213222222222222222222211eeeeeeee";
            QString uid = contentVal.toObject().take("userId").toString();
            QString auth = contentVal.toObject().take("auth").toString();
            m_userPagePermissions.insert(uid, auth);
            if(StudentData::gestance()->m_selfStudent.m_studentId == uid)
            {

                TemporaryParameter::gestance()->m_userPagePermissions = auth;
                //qDebug()<<"myself qqqqqqqqqqqqqqqqqqqqq"<<TemporaryParameter::gestance()->m_userPagePermissions;
            }
        }
        else if (domain == "server" && command == "changeAudio")
        {
            m_supplier = contentVal.toObject().take("supplier").toString();
            m_videoType = contentVal.toObject().take("videoType").toString();
            hasChangeAudio = true;
            TemporaryParameter::gestance()->m_supplier = m_supplier;
            TemporaryParameter::gestance()->m_videoType = m_videoType;
        }
        else if (domain == "draw" &&
                 (command == "trail" || command == "polygon" || command == "ellipse"))
        {
            m_pages[m_currentCourse][m_currentPage].addMsg(fromUser, msg);

            //qDebug() << "draw trail " << m_currentCourse << m_currentPage << currentColumnId;
            //            model->addMsg(fromUser,msg);
        }
        else if (domain == "draw" && command == "undo") //撤销删除对应的当前记录
        {
            //            MessageModel *model = m_pages[m_currentCourse].at(m_currentPage);
            m_pages[m_currentCourse][m_currentPage].undo(fromUser);
        }
        else if (domain == "draw" && command == "clear")
        {
            MessageModel& model = m_pages[m_currentCourse][m_currentPage];
            //            if(!model.isCourware) {
            //                model.bgimg="";
            //            }

            m_pages[m_currentCourse][m_currentPage].clear();
        }
        else if (domain == "server" && command == "startClass")
        {

            m_isInit = true;
            TemporaryParameter::gestance()->m_isAlreadyClass = m_isInit;
        }
        else if (domain == "control" && command == "settinginfo")
        {
            QString userId = contentVal.toObject().take("userId").toString();
            QJsonObject infos =  contentVal.toObject().take("infos").toObject();
            QString  camera = infos.take("camera").toString();
            QString  microphone = infos.take("microphone").toString();
            //            StudentData::gestance()->m_camera = camera;
            //            StudentData::gestance()->m_microphone = microphone;
            QPair<QString, QString> pairStatus(camera, microphone);
            StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
            // qDebug()<<"StudentData::gestance()->m_cameraPhone"<< StudentData::gestance()->m_cameraPhone;

        }
        else if (domain == "control" && command == "avControl")
        {
            TemporaryParameter::gestance()->avPlaySetting.m_avType = contentVal.toObject().take("avType").toString();
            TemporaryParameter::gestance()->avPlaySetting.m_startTime = contentVal.toObject().take("startTime").toString();
            TemporaryParameter::gestance()->avPlaySetting.m_controlType = contentVal.toObject().take("controlType").toString();
            TemporaryParameter::gestance()->avPlaySetting.m_avUrl = contentVal.toObject().take("avUrl").toString();
            //qDebug()<<"avType =="<<avType<<"startTime =="<<startTime<<"controlType =="<<controlType<<"avUrl =="<<avUrl;
            // emit sigAvUrl(avType,startTime ,controlType ,avUrl );//.replace("\\","=")
        }
        else if(domain == "control" && command == "zoomInOut")
        {
            offsetX = contentVal.toObject().take("offsetX").toString().toDouble();
            offsetY = contentVal.toObject().take("offsetY").toString().toDouble();
            zoomRate = contentVal.toObject().take("zoomRate").toString().toDouble();

            //重设 该页的滚动条位置
            m_pages[m_currentCourse][m_currentPage].offSetX = offsetX;
            m_pages[m_currentCourse][m_currentPage].offSetY = offsetY;
            m_pages[m_currentCourse][m_currentPage].zoomRate = zoomRate;

        }
        else if(domain == "draw" && command == "question" )
        {
            stopOrBeginAnswerQuestonData = contentVal;

        }
        else if(domain == "draw" && command == "stopQuestion" )
        {
            stopOrBeginAnswerQuestonData = "";
        }
        else if(domain == "control" && command == "openCorrect" )
        {
            correctViewIsOpen = true;
            openCorrectData = contentVal;
            //  emit sigOpenCorrect(contentVal,false);
        }
        else if(domain == "control" && command == "correct" )
        {
            correctViewIsOpen = true;
            emit sigCorrect(contentVal);
        }
        else if(domain == "control" && command == "closeCorrect" )
        {
            correctViewIsOpen = false;
            openCorrectData = contentVal;
            emit sigCloseCorrect(contentVal);
        }
        else if(domain == "draw" && command == "questionAnswer" )
        {
            stopOrBeginAnswerQuestonData = "";
        }
    }
    else
    {

    }
}

void SocketHandler::clearRecord()
{
    if(!m_isInit)
    {
        m_pages.clear();
        m_pageSave.clear();
        TemporaryParameter::gestance()->m_pageSave.clear();
        QList<MessageModel> list;

#ifdef USE_OSS_AUTHENTICATION
        list.append(MessageModel(0, "", 1.0, 1.0, currentCourwareType, 0));
#else
        list.append(MessageModel(0, "", 1.0, 1.0, currentCourwareType));
#endif
        m_pages.insert("DEFAULT", list);
        m_currentPage = 0;
        m_currentCourse = "DEFAULT";
        //画一页
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);

#ifdef USE_OSS_AUTHENTICATION
        model.bgimg = checkOssSign(model.bgimg);
#endif

        emit sigDrawPage(model);
        //第一次开课默认开启 A通道的视频
        TemporaryParameter::gestance()->m_supplier = "1";
        TemporaryParameter::gestance()->m_videoType = "1";
        //  emit sigEnterOrSync(61); //改变频道跟音频 频道
    }
    m_isInit = true;
    TemporaryParameter::gestance()->m_isAlreadyClass = m_isInit;

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
    delete m_socket;
    delete m_sendMsgTask;
}


//网络撤销
void SocketHandler::undo()
{
    QString s("{\"domain\":\"draw\",\"command\":\"undo\",\"content\":{\"pageIndex\":\"" + QString::number(m_currentPage, 10) + "\"}}");
    sendLocalMessage(s, true, true);
}

//增加某一页
void SocketHandler::addPage()
{
    QString s("{\"domain\":\"page\",\"command\":\"insert\",\"content\":{\"page\":\"" + QString::number(m_currentPage, 10) + "\"}}");
    sendLocalMessage(s, true, true);
}
//删除某一页
void SocketHandler::deletePage()
{
    MessageModel model = m_pages[m_currentCourse][m_currentPage];
    if(model.isCourware)
    {
        emit sigEnterOrSync(12);
        return;
    }
    QString s("{\"domain\":\"page\",\"command\":\"delete\",\"content\":{\"page\":\"" + QString::number(m_currentPage, 10) + "\"}}");
    sendLocalMessage(s, true, true);
}

//到某一页
void SocketHandler::goPage(int pageIndex)
{
    qDebug() << "SocketHandler::goPage(" << pageIndex << TemporaryParameter::gestance()->m_isStartClass << m_pages[m_currentCourse].size();
    if( !TemporaryParameter::gestance()->m_isStartClass)
    {
        if (pageIndex < 0 || pageIndex > m_pages[m_currentCourse].size() - 1)
        {
            return;
        }
        MessageModel model = m_pages[m_currentCourse][pageIndex];
        model.setPage(m_pages[m_currentCourse].size(), pageIndex);
        m_currentPage = pageIndex;

        if(currentCourwareType == 2)
        {
            QJsonObject tobj = currentColumnContent.toObject();
            tobj.take("pageIndex");
            tobj.insert("pageIndex", QString::number(pageIndex));
            currentColumnContent = tobj;

            //更改modle
            model = resetMessageModel(model);
        }

#ifdef USE_OSS_AUTHENTICATION
        model.bgimg = checkOssSign(model.bgimg);
#endif

        emit sigDrawPage(model);
        return;
    }
    if (pageIndex < 0 || pageIndex > m_pages[m_currentCourse].size() - 1)
    {
        return;
    }
    QString s("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number(pageIndex, 10) + "\"}}");
    // qDebug()<<"aaaa  ==="<<s;
    if(currentCourwareType == 2)
    {
        QJsonObject tobj = currentColumnContent.toObject();
        tobj.take("pageIndex");
        tobj.insert("pageIndex", QString::number(pageIndex));
        currentColumnContent = tobj;
    }
    sendLocalMessage(s, true, true);
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


void SocketHandler::autoChangeIp()
{
    qDebug() << "current ip " << StudentData::gestance()->m_address << StudentData::gestance()->m_port << StudentData::gestance()->m_isTcpProtocol;

    //    if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size())
    //    {
    //        m_socket->resetDisConnect(!StudentData::gestance()->m_isTcpProtocol);
    //    }else
    //    {
    //        m_socket->resetDisConnect(StudentData::gestance()->m_isTcpProtocol);
    //    }
    //m_socket->resetDisConnect(StudentData::gestance()->m_isTcpProtocol);
    // m_sendMsgTask->stop();
    //    QEventLoop loop;
    //    qDebug()<<"qqqqqqqqqqqqqqqqqqqqqqqqqqqq";
    //    QTimer::singleShot(5000, &loop, SLOT(quit()));
    //    loop.exec();
    //    qDebug()<<"qqqqqqqqqqqqqqqqqqqqqqqqqqqq1";
    //判断是否存在优选ip
    if( TemporaryParameter::gestance()->goodIpList.size() > 0 )
    {
        //判断是否所有的ip都被切换过 tcp 模式  udp模式
        //
        //判断当前Ip是不是已经被连接过
        int tempHasConnect = -1;
        for(int a = 0; a < TemporaryParameter::gestance()->goodIpList.size(); a++ )
        {
            QVariantMap tempMap = TemporaryParameter::gestance()->goodIpList.at(a).toMap();
            if(StudentData::gestance()->m_address == tempMap["ip"].toString())
            {
                tempHasConnect = a;//获取已经被链接的Ip位置
                qDebug() << QStringLiteral("当前被链接Ip位置") << tempHasConnect;
                break;
            }
        }

        if(tempHasConnect == -1 )
        {
            //没有被连接过
            StudentData::gestance()->m_address = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["ip"].toString();
            StudentData::gestance()->m_port = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["port"].toInt();
            StudentData::gestance()->m_udpPort = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["udpPort"].toInt();

        }
        else
        {
            //被连接过位置的下一个 或第一个

            if(tempHasConnect + 1 <= TemporaryParameter::gestance()->goodIpList.size() - 1)
            {
                qDebug() << "1111111111111111111111" << tempHasConnect << TemporaryParameter::gestance()->goodIpList.size();
                StudentData::gestance()->m_address = TemporaryParameter::gestance()->goodIpList.at(tempHasConnect + 1).toMap()["ip"].toString();
                StudentData::gestance()->m_port = TemporaryParameter::gestance()->goodIpList.at(tempHasConnect + 1).toMap()["port"].toInt();
                StudentData::gestance()->m_udpPort = TemporaryParameter::gestance()->goodIpList.at(tempHasConnect + 1).toMap()["udpPort"].toInt();
            }
            else
            {
                qDebug() << "222222222222222222";
                StudentData::gestance()->m_address = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["ip"].toString();
                StudentData::gestance()->m_port = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["port"].toInt();
                StudentData::gestance()->m_udpPort = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["udpPort"].toInt();

            }
        }
        //切换ip
        qDebug() << QStringLiteral("自动切换Iping ~~~~~~~~~~~  ") << currentAutoChangeIpTimes << StudentData::gestance()->m_address << StudentData::gestance()->m_port;;

        //tcp udp 全部切换完毕之后 还掉线就退出
        if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size() * 2)
        {
            qDebug() << QStringLiteral("全部切换完毕 掉线退出~~~~~~~~~~~  ");
            autoChangeIpResult("autoChangeIpFail");
            return;
        }
        if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size() )
        {
            qDebug() << QStringLiteral("切换一圈之后切换协议模式~~~~~~~~~~~  ") << StudentData::gestance()->m_isTcpProtocol;

            StudentData::gestance()->m_isTcpProtocol = !StudentData::gestance()->m_isTcpProtocol;;
        }
        ++currentAutoChangeIpTimes;
        onChangeOldIpToNew();

        //切换一圈之后切换协议模式


    }
    else
    {
        qDebug() << QStringLiteral("优选Ip列表为空 ~~~~~~~~~~~~  ");
        isAutoChangeIping = false;//重置ip切换标示
        autoChangeIpResult("autoChangeIpFail");//
    }
}

void SocketHandler::justChangeIp(bool isSuccess)
{
    if(TemporaryParameter::gestance()->m_isFinishClass)
    {
        return;
    }
    qDebug() << "justChangeIp(bool isSuccess)" << isSuccess << isAutoChangeIping << isDisconnectBySelf;
    //判断掉线次数 是否满足自动切换ip条件
    if(isSuccess == false)
    {
        qDebug() << QStringLiteral("掉线重连判断ing");
        if(!isAutoChangeIping)//正在切换的状态下 不在从发
        {
            //记录掉线次数 3次掉线自动切换ip
            ++currentReloginTimes;

            if(currentReloginTimes >= 3)
            {
                qDebug() << QStringLiteral("3次掉线 ~~~~~~11111~~~~~  ");
                isAutoChangeIping = true;//正在自动切换ip
                //显示网络差界面
                autoChangeIpResult("showAutoChangeIpview");
                //切换服务器
                TemporaryParameter::gestance()->enterRoomStatus = "C";
                autoChangeIp();
                //重置掉线次数
                currentReloginTimes = 0;
            }
        }

    }

    //判断是否是自动ip切换
    if(isAutoChangeIping)
    {
        //          if(isDisconnectBySelf == true) //过滤掉 主动断开时 主动发的 掉线信号
        //          {
        //              qDebug()<<QStringLiteral("过滤掉主动断开信号")<<isSuccess;
        //              isDisconnectBySelf = false;
        //              return;
        //          }
        qDebug() << QStringLiteral("掉线自动重连1") << isSuccess;
        isAutoChangeIping = false;//重置ip切换标示
        if(isSuccess)
        {
            //切换成功
            autoChangeIpResult("autoChangeIpSuccess");
        }
        else
        {
            //autoChangeIpResult("autoChangeIpFail");
        }
        isDisconnectBySelf = true;
        qDebug() << QStringLiteral("掉线自动重连2") << isSuccess;
        return;
    }


    //判断是否切换到 http 协议
    if(( StudentData::gestance()->m_currentServerLost >= 5 || StudentData::gestance()->m_currentServerDelay > 50  ||  currentReloginTimes == 2 ) && TemporaryParameter::gestance()->m_isStartClass == true)
    {
        currentReloginTimes = 0;//避免 循环切换http
        this->stopSendMsg();
        m_response = false;
        //切换到 Http模式
        //m_socket->chageToHttpProtocol(m_lastRecvNum.toInt(), m_sendMsgNum);
        //处理Tcp Udp没有发送完的 消息

        //发送记录到的 最后一条消息
        //m_socket->sendMsg(m_lastSendMsg);
        //        //发送没处理的消息
        //        for(int i = 0; i <m_sendMsgs.size(); i++)
        //        {
        //            m_sendMsgNum ++ ;
        //            m_lastSendMsg = QString::number(m_sendMsgNum,10) + "#" + m_sendMsgs.at(i) ;
        //            m_socket->sendMsg(m_lastSendMsg);
        //        }
    }
}

void SocketHandler::socketPrepareSlot(bool status)
{
    if (!status) return;

    cleanMessageQue();

    m_bCanSend = true;

    QString enterRoomMessage = enterRoomReqMsgTemplate();
    joinMessageToQue(enterRoomMessage);
}

void SocketHandler::restGoodIpList()
{
    //重设优化ip列表
    int tempHasConnect = -1;
    for(int a = 0; a < TemporaryParameter::gestance()->goodIpList.size(); a++ )
    {
        QVariantMap tempMap = TemporaryParameter::gestance()->goodIpList.at(a).toMap();
        if(StudentData::gestance()->m_address == tempMap["ip"].toString())
        {
            tempHasConnect = a;//获取已经被链接的Ip位置
            qDebug() << QStringLiteral("重设优化ip列表") << tempHasConnect;
            break;
        }
    }

    if(tempHasConnect == -1)
    {
        //不包含 默认ip
        QVariantMap tempMap ;
        tempMap.insert("port", QString::number(StudentData::gestance()->m_port));
        tempMap.insert("udpPort", QString::number(StudentData::gestance()->m_udpPort));
        tempMap.insert("ip", StudentData::gestance()->m_address);
        TemporaryParameter::gestance()->goodIpList.append(tempMap);
        qDebug() << "restGoodIpList() fasle ";
    }
    else
    {
        qDebug() << "restGoodIpList() has has ";
        TemporaryParameter::gestance()->goodIpList.swap(tempHasConnect, TemporaryParameter::gestance()->goodIpList.size() - 1);
    }

    qDebug() << "restGoodIpList()" << TemporaryParameter::gestance()->goodIpList;

}

void SocketHandler::synchronousForNewHomeWork(QString &msg)
{


}


QJsonObject SocketHandler::getCurrentItemBaseImage(QJsonObject dataObjecte, int pageIndex)
{
    return getAllLessonCoursewareList->getCurrentItemBaseImage(dataObjecte, pageIndex);
}


MessageModel SocketHandler::resetMessageModel(MessageModel model)
{
    //更改modle
    // 当课件为老课件 或者 新课件的第一页 插入的页 此时  model.currentCoursewareType = 1 否则为 2
    // 课件类型为 2 的时候 查询此课件是否存在 baseimage  存在就按照 老课件逻辑走 不存在就 发送题型的内容来显示
    if(model.currentCoursewareType != 1 )
    {
        qDebug() << "SocketHandler::resetMessageModel model.currentCoursewareType " << model.currentCoursewareType;
        //更改modle
        //根据在新讲义里的 index 进行 查询 而不是课件当前的 index
        QJsonObject imageUrl = getCurrentItemBaseImage(currentColumnContent.toObject(), model.pageIndex);
        if(imageUrl.value("imageUrl").toString() == "")
        {
            qDebug() << " imageUrl null";
            QJsonObject tobj = currentColumnContent.toObject();
            tobj.take("pageIndex");
            tobj.insert("pageIndex", QString::number(model.pageIndex));
            currentColumnContent = tobj;
            emit sigShowNewCoursewareItem(currentColumnContent);
        }
        else
        {
            qDebug() << "command == 11column imageUrl not null" << imageUrl.value("imageUrl").toString();
            model.bgimg = imageUrl.value("imageUrl").toString();
            model.width = imageUrl.value("width").toInt();
            if(imageUrl.value("width").isString())
            {
                model.width = imageUrl.value("width").toString().toInt();
            }
            model.height = imageUrl.value("height").toInt();
            if(imageUrl.value("height").isString())
            {
                model.height = imageUrl.value("height").toString().toInt();
            }
        }
    }
    return model;
}

#ifdef USE_OSS_AUTHENTICATION
//OSS过期重新签名URL
QString SocketHandler::getOssSignUrl(QString key)
{
    QVariantMap  reqParm;
    reqParm.insert("key", key);
    reqParm.insert("expiredTime", 1800 * 1000);
    reqParm.insert("token", YMUserBaseInformation::token);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString httpUrl = StudentData::gestance()->apiUrl;
    QString url = "https://" + httpUrl + "/api/oss/make/sign"; //环境切换要注意更改
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "***********allDataObj********" << url << reqParm;
    qDebug() << "=======aaa=========" << allDataObj << key;

    if(allDataObj.value("result").toString().toLower() == "success")
    {
        QString url = allDataObj.value("data").toString();
        qDebug() << "*********url********" << url;
        return url;
    }
    else
    {
        qDebug() << "SocketHandler::getOssSignUrl" << allDataObj << __LINE__;
    }

    return "";
}

QString SocketHandler::checkOssSign(QString imgUrl)
{
    //重新验签处理返回URL
    if(imgUrl != "" && StudentData::gestance()->coursewareSignOff)
    {
        long current_second = QDateTime::currentDateTime().toTime_t();
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        qDebug() << "==ssssssssss==" << current_second - model.expiredTime << current_second << model.expiredTime;
        if(model.expiredTime == 0 || current_second - model.expiredTime >= 1800)//30分钟该页重新请求一次验签
        {
            QString oldImgUrl = model.bgimg;
            int indexOf = oldImgUrl.indexOf(".com");
            int midOf = oldImgUrl.indexOf("?");
            QString key = oldImgUrl.mid(indexOf + 4, midOf - indexOf - 4);
            QString newImgUrl = getOssSignUrl(key);

            qDebug() << "=====drawPage::key=====" << imgUrl << newImgUrl;
            if(newImgUrl == "")
            {
                return imgUrl;
            }

            m_pages[m_currentCourse][m_currentPage].expiredTime = current_second;
            m_pages[m_currentCourse][m_currentPage].bgimg = newImgUrl;
            return newImgUrl;
        }
    }
    return imgUrl;
}
#endif //#ifdef USE_OSS_AUTHENTICATION
