#include "sockethandler.h"
#include <QtNetwork>

#include <QTimer>
#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>
#include "debuglog.h"

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
    m_sendAudioQualityTask = new QTimer(this);
    connect(m_sendAudioQualityTask, SIGNAL(timeout()), this, SLOT(sendAudioQuality()));

    m_netTimer = new QTimer();
    m_netTimer->setInterval(60000);
    connect(m_netTimer, SIGNAL(timeout()), this, SLOT(interNetworkChange()));
    m_netTimer->start();

    restGoodIpList();

    m_socketOutTimeTimer = new QTimer();
    m_socketOutTimeTimer->setInterval(30000);
    m_socketOutTimeTimer->setSingleShot(true);
    connect(m_socketOutTimeTimer, SIGNAL(timeout()), this, SLOT(socketTimeOut()));
    m_socketOutTimeTimer->start();

    m_socket = new YMTCPSocket(this);
    connect(m_socket, &YMTCPSocket::readMsg, this, &SocketHandler::readMessage);
    //新的http协议
    connect(m_socket, SIGNAL(httpTimeOut(QString)), this, SIGNAL(autoChangeIpResult(QString)));
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SIGNAL(justNetConnect(bool)));
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SIGNAL(justChangeIp(bool)));

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
                             "{\"qqvoiceVersion\":\"6.0.0\",\"appVersion\":\"%1\",\"recordVersion\":\"3.10.19\","
                             "\"MD5Pwd\":\"%2\",\"agoraVersion\":\"1.8\",\"userId\":\"%3\","
                             "\"userType\":\"student_%4\",\"sysInfo\":\"%5\",\"phone\":\"%6\",\"lessonId\":\"%7\","
                             "\"deviceInfo\":\"%8\",\"lat\":\"%9\",\"lng\":\"%10\",\"netType\":\"%11\",\"lessonType\":\"%12\",\"appSource\":\"YIMI\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_appVersion).arg(StudentData::gestance()->m_mD5Pwd).arg(StudentData::gestance()-> m_selfStudent.m_studentId).arg(StudentData::gestance()-> m_selfStudent.m_studentType).arg(StudentData::gestance()->m_sysInfo)
            .arg(StudentData::gestance()->m_phone).arg(StudentData::gestance()->m_lessonId).arg(StudentData::gestance()->m_deviceInfo).arg(StudentData::gestance()->m_lat).arg(StudentData::gestance()->m_lng).arg(netType).arg(StudentData::gestance()->m_lessonType);

    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
    //m_lastSendMsg = m_enterRoomMsg;
    //sendMessage(lastSendMsg);
    m_lastHBTime.start();
    startSendMsg();
    startSendAudioQuality();

    //再次提交答案 for(老师端有时候第一次无法成功生成答案) 暂时不用了
    anserSubmitTimer = new QTimer(this);
    //anserSubmitTimer->setSingleShot(true);
    anserSubmitTimer->setInterval(15000);
    connect(anserSubmitTimer, SIGNAL(timeout()), this, SLOT(reSubmitAnswer()));

}

void SocketHandler::reSubmitAnswer()
{
    anserSubmitTimer->stop();//停掉计时器
    sendMessage(currentAnswerSumitData);
}

//发送本地消息
void SocketHandler::sendLocalMessage(QString cmd, bool append, bool drawPage)
{
    qDebug() << "SocketHandler::sendLocalMessage" << cmd << m_isInit << append;

    excuteMsg(cmd, StudentData::gestance()->m_selfStudent.m_studentId);

    // if(cmd.contains("questionAnswer")){append = false;}

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
    if(m_isInit)
    {
        if(append)
        {
            QMutexLocker locker(&m_sendMsgsMutex);
            m_sendMsgs.append(cmd);
        }
        else
        {

            sendMessage(cmd);
        }
    }
}

int SocketHandler::getCurrentPage(QString docId)
{
    int cuttents = 1;
    cuttents = m_pageSave.value(docId, 1);
    return cuttents;
}

void SocketHandler::readMessage(QString line)
{
    //    qDebug() << "SocketHandler::readMessageaaa" << line;

    //判断是否停掉重新提交答案的定时器
    if(line.contains("autoPicture") && !line.contains("synchronize") )
    {
        anserSubmitTimer->stop();
    }

    //解析消息
    int firstS = line.indexOf('#', 0);
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
    }

    TemporaryParameter::gestance()->avPlaySetting.currentTime = line.mid(line.indexOf(":", 0) + 1, line.indexOf("}", 0) - 1 - line.indexOf(":", 0)).toLongLong();

    //解析命令
    qDebug() << "==SocketHandler::readMessage==" << recvNum << fromUser << msgJson;
    parseMsg(recvNum, fromUser, msgJson);
}

void SocketHandler::sendMessage(QString msg)
{
    if(msg.contains("questionAnswer"))
    {
        //anserSubmitTimer->start();
        currentAnswerSumitData = msg;
    }

    m_socket->sendMsg(msg);
}

void SocketHandler::sendMessage()
{
    checkTimeOut();
    if (m_response && m_canSend && m_sendMsgs.size() > 0)
    {
        QMutexLocker locker(&m_sendMsgsMutex);
        m_lastHBTime.restart();
        m_response = false;
        m_sendMsgNum++;
        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#" + m_sendMsgs.first() ;
        m_sendMsgs.pop_front();
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
                QString tempString = QString("0#SYSTEM{\"command\":\"audioQuality\",\"content\":{\"userId\":\"%1\",\"delay\":\"%2\",\"lost\":\"%3\",\"quality\":\"%4\",\"bitrate\":\"%5\",\"supplier\":\"%6\",\"videoType\":\"%7\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_selfStudent.m_studentId).arg(QString(it.value()).split(",").at(1)).arg(QString(it.value()).split(",").at(2)).arg(QString(it.value()).split(",").at(0)).arg(TemporaryParameter::gestance()->bitRate).arg(TemporaryParameter::gestance()->m_supplier).arg(TemporaryParameter::gestance()->m_videoType);
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
    QEventLoop loop;
    QTimer::singleShot(200, &loop, SLOT(quit()));
    loop.exec();

    Q_UNUSED(reconnect);

    if (NULL != m_socket)
    {
        m_socket->destroyMarsService();
    }
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
                    m_lastHBTime.restart();
                    m_response = false;
                    m_socket->sendMsg(m_enterRoomMsg);
                    //ggggggggggggggg
                }
                else if (command == "enterRoom")
                {
                    m_hasConnectServer = true;
                    StudentData::gestance()->m_hasConnectServer = true;

                    QString userId = contentValue.toObject().take("userId").toString();

                    StudentData::gestance()->m_userTypeInfo.insert(userId, contentValue.toObject().value("userType").toString());

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

                        //信息上报
                        QJsonObject obj;
                        obj.insert("result","1");
                        obj.insert("errMsg","");
                        YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);
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
                            if(ids == StudentData::gestance()->m_teacher.m_teacherId_OnLine)
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

                    //qDebug() << "SocketHandler::parseMsg22" << StudentData::gestance()->m_teacher.m_teacherId_OnLine << TemporaryParameter::gestance()->m_astudentIsOnline << __LINE__;
                    m_canSend = true;
                }
                else if(command == "exitRoom")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    StudentData::gestance()->removeOnlineId(userId);
                    qDebug() << "SocketHandler::parseMsg22" << StudentData::gestance()->m_teacher.m_teacherId_OnLine << userId << __LINE__;
                    if(StudentData::gestance()->m_teacher.m_teacherId_OnLine == userId )
                    {
                        TemporaryParameter::gestance()->m_isStartClass = false;
                    }
                    else
                    {
                        emit sigExitRoomIds(userId);
                        return;
                    }

                    TemporaryParameter::gestance()->avPlaySetting.m_controlType = "stop";
                    emit sigAvUrl( TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );
                    if(!hasReciveFinishedClass)
                    {
                        qDebug() << "SocketHandler::parseMsg22" << StudentData::gestance()->m_teacher.m_teacherId_OnLine << userId << __LINE__;
                        emit sigExitRoomIds(userId);
                    }

                    //qDebug() << "SocketHandler::parseMsg22" << StudentData::gestance()->m_teacher.m_teacherId_OnLine << userId << __LINE__;
                    emit sigEnterOrSync(4);
                }
                else if(command == "changeAudio")
                {
                    QString supplier = contentValue.toObject().take("supplier").toString();
                    QString videoType = contentValue.toObject().take("videoType").toString();

                    //信息上报
                    QJsonObject changeChannelObj;
                    changeChannelObj.insert("currentChannel",TemporaryParameter::gestance()->m_supplier);//agora/tencent/netease
                    changeChannelObj.insert("doChangeChannel",supplier);
                    changeChannelObj.insert("currentAudioType",TemporaryParameter::gestance()->m_videoType);//1音频/2视频
                    changeChannelObj.insert("actionType","passive");
                    YMQosManager::gestance()->addBePushedMsg("changeAuidoChannel", changeChannelObj);
                    YMQosManager::gestance()->setChangeChannelValue(true);

                    TemporaryParameter::gestance()->m_tempSupplier = TemporaryParameter::gestance()->m_supplier;
                    TemporaryParameter::gestance()->m_supplier = supplier;
                    TemporaryParameter::gestance()->m_videoType = videoType;
                    emit sigEnterOrSync(61); //改变频道跟音频 频道
                }
                else if(command == "enterFailed")
                {
                    emit sigEnterOrSync(0);
                    //信息上报
                    QJsonObject obj;
                    obj.insert("result","0");
                    obj.insert("errMsg",contentValue.toObject().take("reason").toString());
                    YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);
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
                    qDebug() << "TemporaryParameter::gestance()->m_supplier" << TemporaryParameter::gestance()->m_supplier << TemporaryParameter::gestance()->m_videoType << totalTime;
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

                    //================================== >>>
                    //老师异常掉线以后, CC/CR 开始上课
                    qDebug() << "server startClass" << fromUser << StudentData::gestance()->m_teacher.m_teacherId << jsonObj << __LINE__ ;
                    if(fromUser.trimmed().length() > 0 && StudentData::gestance()->m_teacher.m_teacherId != fromUser)
                    {
                        qDebug() << "server startClass" << __LINE__;
                        StudentData::gestance()->m_teacher.m_teacherId = fromUser;
                        emit sigEnterOrSync(1101); //上麦以后, 更新老师视频窗口绑定的UserID
                    }

                    StudentData::gestance()->m_teacher.m_teacherId_OnLine = fromUser;
                    StudentData::gestance()->m_dataInsertion = true;
                    StudentData::gestance()->insertIntoOnlineId(fromUser);
                    emit sigEnterOrSync(4); //判断老师是否在线, 从而影响到: 学生 + 老师摄像头视频窗口, 是否遮盖的状态

                    TemporaryParameter::gestance()->m_teacherIsOnline = true;
                    TemporaryParameter::gestance()->m_astudentIsOnline = true;
                    //<<< ==================================
                }
                else if(command == "disconnect")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    qDebug() << "=============disconnect==============" << userId << StudentData::gestance()->m_teacher.m_teacherId_OnLine << __LINE__;
                    if(userId != StudentData::gestance()->m_teacher.m_teacherId_OnLine) //如果当前掉线的User ID, 不是当前正在上课的老师, 则return
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
                            // 判断除自己之外的成员(教师、旁听)的腾讯SDK版本，只要其中有一个是1.8.2，则使用老版本SDK
                            if(userId != StudentData::gestance()->m_selfStudent.m_studentId)
                            {
                                QString qqvoiceVersion = values.toObject().take("qqvoiceVersion").toString();
                                if(qqvoiceVersion == "1.8.2")
                                {
                                    TemporaryParameter::gestance()->qqVoiceVersion = qqvoiceVersion;
                                }
                            }

                            TemporaryParameter::gestance()->deviceVersion[userId] = appVersion;//版本号
                            TemporaryParameter::gestance()->deviceSysInfo[userId] = sysInfo;//设备信息
                            TemporaryParameter::gestance()->m_phoneType[userId] = sysInfo;
                            QString userType = values.toObject().take("userType").toString();

                            StudentData::gestance()->m_userTypeInfo.insert(userId,userType);

                            if("teacher" == userType)
                            {
                                //判断是否兼容16:9
                                QStringList versionList = appVersion.split(".");
                                QString tVersion = "0";
                                //获取tVersion
                                if(versionList.size() >= 3 )
                                {
                                    //拼字符串
                                    if(versionList.size() == 3)//ios
                                    {
                                        QString lastString = versionList.at(2);
                                        lastString = lastString.mid(0,lastString.size() - 3);
                                        if(lastString.size() == 1)
                                        {
                                            lastString = lastString.insert(0,"0");
                                        }

                                        QString tempS = "";
                                        for(int a = 0; a < versionList.size() ; a++)
                                        {
                                            tempS = versionList.at(a);
                                            if(tempS.size() == 1)
                                            {
                                                tempS = tempS.insert(0,"0");
                                            }
                                            tVersion.append(tempS);
                                            if(a == 1)
                                            {
                                                tVersion.append(lastString);
                                                break;
                                            }
                                        }
                                    }else
                                    {
                                        for(int a = 0; a < versionList.size() ; a++)
                                        {

                                            if(a == 2)
                                            {
                                                QString lastString = versionList.at(2);
                                                if(lastString.size() == 1)
                                                {
                                                    lastString = lastString.insert(0,"0");
                                                }
                                                tVersion.append(lastString);
                                                break;
                                            }else
                                            {
                                                tVersion.append(versionList.at(a));
                                            }
                                        }
                                    }
                                }

                                if(StudentData::gestance()->tempRecordVersion != "")//已经开过课
                                {
                                    if(StudentData::gestance()->tempRecordVersion == oldRecordVersion)
                                    {
                                        emit sigCouldUseNewBoard(false);
                                        StudentData::gestance()->setCouldUseNewBoard(false);
                                    }else
                                    {
                                        emit sigCouldUseNewBoard(true);
                                        StudentData::gestance()->setCouldUseNewBoard(true);
                                        //判断老师是否更换过版本 如果换到低版本 提示版本过低
                                        if(tVersion.toInt() < lowestNewBoardCode)
                                        {
                                            sigTeaChangeVersionToOld();
                                        }
                                    }
                                }else if(StudentData::gestance()->tempRecordVersion == ""  )
                                {
                                    //没上过课根据老师当前的版本是否支持16:9来判断
                                    if(tVersion.toInt() >= lowestNewBoardCode)
                                    {
                                        emit sigCouldUseNewBoard(true);//支持16:9新模式
                                        StudentData::gestance()->setCouldUseNewBoard(true);
                                        StudentData::gestance()->tempRecordVersion = newRecorderVersion;
                                    }else
                                    {
                                        StudentData::gestance()->setCouldUseNewBoard(false);
                                        emit sigCouldUseNewBoard(false);
                                        StudentData::gestance()->tempRecordVersion = oldRecordVersion;
                                    }
                                }
                            }

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
                }else if(command == "c2cDelay")
                {
                    QJsonObject obj;
                    obj.insert("socketIp",StudentData::gestance()->m_address);
                    obj.insert("tea_s",contentValue.toObject().value("tea_s"));
                    obj.insert("server_s",contentValue.toObject().value("server_s"));
                    qint64 timeDifference = YMQosManager::gestance()->getTimeDifference();
                    obj.insert("stu",QString::number(QDateTime::currentMSecsSinceEpoch() + timeDifference));
                    YMQosManager::gestance()->addBePushedMsg("c2cDelay",obj);

                    //发消息给服务端
                    sendC2cDelay(contentValue.toObject().value("tea_s").toString().toLongLong(),contentValue.toObject().value("server_s").toString().toLongLong(),timeDifference);
                }
                else if(command == "currentVideoSpanResponse")// 腾讯V2新增
                {
                    emit sigVideoSpan(contentValue.toObject().take("videoSpan").toString());
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
                    qDebug() << "m_currentCourse == domain == page" << __LINE__;
                    return;
                }

                excuteMsg(msg, fromUser);
                qDebug() << "m_currentCourse == domain == page" << stopOrBeginAnswerQuestonData << msg.contains("goto") << currentIsAnswing << m_currentPage << __LINE__;
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
                else if(command == "smResp") //试听课, 上麦授权结果
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    StudentData::gestance()->m_teacher.m_teacherId_OnLine = userId;

                    qDebug() << "stu_smResp" << __LINE__ << userId << StudentData::gestance()->m_teacher.m_teacherId;
                    if(userId.trimmed().length() > 0 && StudentData::gestance()->m_teacher.m_teacherId != userId)
                    {
                        qDebug() << "stu_smResp" << __LINE__;
                        StudentData::gestance()->m_teacher.m_teacherId = userId;
                        emit sigEnterOrSync(1101); //上麦以后, 更新老师视频窗口绑定的UserID
                    }

                    StudentData::gestance()->m_teacher.m_teacherId_OnLine = userId;
                    StudentData::gestance()->m_dataInsertion = true;
                    StudentData::gestance()->insertIntoOnlineId(userId);
                    emit sigEnterOrSync(4); //判断老师是否在线, 从而影响到: 学生 + 老师摄像头视频窗口, 是否遮盖的状态

                    TemporaryParameter::gestance()->m_teacherIsOnline = true;
                    TemporaryParameter::gestance()->m_astudentIsOnline = true;
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
                    //防止因为越界访问, 导致程序崩溃
                    if(m_currentPage < 0) return;
                    if(m_currentPage > (m_pages[m_currentCourse].size() - 1)) return;

                    zoomRate = contentValue.toObject().take("zoomRate").toString().toDouble();
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

void SocketHandler::startSendMsg()
{
    m_sendMsgTask->start(50);
}

void SocketHandler::stopSendMsg()
{
    if (m_sendMsgTask->isActive())
        m_sendMsgTask->stop();
}

void SocketHandler::checkTimeOut()
{
    if (!m_response && m_lastHBTime.elapsed() > 3000)
    {
        m_lastHBTime.restart();
        m_socket->sendMsg(m_lastSendMsg);
    }

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
        else if (domain == "draw" && command == "pictureReport")
        {
            QString tempNextKey = m_currentCourse;
            if(currentCourwareType == 2)
            {
                tempNextKey = currentColumnId;
            }

            QJsonArray imgArry = contentVal.toObject().take("urls").toArray();

            for(int a = 0; a < imgArry.size(); a++)
            {
                QString url = imgArry.at(a).toObject().take("imageUrl").toString();
                double width = imgArry.at(a).toObject().take("width").toString().toDouble();
                double height = imgArry.at(a).toObject().take("height").toString().toDouble();
                if(a == 0)
                {
                    ++m_currentPage;
                }
#ifdef USE_OSS_AUTHENTICATION
                MessageModel model = MessageModel(0, url, width, height, 1, 0);
                model.beShowedAsLongImg = true;
                m_pages[m_currentCourse].insert(a + m_currentPage,model);
#else
                MessageModel model = MessageModel(0, url, width, height, 1);
                model.beShowedAsLongImg = true;
                m_pages[m_currentCourse].insert( a + m_currentPage, model);
#endif
            }
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
            //获取第一次开课时的录播版本号
            if(StudentData::gestance()->tempRecordVersion != "")
            {
                return;
            }
            QJsonObject contentObj = contentVal.toObject();
            StudentData::gestance()->tempRecordVersion = contentObj.value("recordVersion").toString();
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
    //信息上报
    QJsonObject socketJsonObj;
    socketJsonObj.insert("currentSocketIp",StudentData::gestance()->m_address);
    StudentData::gestance()->m_tempAddress = StudentData::gestance()->m_address;
    qDebug() << "current ip " << StudentData::gestance()->m_address << StudentData::gestance()->m_port << StudentData::gestance()->m_isTcpProtocol;

    //    if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size())
    //    {
    //        m_socket->resetDisConnect(!StudentData::gestance()->m_isTcpProtocol);
    //    }else
    //    {
    //        m_socket->resetDisConnect(StudentData::gestance()->m_isTcpProtocol);
    //    }
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
        if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size())
        {
            qDebug() << QStringLiteral("全部切换完毕 掉线退出~~~~~~~~~~~  ");
            autoChangeIpResult("autoChangeIpFail");
            return;
        }

        ++currentAutoChangeIpTimes;
        socketJsonObj.insert("doChangeSocketIp",StudentData::gestance()->m_address);
        YMQosManager::gestance()->addBePushedMsg("changeSocketNetwork", socketJsonObj);
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
    //信息上报
    QJsonObject socketJsonObj;
    socketJsonObj.insert("currentSocketIp",StudentData::gestance()->m_address);

    if(TemporaryParameter::gestance()->m_isFinishClass)
    {
        socketJsonObj.insert("errMsg",QStringLiteral("正常退出"));
        YMQosManager::gestance()->addBePushedMsg("socketDisconnect", socketJsonObj);
        return;
    }
    qDebug() << "justChangeIp(bool isSuccess)" << isSuccess << isAutoChangeIping << isDisconnectBySelf;
    //判断掉线次数 是否满足自动切换ip条件
    if(isSuccess == false)
    {
        socketJsonObj.insert("errMsg",QStringLiteral("连接失败"));
        YMQosManager::gestance()->addBePushedMsg("socketDisconnect", socketJsonObj);
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

        //信息上报
        QJsonObject socketJsonObj;
        socketJsonObj.insert("beforeSocketIp",StudentData::gestance()->m_tempAddress);
        socketJsonObj.insert("currentSocketIp",StudentData::gestance()->m_address);
        if(isSuccess)
        {
            socketJsonObj.insert("result",1);
            socketJsonObj.insert("errMsg",QStringLiteral(""));
        }else
        {
            socketJsonObj.insert("result",0);
            socketJsonObj.insert("errMsg",QStringLiteral("连接失败"));
        }
        YMQosManager::gestance()->addBePushedMsg("changeSocketNetworkFinished", socketJsonObj);

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
    }
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

void SocketHandler::sendC2cDelay(long long tea_s,long long server_s,long long timeDifference)
{
    QString tempString = QString("0#SYSTEM{\"command\":\"c2cDelay\",\"content\":{\"tea_s\":\"%1\",\"server_s\":\"%2\",\"stu\":\"%3\"},\"domain\":\"system\"}").arg(tea_s).arg(server_s).arg(QDateTime::currentMSecsSinceEpoch() + timeDifference);
    sendMessage(tempString);
}

void SocketHandler::interNetworkChange()
{
    int types = 0;
    QString netTypeStr;
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
               netTypeStr = netInterface.name();//netInterface.hardwareAddress();
            }
            types++;
        }
    }

   netTypeStr.remove("#");
   netTypeStr.remove("\n");


    qDebug() << "====netTypeStr====" << netTypeStr;

    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }

    if(currentNetWorkType != netType)
    {
        //切换过网络之后再上报
        currentNetWorkType = netType;
        //信息上报
        QJsonObject networkJsonObj;
        networkJsonObj.insert("socketIp",StudentData::gestance()->m_address);
        YMQosManager::gestance()->addBePushedMsg("network", networkJsonObj);
    }
}

int SocketHandler::getCurrentCoursewarePage(QString planId, QString columnId)
{
    QString tempPlanId = planId + "yxt" + columnId;

    if(m_pageSave.contains(tempPlanId))
    {
        return m_pageSave.value(tempPlanId);
    }else
    {
        return 1;
    }
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

void SocketHandler::socketTimeOut()
{
    if(!m_hasConnectServer)
    {
        autoChangeIpResult("autoChangeIpFail");
        QJsonObject obj;
        obj.insert("result","0");
        obj.insert("server_ip",StudentData::gestance()->m_address);
        obj.insert("errMsg",QStringLiteral("socket连接超时"));

        YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);
    }
}
