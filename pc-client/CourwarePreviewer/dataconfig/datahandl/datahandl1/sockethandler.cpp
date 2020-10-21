#include "sockethandler.h"
#include <QtNetwork>

#include <QTimer>
#include <QMutexLocker>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>

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
{

    QList<MessageModel> list;
    list.append(MessageModel(0, "", 1.0, 1.0));
    m_pages.insert("DEFAULT", list);

    m_sendMsgTask = new QTimer(this);
    connect(m_sendMsgTask, SIGNAL(timeout()), this, SLOT(sendMessage()));
    m_sendAudioQualityTask = new QTimer(this);
    connect(m_sendAudioQualityTask, SIGNAL(timeout()), this, SLOT(sendAudioQuality()));


    m_socket = new YMTCPSocket(this);
    connect(m_socket, &YMTCPSocket::readMsg, this, &SocketHandler::readMessage);

    QString netTypeStr = TemporaryParameter::gestance()->m_netWorkMode;
    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("无线")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }

    m_enterRoomMsg = QString("1#SYSTEM{\"command\":\"enterRoom\",\"content\":"
                             "{\"qqvoiceVersion\":\"1.8.2\",\"appVersion\":\"%1\",\"recordVersion\":\"2.3.2\","
                             "\"MD5Pwd\":\"%2\",\"agoraVersion\":\"1.8\",\"userId\":\"%3\","
                             "\"userType\":\"%4\",\"sysInfo\":\"%5\",\"phone\":\"%6\",\"lessonId\":\"%7\","
                             "\"deviceInfo\":\"%8\",\"lat\":\"%9\",\"lng\":\"%10\",\"netType\":\"%11\",\"appSource\":\"YIMI\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_appVersion).arg(StudentData::gestance()->m_mD5Pwd).arg(StudentData::gestance()-> m_selfStudent.m_studentId).arg("teacher").arg(StudentData::gestance()->m_sysInfo)
                     .arg(StudentData::gestance()->m_phone).arg(StudentData::gestance()->m_lessonId).arg(StudentData::gestance()->m_deviceInfo).arg(StudentData::gestance()->m_lat).arg(StudentData::gestance()->m_lng).arg(netType);

    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
    m_lastSendMsg = m_enterRoomMsg;
    //sendMessage(lastSendMsg);
    m_lastHBTime.start();
    startSendMsg();
    startSendAudioQuality();
    m_socket->newConnect();
}

//发送本地消息
void SocketHandler::sendLocalMessage(QString cmd, bool append, bool drawPage)
{
    qDebug() << "SocketHandler::sendLocalMessage:" << cmd << append << drawPage;
    excuteMsg(cmd, StudentData::gestance()->m_selfStudent.m_studentId);

    if (drawPage)
    {

        //画一页
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
        emit sigDrawPage(model);
    }
    if(m_isInit)
    {

        if (append)
        {
            QMutexLocker locker(&m_sendMsgsMutex);
            m_sendMsgs.append(cmd);
            qDebug() << "SocketHandler::sendLocalMessage::" << append;
        }
        else
        {
            sendMessage(cmd);
            qDebug() << "SocketHandler::sendLocalMessage::" << append;
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
    //解析消息
    int firstS = line.indexOf('#', 0);
    int secondS = line.indexOf('#', firstS + 1);
    int firstM = line.indexOf(':', 0);
    QString recvNum = line.mid(0, firstS);
    QString fromUser = line.mid(firstS + 2, firstM - firstS - 2);
    QString msgJson = line.mid(secondS + 1);
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
    //解析命令
    qDebug() << "SocketHandler::readMessage:" << recvNum << fromUser << msgJson;
    parseMsg(recvNum, fromUser, msgJson);
}

void SocketHandler::sendMessage(QString msg)
{
    qDebug() << "=================";
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
        qDebug() << "SocketHandler::sendMessage::" << m_sendMsgs.size();
        sendMessage(m_lastSendMsg);
    }
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
                QString tempString = QString("0#SYSTEM{\"command\":\"audioQuality\",\"content\":{\"userId\":\"%1\",\"delay\":\"%2\",\"lost\":\"%3\",\"quality\":\"%4\"},\"domain\":\"system\"}").arg(it.key()).arg(QString(it.value()).split(",").at(1)).arg(QString(it.value()).split(",").at(2)).arg(QString(it.value()).split(",").at(0));
                sendMessage(tempString);
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
    if (!reconnect)
    {
        m_socket->disConnect();
        qDebug() << "SocketHandler::disconnectSocket";
    }
}

//解析处理消息
void SocketHandler::parseMsg(QString &num, QString &fromUser, QString &msg)
{
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
                    m_canSend = false;
                    m_lastSendMsg = m_enterRoomMsg;
                    m_lastHBTime.restart();
                    m_response = false;
                    m_socket->sendMsg(m_enterRoomMsg);
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
                        qDebug() << "userId>>>>>>" << userId;
                        //emit sigEnterOrSync(4);
                    }
                    else
                    {
                        StudentData::gestance()->m_dataInsertion = true;
                        StudentData::gestance()->insertIntoOnlineId(userId);
                        for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                        {
                            //qDebug() << "SocketHandler::parseMsg" << userId << StudentData::gestance()->m_student[i].m_studentId;
                            if(userId == StudentData::gestance()->m_student[i].m_studentId)
                            {
                                if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                                {
                                    m_isInit = true;
                                    TemporaryParameter::gestance()->m_isAlreadyClass = m_isInit;
                                    emit sigSendUserId(userId);
                                    emit sigEnterOrSync(3);//3
                                    qDebug() << "=============userId========" << userId;
                                    break;
                                }
                            }
                        }
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
                        excuteMsg(msgJson, uid);
                    }
                    if (contentValue.toObject().take("state").toString() == "complete")
                    {
                        m_sendMsgNum++;
                        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#SYSTEM{\"command\":\"onlineState\",\"domain\":\"system\"}";
                        m_response = false;
                        sendMessage(m_lastSendMsg);
                        m_includeSelfMsg = "0";


                        MessageModel model = m_pages[m_currentCourse][m_currentPage];
                        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
                        TemporaryParameter::gestance()->m_userBrushPermissionsId = m_userBrushPermissions;
                        emit sigAuthtrail(m_userBrushPermissions);
                        emit sigDrawPage(model);
                        emit sigEnterOrSync( 2 ) ;

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
                                emit sigSendUserId(ids);
                                qDebug() << "======teacher::Online=======";
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
                                        emit sigSendUserId(ids);
                                        qDebug() << "======m_astudentIsOnline=======" << ids;
                                    }
                                }
                            }
                        }
                        emit sigEnterOrSync(14);
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
                    emit sigExitRoomIds(userId);
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
                    QString supplieras = contentValue.toObject().take("supplier").toString();
                    QString videoTypeas = contentValue.toObject().take("videoType").toString();
                    TemporaryParameter::gestance()->m_supplier = supplieras;
                    TemporaryParameter::gestance()->m_videoType = videoTypeas;
                    TemporaryParameter::gestance()->m_isStartClass = true;
                    m_response = true;
                    emit sigStartClassTimeData(totalTime);

                    //第一次开课
                    clearRecord();

                }
                else if(command == "disconnect")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    emit sigDroppedRoomIds(userId);
                }
                else if(command == "deviceInfos")
                {
                    QJsonArray contentArray = contentValue.toArray();
                    if (contentArray.size() > 1)
                    {
                        foreach (QJsonValue values, contentArray)
                        {
                            QString sysInfo = values.toObject().take("sysInfo").toString();
                            QString userId = values.toObject().take("userId").toString();
                            TemporaryParameter::gestance()->m_phoneType[userId] = sysInfo;
                        }
                    }
                }
            }
            else if (domain == "draw")
            {
                excuteMsg(msg, fromUser);
                if (command != "trail" && command != "polygon" && command != "ellipse")
                {
                    //画一页
                    MessageModel model = m_pages[m_currentCourse][m_currentPage];
                    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
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
                excuteMsg(msg, fromUser);
                //      qDebug()<<"m_currentCourse =="<<m_currentCourse<<"m_currentPage =="<<m_currentPage;
                //画一页
                MessageModel model = m_pages[m_currentCourse][m_currentPage];
                model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
                emit sigDrawPage(model);
                QString auth = "0";
                if(TemporaryParameter::gestance()->m_userPagePermissions == "1")
                {
                    if(auth == "0")
                    {
                        TemporaryParameter::gestance()->m_userPagePermissions = auth;
                        if(m_firstPage != 0)
                        {
                            emit sigEnterOrSync(72); //申请翻页收回权限
                        }
                        m_firstPage++;
                    }
                }
                else
                {
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
                    TemporaryParameter::gestance()->m_isAlreadyClass = false;
                    qDebug() << "exitRoom::enterRoomRequest:" << userId;
                    //emit sigSendUserId(userId);
                    emit sigEnterOrSync(10);
                }
                else if(command == "enterRoomRequest")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_enterRoomRequest =  userId;
                    emit sigSendUserId(userId);
                    emit sigEnterOrSync(11);
                }
                else if(command == "enterRoom")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QString auth = contentValue.toObject().take("auth").toString();

                    //qDebug()<<"dfsddddddddddddd"<<auth <<StudentData::gestance()->m_selfStudent.m_studentId <<userId;
                    if(StudentData::gestance()->m_selfStudent.m_studentId == userId)
                    {
                        if(auth == "1")
                        {
                            emit sigEnterOrSync(66); //申请进入教室的返回 同意
                            TemporaryParameter::gestance()->m_isStartClass = true;
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

                    //qDebug()<<"aaaaaaaaaaaaaaaaaaaa"<<auth;
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
                    QString userId = contentValue.toObject().take("userId").toString();
                    QString auth = contentValue.toObject().take("auth").toString();
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
                    emit sigStudentEndClass(fromUser);
                }
                else if(command.contains("settinginfo") )
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QJsonObject infos =  contentValue.toObject().take("infos").toObject();
                    QString  camera = infos.take("camera").toString();
                    QString  microphone = infos.take("microphone").toString();
                    if(infos.value("ishideapp").toString() == "1")
                    {
                        emit sigSendUserId(userId);
                        emit sigEnterOrSync(52);
                    }
                    QPair<QString, QString> pairStatus(camera, microphone);
                    StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
                    emit sigUserIdCameraMicrophone( userId, camera, microphone);
                    emit sigEnterOrSync(68); //改变频道跟音频 状态

                }
                else if(command.contains("avControl") )
                {
                    QString avType = contentValue.toObject().take("avType").toString();
                    QString startTime = contentValue.toObject().take("startTime").toString();
                    QString controlType = contentValue.toObject().take("controlType").toString();
                    QString avUrl = contentValue.toObject().take("avUrl").toString();
                    //qDebug()<<"avType =="<<avType<<"startTime =="<<startTime<<"controlType =="<<controlType<<"avUrl =="<<avUrl;
                    emit sigAvUrl(avType, startTime, controlType, avUrl );
                }
                else if(command.contains("cursor") )
                {
                    QString xPoints = contentValue.toObject().take("X").toString();
                    QString  yPoints = contentValue.toObject().take("Y").toString();
                    double xPoint = xPoints.toDouble();
                    double yPoint = yPoints.toDouble();
                    emit sigPointerPosition( xPoint, yPoint);
                }

            }
        }
    }
    else
    {

    }
}

void SocketHandler::startSendMsg()
{
    m_sendMsgTask->start(20);
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
        if (domain == "draw" && command == "courware")
        {
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
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0));
                }
            }
            else if (!m_pages.contains(docId))
            {
                QList<MessageModel> list;
                list.append(MessageModel(0, "", 1.0, 1.0));
                m_pages.insert(docId, list);
                m_pageSave.insert(m_currentCourse, m_currentPage);
                TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                m_currentCourse = docId;
                TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                m_currentPage = 1;
                for (int i = 0; i < arr.size(); ++i)
                {
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0));
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
        else if (domain == "page" && command == "goto")
        {
            int pageI = contentVal.toObject().take("page").toString().toInt();
            pageI = pageI < 0 ? 0 : pageI;
            if (pageI > m_pages[m_currentCourse].size() - 1)
                pageI = m_pages[m_currentCourse].size() - 1;
            m_currentPage = pageI;
        }
        else if (domain == "page" && command == "insert")
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0));
        else if (domain == "page" && command == "delete")
        {
            if (m_pages[m_currentCourse].size() == 1)
            {
                m_pages[m_currentCourse][0].release();
                m_pages[m_currentCourse].removeAt(0);
                //                model->release();
                m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0));
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
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height));
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
            QString uid = contentVal.toObject().take("userId").toString();
            QString auth = contentVal.toObject().take("auth").toString();
            m_userPagePermissions.insert(uid, auth);
            if(StudentData::gestance()->m_selfStudent.m_studentId == uid)
            {
                TemporaryParameter::gestance()->m_userPagePermissions = auth;
            }
        }
        else if (domain == "server" && command == "changeAudio")
        {
            m_supplier = contentVal.toObject().take("supplier").toString();
            m_videoType = contentVal.toObject().take("videoType").toString();
            TemporaryParameter::gestance()->m_supplier = m_supplier;
            TemporaryParameter::gestance()->m_videoType = m_videoType;
        }
        else if (domain == "draw" &&
                 (command == "trail" || command == "polygon" || command == "ellipse"))
        {
            m_pages[m_currentCourse][m_currentPage].addMsg(fromUser, msg);
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
            if(!model.isCourware)
            {

                model.bgimg = "";
            }
            m_pages[m_currentCourse][m_currentPage].clear();


        }
        else if (domain == "server" && command == "startClass")
        {
            m_isInit = true;
            //TemporaryParameter::gestance()->m_isAlreadyClass = m_isInit;
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
            // qDebug()<<" StudentData::gestance()->m_cameraPhone"<< StudentData::gestance()->m_cameraPhone;

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
        list.append(MessageModel(0, "", 1.0, 1.0));
        m_pages.insert("DEFAULT", list);
        m_currentPage = 0;
        m_currentCourse = "DEFAULT";
        //画一页
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
        emit sigDrawPage(model);
    }
}
//ip切换
void SocketHandler::onChangeOldIpToNew()
{
    m_canSend = false;
    m_socket->socketDisconnect();
    m_socket->changeSerIp();
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

    //    if(m_userPagePermissions.count() > 0 ) {
    //        QMap<QString, QString>::iterator it = m_userPagePermissions.begin();
    //        for(; it !=  m_userPagePermissions.end() ; it++ ) {
    //            if(it.value() == "1") {
    //                QString bstr =  QString("{\"domain\":\"auth\",\"command\":\"gotoPage\",\"content\":{\"userId\":\"%1\",\"auth\":\"0\"}}").arg( it.key() );
    //                sendLocalMessage(bstr,true,false);
    //            }
    //        }
    //    }

    if( !TemporaryParameter::gestance()->m_isStartClass)
    {
        if (pageIndex < 0 || pageIndex > m_pages[m_currentCourse].size() - 1)
        {
            return;
        }
        MessageModel model = m_pages[m_currentCourse][pageIndex];
        model.setPage(m_pages[m_currentCourse].size(), pageIndex);
        emit sigDrawPage(model);
        return;
    }
    if (pageIndex < 0 || pageIndex > m_pages[m_currentCourse].size() - 1)
    {
        return;
    }
    QString s("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number(pageIndex, 10) + "\"}}");
    // qDebug()<<"aaaa  ==="<<s;
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
