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
    , m_isGotoPageRequst(false)
    , currentReloginTimes(0)
    , m_sysnStatus(false)
{

    QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
    m_pages.insert("DEFAULT", list);

    m_sendMsgTask = new QTimer(this);
    connect(m_sendMsgTask, SIGNAL(timeout()), this, SLOT(sendMessage()));
    m_sendAudioQualityTask = new QTimer(this);
    connect(m_sendAudioQualityTask, SIGNAL(timeout()), this, SLOT(sendAudioQuality()));

    restGoodIpList();
    m_socket = new YMTCPSocket(this);
    connect(m_socket, &YMTCPSocket::readMsg, this, &SocketHandler::readMessage);
    connect(m_socket, SIGNAL(hasNetConnects(bool)), this, SIGNAL(sigNetworkOnline(bool)));
    connect(m_socket, SIGNAL(hasNetConnects(bool)), this, SLOT(justChangeIp(bool)));
    connect(m_socket, SIGNAL(tcpConnectFail()), this, SLOT(autoChangeIp()));
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

    m_enterRoomMsg = QString("1#SYSTEM{\"command\":\"enterRoom\",\"content\":"
                             "{\"qqvoiceVersion\":\"1.8.2\",\"appVersion\":\"%1\",\"recordVersion\":\"2.3.2\","
                             "\"MD5Pwd\":\"%2\",\"agoraVersion\":\"1.8\",\"userId\":\"%3\","
                             "\"userType\":\"%4\",\"sysInfo\":\"%5\",\"phone\":\"%6\",\"lessonId\":\"%7\","
                             "\"deviceInfo\":\"%8\",\"lat\":\"%9\",\"lng\":\"%10\",\"netType\":\"%11\",\"appSource\":\"YIMI\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_appVersion).arg(StudentData::gestance()->m_mD5Pwd).arg(StudentData::gestance()-> m_selfStudent.m_studentId).arg("teacher").arg(StudentData::gestance()->m_sysInfo)
                     .arg(StudentData::gestance()->m_phone).arg(StudentData::gestance()->m_lessonId).arg(StudentData::gestance()->m_deviceInfo).arg(StudentData::gestance()->m_lat).arg(StudentData::gestance()->m_lng).arg(netType);

    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
    //    m_lastHBTime.start();
    //    startSendMsg();
    //    startSendAudioQuality();
    //    m_socket->newConnect();
    m_currentPlanId = "";
    m_currentColumnId = "";
    m_currentQuestionId = "";
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

    QString httpUrl = m_httpClient->getRunUrl(0);
    QString url = "https://" + httpUrl + "/api/oss/make/sign"; //环境切换要注意更改
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();

    if(allDataObj.value("result").toString().toLower() == "success")
    {
        QString url = allDataObj.value("data").toString();
        return url;
    }
    else
    {
        qDebug() << "SocketHandler::getOssSignUrl::Fail" << allDataObj;
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
        //qDebug() << "==ssssssssss==" << current_second - model.expiredTime << current_second << model.expiredTime;
        if(model.expiredTime == 0 || current_second - model.expiredTime >= 1800)//30分钟该页重新请求一次验签
        {
            QString oldImgUrl = model.bgimg;
            int indexOf = oldImgUrl.indexOf(".com");
            int midOf = oldImgUrl.indexOf("?");
            QString key = oldImgUrl.mid(indexOf + 4, midOf - indexOf - 4);
            QString newImgUrl = getOssSignUrl(key);

            //qDebug() << "=====drawPage::key=====" << imgUrl << newImgUrl;
            if(newImgUrl == "")
            {
                return imgUrl;
            }

            m_pages[m_currentCourse][m_currentPage].expiredTime = current_second;
            m_pages[m_currentCourse][m_currentPage].setImageUrl(newImgUrl, model.width, model.height);
            return newImgUrl;
        }
    }
    return imgUrl;
}
#endif

//发送本地消息
void SocketHandler::sendLocalMessage(QString cmd, bool append, bool drawPage)
{
    //qDebug() << "SocketHandler::sendLocalMessage:" << cmd << append << drawPage << m_isInit << m_currentPage;
    if(cmd.contains("courware")) //如果课件默认值是1则改为总页数
    {
        if(m_pages.contains("DEFAULT"))
        {
            cmd.replace("\"pageIndex\":\"1\"", "\"pageIndex\":\"" + QString::number(m_pages.value("DEFAULT").size()) + "\"");
            //qDebug() << "default" << m_pages.value("DEFAULT").size();
        }
    }

    excuteMsg(cmd, StudentData::gestance()->m_selfStudent.m_studentId);

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
#ifdef USE_OSS_AUTHENTICATION
        model.bgimg = checkOssSign(model.bgimg);
#endif
        emit sigDrawPage(model);
    }

    if(m_isInit)
    {
        if (append)
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
    //qDebug() << "===cuttents::old=====" << cuttents << m_pages[docId].size();
    if(m_pages[docId].size()  <= cuttents)
    {
        cuttents = 1;
    }
    //qDebug() << "===cuttents::new=====" << cuttents;
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
    TemporaryParameter::gestance()->avPlaySetting.currentTime = line.mid(line.indexOf(":", 0) + 1, line.indexOf("}", 0) - 1 - line.indexOf(":", 0)).toLongLong();
    //解析命令
    //qDebug() << "==SocketHandler::readMessage=="<< recvNum << fromUser<< msgJson;
    parseMsg(recvNum, fromUser, msgJson);
}

void SocketHandler::sendMessage(QString msg)
{
    m_socket->sendMsg(msg);
    //qDebug() << "SocketHandler::sendMessage:" << msg;
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
                else if (command == "totalTime")
                {
                    int currentPlayerTimer = contentValue.toObject().take("time").toString().toInt();
                    emit sigCurrentLessonTimer(currentPlayerTimer);
                }
                else if (command == "reLogin")
                {
                    if (!m_response && m_lastSendMsg != "")
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
                    }
                    else
                    {
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
                else if (command == "synchronize")
                {
                    isInitFromServe = true;
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
#ifdef USE_OSS_AUTHENTICATION
                        model.bgimg = checkOssSign(model.bgimg);
#endif
                        TemporaryParameter::gestance()->m_userBrushPermissionsId = m_userBrushPermissions;
                        emit sigAuthtrail(m_userBrushPermissions);
                        emit sigDrawPage(model);
                        emit sigEnterOrSync(2) ;
                        m_sysnStatus = true;
                        //qDebug() << "############m_sysnStatus##############" << m_currentPlanId << m_currentColumnId;
                        if(m_currentPlanId == "" && m_currentColumnId == "")
                        {
                            isInitFromServe = false;
                            return;
                        }
                        emit sigPlanChange(0, m_currentPlanId.toLong(), m_currentColumnId.toLong());
                        emit sigCurrentQuestionId(m_currentPlanId, m_currentColumnId, m_currentQuestionId, offsetY, m_currentQuestionButStatus);
                        emit sigCurrentColumn(m_currentPlanId.toLong(), m_currentColumnId.toLong());
                        emit sigOffsetY(offsetY);
                    }
                    else
                    {
                        m_sendMsgNum++;
                        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#SYSTEM{\"command\":\"synchronize\",\"content\":{\"currentIndex\":\"" + m_lastRecvNum
                                        + "\",\"includeSelfMsg\":\"" + m_includeSelfMsg + "\"},\"domain\":\"system\"}";
                        m_response = false;
                        sendMessage(m_lastSendMsg);
                    }
                    isInitFromServe = false;
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
                                //qDebug()<< "======teacher::Online=======";
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
                                        //qDebug()<< "======m_astudentIsOnline=======" << ids;
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
                    //TemporaryParameter::gestance()->m_supplier = supplier;
                    //TemporaryParameter::gestance()->m_videoType = videoType;
                    emit sigEnterOrSync(61); //改变频道跟音频 频道
                }
                else if(command == "enterFailed")
                {
                    emit sigEnterOrSync(0);
                }
                else if(command == "startClass")
                {
                    QString totalTime = contentValue.toObject().take("totalTime").toString();
                    //QString supplieras = contentValue.toObject().take("supplier").toString();
                    //QString videoTypeas = contentValue.toObject().take("videoType").toString();
                    //qDebug() << "SocketHandler::parseMsg::startClass>>" << supplieras << videoTypeas;
                    //TemporaryParameter::gestance()->m_supplier = supplieras;
                    //TemporaryParameter::gestance()->m_videoType = videoTypeas;
                    TemporaryParameter::gestance()->m_isStartClass = true;
                    TemporaryParameter::gestance()->m_isAlreadyClass = true;
                    m_response = true;
                    emit sigStartClassTimeData(totalTime);
                    if(TemporaryParameter::gestance()->avPlaySetting.isHasSynchronize == false
                       && TemporaryParameter::gestance()->avPlaySetting.m_controlType == "play")
                    {
                        //同步 播放时间
                        //qDebug() << "avPlaySetting::" << TemporaryParameter::gestance()->avPlaySetting.m_avType;
                        TemporaryParameter::gestance()->avPlaySetting.m_startTime = QString::number(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.playTime).secsTo(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.currentTime)) + TemporaryParameter::gestance()->avPlaySetting.m_startTime.toInt() );
                        emit sigAvUrl(TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );
                        TemporaryParameter::gestance()->avPlaySetting.isHasSynchronize = true;
                    }
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
                        QString appVersion = "0";
                        foreach (QJsonValue values, contentArray)
                        {
                            QString sysInfo = values.toObject().take("sysInfo").toString();
                            QString userId = values.toObject().take("userId").toString();
                            appVersion = values.toObject().take("appVersion").toString();
                            TemporaryParameter::gestance()->m_phoneType[userId] = sysInfo;
                        }

                        QStringList versionList = appVersion.split(".");

                        //qDebug() << "***********stuVersion************"<< versionList;
                        if(versionList.size() > 1)
                        {
                            QString current_Version = versionList.at(0);
                            int c_version = current_Version.toInt();
                            //qDebug() << "***********c_version************"<< c_version;
                            if(c_version < 3)
                            {
                                emit sigStudentAppversion(false);
                            }
                            else
                            {
                                emit sigStudentAppversion(true);
                            }
                        }
                        else
                        {
                            emit sigStudentAppversion(false);
                        }

                    }
                }
                else if(command == "changeCmd")
                {
                    QString cmd =  contentValue.toObject().take("cmd").toString();
                    QString cmdData = contentValue.toObject().take("data").toString();
                    QString cmdPort = contentValue.toObject().take("port").toString();
                    if(cmd == "server")
                    {
                        //切换服务器
                        StudentData::gestance()->m_address = cmdData;//contentValue.toObject().take("data").toString();
                        StudentData::gestance()->m_port = cmdPort.toInt();//contentValue.toObject().take("port").toString().toInt()
                        TemporaryParameter::gestance()->enterRoomStatus = "C";
                        onChangeOldIpToNew();
                    }
                    if(cmd == "supplier")
                    {
                        //切换通道
                        emit sigChangedWay(cmdData);
                    }
                    if(cmd == "page")
                    {
                        //翻页
                        emit sigChangedPage();
                    }
                    //qDebug() << "changeCmd" << cmd << cmdData << cmdPort;
                }
                else if (command == "kickOut")
                {
                    emit sigEnterOrSync(88);//账号在其他地方登录 被迫下线
                    //qDebug()<<QStringLiteral("账号在其他地方登录 被迫下线");
                }
            }
            else if (domain == "draw")
            {
                if(command == "questionAnswer")
                {
                    QString questionId = contentValue.toObject().take("questionId").toString();
                    QString planId = contentValue.toObject().take("planId").toString();
                    QString columnId = contentValue.toObject().take("columnId").toString();
                    long lessonId = jsonObj.value("lessonId").toString().toLong();
                    //qDebug() << "===questionAnswer===" << questionId << planId << columnId << lessonId;
                    m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(false);
                    emit sigAnalysisQuestionAnswer(lessonId, questionId, planId, columnId);
                    return;
                }
                if(command.contains("answerPicture"))
                {
                    QJsonObject imgPhotosObj = jsonObj.take("content").toObject();
                    //qDebug()  << "****imgPhotosObj*******" << imgPhotosObj << jsonObj.take("content");
                    return;
                }
                if(command.contains("column"))
                {
                    QString planId = contentValue.toObject().take("planId").toString();
                    QString columnId = contentValue.toObject().take("columnId").toString();
                    emit sigSynColumn(planId, columnId);
                    return;
                }
                excuteMsg(msg, fromUser);
                if (command != "trail" && command != "polygon" && command != "ellipse")
                {
                    //画一页
                    MessageModel model = m_pages[m_currentCourse][m_currentPage];
                    model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
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
                excuteMsg(msg, fromUser);
                //画一页
                MessageModel model = m_pages[m_currentCourse][m_currentPage];
                model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
#ifdef USE_OSS_AUTHENTICATION
                model.bgimg = checkOssSign(model.bgimg);
#endif
                emit sigDrawPage(model);
            }
            else if (domain == "auth")
            {
                if(command == "gotoPageRequest" )
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_userId = userId ;
                    m_isGotoPageRequst = true;
                    sigSendUserId(userId);
                    emit  sigEnterOrSync(8);
                }
                else if(command == "exitRequest")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_exitRequestId = userId;
                    //qDebug() << "exitRoom::enterRoomRequest:" << userId;
                    emit sigSendUserId(userId);
                    emit sigEnterOrSync(10);
                }
                else if(command == "finishReq")   //申请结束课程
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_exitRequestId = userId;
                    //qDebug() << "finishResp::userId" << userId;
                    emit sigSendUserId(userId);
                    emit sigEnterOrSync(50);
                }
                else if(command == "enterRoomRequest")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_enterRoomRequest =  userId;
                    //qDebug() << "enterRoomRequest:" << userId;
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
                    TemporaryParameter::gestance()->m_isFinishLesson = true;
                }
                else if(command.contains("settinginfo") )
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    QJsonObject infos =  contentValue.toObject().take("infos").toObject();
                    QString  camera = infos.take("camera").toString();
                    QString  microphone = infos.take("microphone").toString();
                    if(infos.value("ishideapp").toString() == "1")
                    {
                        //qDebug() << "settinginfo:" << userId;
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
                else if(command.contains("zoomInOut"))
                {
                    double offsetY =  contentValue.toObject().take("offsetY").toString().toDouble();
                    emit sigZoomInOut(0.0, offsetY, 1.0);
                    emit sigOffsetY(offsetY);
                    //qDebug() << "=========offsetY========" << offsetY;
                }
                else if(command.contains("closeAnswerParsing"))  //关闭答案解析
                {
                    QString questionId = contentValue.toObject().take("questionId").toString();
                    QString childQuestionId = contentValue.toObject().take("childQuestionId").toString();
                    emit sigIsOpenAnswer(false, questionId, childQuestionId);
                }
                else if(command.contains("openAnswerParsing"))  //打开答案解析
                {
                    QString questionId = contentValue.toObject().take("questionId").toString();
                    QString childQuestionId = contentValue.toObject().take("childQuestionId").toString();
                    emit sigIsOpenAnswer(true, questionId, childQuestionId);
                }
                else if(command.contains("openCorrect"))  //打开批改
                {
                    emit sigIsOpenCorrect(true);
                }
                else if(command.contains("closeCorrect"))  //关闭批改
                {
                    emit sigIsOpenCorrect(false);
                }
            }

        }
    }
    else
    {
        qDebug() << "SocketHandler::parseMsg::error" << msg;
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

//解析命令函数
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
#ifdef USE_OSS_AUTHENTICATION
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, "", "0", 0, false, 0));
#else
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, "", "0", 0, false));
#endif
                }
            }
            else if (!m_pages.contains(docId))
            {
                QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
                list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
                list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
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
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, "", "0", 0, false, 0));
#else
                    m_pages[m_currentCourse].append(MessageModel(1, arr.at(i).toString(), 1.0, 1.0, "", "0", 0, false));
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
            m_currentPlanId = docId;
        }
        else if (domain == "page" && command == "goto")
        {
            int pageI = contentVal.toObject().take("page").toString().toInt();
            pageI = pageI < 0 ? 0 : pageI;
            if (pageI > m_pages[m_currentCourse].size() - 1)
                pageI = m_pages[m_currentCourse].size() - 1;
            m_currentPage = pageI;

            QStringList strList =  m_currentCourse.split("|");
            //qDebug() << "========goto::page=======" << m_currentCourse << m_currentPage << strList.size();
            if(strList.size() > 1)
            {
                QString planId = strList.at(0);
                QString columnId = strList.at(1);
                if(m_pages.contains(m_currentCourse))
                {
                    if(m_pages[m_currentCourse].size() > 1)
                    {
                        QString questionId = m_pages[m_currentCourse].at(m_currentPage).questionId;
                        double m_offsetY = m_pages[m_currentCourse].at(m_currentPage).offsetY;
                        bool m_questionStatus = m_pages[m_currentCourse].at(m_currentPage).questionBtnStatus;


                        m_pageSave.insert(m_currentCourse, 1);
                        if(m_sysnStatus)
                        {
                            emit sigCurrentQuestionId(planId, columnId, questionId, m_offsetY, m_questionStatus);
                        }
                    }
                }
            }
        }
        else if (domain == "page" && command == "insert")
        {
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
            QStringList strList = m_currentCourse.split("|");
            if(strList.size() > 1)
            {
                QString planId = strList.at(0);
                QString columnId = strList.at(1);
                emit sigCurrentQuestionId(planId, columnId, "", 0, false);
            }
        }
        else if (domain == "page" && command == "delete")
        {
            if (m_pages[m_currentCourse].size() == 1)
            {
                m_pages[m_currentCourse][0].release();
                m_pages[m_currentCourse].removeAt(0);
#ifdef USE_OSS_AUTHENTICATION
                m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
                m_pages[m_currentCourse].append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif

                QStringList strList = m_currentCourse.split("|");
                if(strList.size() > 1)
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
            if(strList.size() > 1)
            {
                QString planId = strList.at(0);
                QString columnId = strList.at(1);
                QString docId = planId + "|" + columnId;
                if(m_pages.contains(docId))
                {
                    QString questionId = m_pages[docId].at(m_currentPage).questionId;
                    emit sigCurrentQuestionId(planId, columnId, questionId, 0, false);
                }
            }
        }
        else if (domain == "draw" && command == "picture")
        {
            QString url = contentVal.toObject().take("url").toString();
            double width = contentVal.toObject().take("width").toString().toDouble();
            double height = contentVal.toObject().take("height").toString().toDouble();
            QStringList strList = m_currentCourse.split("|");
            QString questionId = "-2";
            if(strList.size() > 1)
            {
                questionId = "-1";
            }
            //qDebug() << "=======picture===========" << url << questionId;
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, questionId, "0", 0, false, 0));
#else
            m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, width, height, questionId, "0", 0, false));
#endif
        }
        else if (domain == "auth" && command == "control")
        {
            QString uid = contentVal.toObject().take("userId").toString();
            QString auth = contentVal.toObject().take("auth").toString();
            TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(uid, auth);
            m_userBrushPermissions.insert(uid, auth);
        }
        else if (domain == "auth" && command == "gotoPageRequest")
        {
            m_isGotoPageRequst = true;
            //qDebug() << "==m_isGotoPageRequst===" << m_isGotoPageRequst;
        }
        else if (domain == "auth" && command == "gotoPage")
        {
            QString uid = contentVal.toObject().take("userId").toString();
            QString auth = contentVal.toObject().take("auth").toString();
            TemporaryParameter::gestance()->m_userId = uid ;
            m_userPagePermissions.insert(uid, auth);
            //if(StudentData::gestance()->m_selfStudent.m_studentId == uid) {
            TemporaryParameter::gestance()->m_userPagePermissions = auth;
            m_isGotoPageRequst = false;
            //qDebug() << "***m_isGotoPageRequst***" << m_isGotoPageRequst;
        }
        else if (domain == "server" && command == "changeAudio")
        {
            m_supplier = contentVal.toObject().take("supplier").toString();
            m_videoType = contentVal.toObject().take("videoType").toString();
            TemporaryParameter::gestance()->m_supplier = m_supplier;
            TemporaryParameter::gestance()->m_videoType = m_videoType;
            //qDebug() << "======server=======" << m_videoType << m_supplier;
        }
        else if (domain == "draw" &&  (command == "trail" || command == "polygon" || command == "ellipse"))
        {
            //qDebug() << "=======m_currentCourse=========" << m_currentCourse << m_currentPage;
            m_pages[m_currentCourse][m_currentPage].addMsg(fromUser, msg);
        }
        else if (domain == "draw" && command == "undo") //撤销删除对应的当前记录
        {
            //qDebug() << "=======sockethandler::fromUser========" << fromUser;
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
        else if(domain == "draw" && command == "question")
        {
            m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(true);
            m_currentQuestionButStatus = true;
            emit sigSynQuestionStatus(true);
            return;
        }
        else if(domain == "draw" && command == "stopQuestion")
        {
            m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(false);
            m_currentQuestionButStatus = false;
            emit sigSynQuestionStatus(false);
            return;
        }
        else if(domain == "draw" && command == "lessonPlan")
        {
            QJsonObject contentObj = contentVal.toObject();
            //qDebug() << "=====contentObj======" << contentObj;
            QString planId = contentObj.value("planId").toString();
            QJsonArray columnsArray = contentObj.value("columns").toArray();
            if(columnsArray.size() <= 0)
            {
                m_currentPage = 1;
                return;
            }
            QString itemId;
            for(int i = 0; i < columnsArray.size(); i++)
            {
                QJsonObject columnObj =  columnsArray.at(i).toObject();
                QString columnId = columnObj.value("columnId").toString();
                QJsonArray questionsArray = columnObj.value("questions").toArray();
                if(i == 0 )
                {
                    itemId = columnId;
                }
                QString docId = planId + "|" + columnId;
                if (m_pages.contains("DEFAULT"))
                {
                    m_pages.insert(docId, m_pages.value("DEFAULT"));
                    m_pages.remove("DEFAULT");
                    m_currentCourse = docId;
                    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                    m_currentPage = m_pages[m_currentCourse].size();
                    for(int z = 0; z < questionsArray.size(); z++)
                    {
                        QString questionId = questionsArray.at(z).toString();
#ifdef USE_OSS_AUTHENTICATION
                        m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false, 0));
#else
                        m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false));
#endif
                    }
                }
                else if (!m_pages.contains(docId))
                {
                    QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
                    list.append(MessageModel(0, "", 1.0, 1.0, "", columnId, 0, false, 0));
#else
                    list.append(MessageModel(0, "", 1.0, 1.0, "", columnId, 0, false));
#endif
                    m_pages.insert(docId, list);
                    //  m_pageSave.insert(m_currentCourse,m_currentPage);
                    TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                    m_currentCourse = docId;
                    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                    m_currentPage = 1;
                    for(int z = 0; z < questionsArray.size(); z++)
                    {
                        QString questionId = questionsArray.at(z).toString();
#ifdef USE_OSS_AUTHENTICATION
                        m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false, 0));
#else
                        m_pages[m_currentCourse].append(MessageModel(1, "", 1.0, 1.0, questionId, columnId, 0, false));
#endif
                    }
                }
                else
                {
                    //  m_pageSave.insert(m_currentCourse,m_currentPage);
                    TemporaryParameter::gestance()->m_pageSave.insert(m_currentCourse, m_currentPage);
                    TemporaryParameter::gestance()->m_currentCourse = m_currentCourse;
                }
            }

        }
        else if(domain == "draw" && command == "column")
        {
            //qDebug() << "========contentVal========" << contentVal.toObject();
            QJsonObject contentObj = contentVal.toObject();
            QString columnId = contentObj.value("columnId").toString();
            int pageIndex = contentObj.value("pageIndex").toString().toInt();
            QString planId = contentObj.value("planId").toString();
            QString docId = planId + "|" + columnId;
            //qDebug() << "*********draw::column*********" << planId << columnId;
            if(m_pages.contains(docId))
            {
                m_currentCourse = docId;
                m_currentPage = m_pageSave.value(m_currentCourse, 0);
                //qDebug() << "**********m_currentPage111**********" << m_currentPage;
                m_currentPage = m_currentPage == 0 ? 1 : m_currentPage;
                //qDebug() << "*********currentPage**********" << m_currentPage << m_pages[docId].size() << m_pageSave.value(m_currentCourse,0) << m_sysnStatus;
                if(m_currentPage >= m_pages[docId].size())
                {
                    m_currentPage = 0;
                    //qDebug() << "******return**********";
                    return;
                }

                QString currentQustionId = m_pages[docId].at(m_currentPage).questionId;
                MessageModel msgModel  = m_pages[docId][m_currentPage];
                msgModel.setPage(m_pages[docId].size(), m_currentPage);
#ifdef USE_OSS_AUTHENTICATION
                msgModel.bgimg = checkOssSign(msgModel.bgimg);
#endif
                sigDrawPage(msgModel);

                if(m_sysnStatus)
                {
                    emit sigCurrentQuestionId(planId, columnId, currentQustionId, 0, false);
                }

                //qDebug() << "=======draw::column2222======="  <<isInitFromServe;
                if(isInitFromServe)
                {
                    return;
                }
                //qDebug() << "=======draw::column2222=======" ;
                m_currentPlanId = planId;
                m_currentColumnId = columnId;
                m_currentQuestionId = currentQustionId;
                emit sigCurrentColumn(planId.toLong(), columnId.toLong());
            }

        }
        else if(domain == "draw" && command == "autoPicture")
        {
            //qDebug() << "==========autoPicture=======" << contentVal;
            QString imageUrl = contentVal.toObject().value("imageUrl").toString();
            double imgWidth = contentVal.toObject().value("imgWidth").toString().toDouble();
            double imgHeight = contentVal.toObject().value("imgHeight").toString().toDouble();
            QString questionId = contentVal.toObject().value("questionId").toString();
            m_pages[m_currentCourse][m_currentPage].bgimg = imageUrl;
            m_pages[m_currentCourse][m_currentPage].width = imgWidth;
            m_pages[m_currentCourse][m_currentPage].height = imgHeight;
            m_pages[m_currentCourse][m_currentPage].questionBtnStatus = false;
            m_pages[m_currentCourse][m_currentPage].setImageUrl(imageUrl, imgWidth, imgHeight);
        }
        else if (domain == "draw" && command == "questionAnswer")
        {
            emit sigSynQuestionStatus(false);
            return;
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
            //StudentData::gestance()->m_camera = camera;
            //StudentData::gestance()->m_microphone = microphone;
            QPair<QString, QString> pairStatus(camera, microphone);
            StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
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
        else if(domain.contains("control") && command.contains("zoomInOut"))
        {
            //            offsetY =  contentVal.toObject().take("offsetY").toString().toDouble();
            //            m_pages[m_currentCourse][m_currentPage].setOffsetY(offsetY);
            //qDebug() << "=========offsetY========" << offsetY;
            return;
        }
    }
    else
    {

    }
}

void SocketHandler::clearRecord()
{
    //qDebug() << "SocketHandler::clearRecord" << m_isInit;
    if(!m_isInit)
    {
        m_isInit = true;
        m_pages.clear();
        m_pageSave.clear();
        TemporaryParameter::gestance()->m_pageSave.clear();
        QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
        list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false, 0));
#else
        list.append(MessageModel(0, "", 1.0, 1.0, "", "1", 0, false));
#endif
        m_pages.insert("DEFAULT", list);
        m_currentPage = 0;
        m_currentCourse = "DEFAULT";
        //画一页
        MessageModel model = m_pages[m_currentCourse][m_currentPage];
        model.setPage(m_pages[m_currentCourse].size(), m_currentPage);
        emit sigDrawPage(model);
        emit sigOneStartClass();
        //qDebug() << "******SocketHandler::clearRecord*********";
    }
}
//ip切换
void SocketHandler::onChangeOldIpToNew()
{
    //    m_socket->disConnect();
    //    m_socket = new YMTCPSocket(this);
    //    connect(m_socket,&YMTCPSocket::readMsg,this,&SocketHandler::readMessage);
    //    connect(m_socket,SIGNAL(sigNetworkOnline(bool)),this,SIGNAL(sigNetworkOnline(bool)));
    m_canSend = false;
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
    //qDebug() << "=====SocketHandler::goPage=====" << m_currentCourse << pageIndex << m_currentPage << m_pageSave.size();
    if( !TemporaryParameter::gestance()->m_isStartClass)
    {
        if (pageIndex < 0 || pageIndex > m_pages[m_currentCourse].size() - 1)
        {
            return;
        }
        MessageModel model = m_pages[m_currentCourse][pageIndex];
        model.setPage(m_pages[m_currentCourse].size(), pageIndex);
#ifdef USE_OSS_AUTHENTICATION
        model.bgimg = checkOssSign(model.bgimg);
#endif
        m_currentPage = pageIndex;

        emit sigDrawPage(model);

        QStringList strList = m_currentCourse.split("|");
        if(strList.size() > 1)
        {
            QString planId = strList.at(0);
            QString columnId = strList.at(1);
            m_pageSave.insert(m_currentCourse, m_currentPage);
            //qDebug() << "**********SocketHandler::goPage************" << m_currentCourse << m_currentPage <<model.questionId << model.bgimg;
            emit sigCurrentQuestionId(planId, columnId, model.questionId, model.offsetY, model.questionBtnStatus);
        }
        return;
    }

    if (pageIndex < 0 || pageIndex > m_pages[m_currentCourse].size() - 1)
    {
        return;
    }

    QString s("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number(pageIndex) + "\"}}");
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
    //qDebug()<<"current ip "<<StudentData::gestance()->m_address<<StudentData::gestance()->m_port<<StudentData::gestance()->m_isTcpProtocol;
    //    if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size())
    //    {
    //        m_socket->resetDisConnect(!StudentData::gestance()->m_isTcpProtocol);
    //    }else
    //    {

    //    }
    m_socket->resetDisConnect(StudentData::gestance()->m_isTcpProtocol);
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
                //qDebug()<<"位置"<<tempHasConnect;
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
                //qDebug()<<"1111111111111111111111"<<tempHasConnect<<TemporaryParameter::gestance()->goodIpList.size();
                StudentData::gestance()->m_address = TemporaryParameter::gestance()->goodIpList.at(tempHasConnect + 1).toMap()["ip"].toString();
                StudentData::gestance()->m_port = TemporaryParameter::gestance()->goodIpList.at(tempHasConnect + 1).toMap()["port"].toInt();
                StudentData::gestance()->m_udpPort = TemporaryParameter::gestance()->goodIpList.at(tempHasConnect + 1).toMap()["udpPort"].toInt();
            }
            else
            {
                //qDebug()<<"222222222222222222";
                StudentData::gestance()->m_address = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["ip"].toString();
                StudentData::gestance()->m_port = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["port"].toInt();
                StudentData::gestance()->m_udpPort = TemporaryParameter::gestance()->goodIpList.at(0).toMap()["udpPort"].toInt();
            }
        }
        //切换ip
        //qDebug()<<QStringLiteral("自动切换Iping ~~~~~~~~~~~  ")<<currentAutoChangeIpTimes<<StudentData::gestance()->m_address<<StudentData::gestance()->m_port;;

        //tcp udp 全部切换完毕之后 还掉线就退出
        if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size() * 2)
        {
            //qDebug()<<QStringLiteral("全部切换完毕 掉线退出~~~~~~~~~~~  ");
            autoChangeIpResult("autoChangeIpFail");
            return;
        }
        if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size() )
        {
            //qDebug()<<QStringLiteral("切换一圈之后切换协议模式~~~~~~~~~~~  ")<<StudentData::gestance()->m_isTcpProtocol;
            StudentData::gestance()->m_isTcpProtocol = !StudentData::gestance()->m_isTcpProtocol;;
        }
        ++currentAutoChangeIpTimes;
        onChangeOldIpToNew();

        //切换一圈之后切换协议模式


    }
    else
    {
        //qDebug()<<QStringLiteral("优选Ip列表为空 ~~~~~~~~~~~~  ");
        isAutoChangeIping = false;//重置ip切换标示
        autoChangeIpResult("autoChangeIpFail");//
    }
}

void SocketHandler::justChangeIp(bool isSuccess)
{
    if(isSuccess)
    {
        m_response = true;
    }
    //qDebug() << "TemporaryParameter::gestance()->m_isFinishLesson:" << TemporaryParameter::gestance()->m_isFinishLesson;
    if(TemporaryParameter::gestance()->m_isFinishLesson) //如果是结束课程不进行重连操作
    {
        qDebug() << "===SocketHandler::justChangeIp===";
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
                //qDebug()<<QStringLiteral("3次掉线 ~~~~~~11111~~~~~  ");
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
        //qDebug()<<QStringLiteral("掉线自动重连1") << isSuccess;
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
        //qDebug()<<QStringLiteral("掉线自动重连2")<< isSuccess;
        return;
    }
    else
    {
        //自动连接网络
        emit sigAutoConnectionNetwork();
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
            //qDebug()<<"位置"<<tempHasConnect;
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
        //qDebug()<<"restGoodIpList() fasle ";
    }
    else
    {
        //qDebug()<<"restGoodIpList() has has ";
        TemporaryParameter::gestance()->goodIpList.swap(tempHasConnect, TemporaryParameter::gestance()->goodIpList.size() - 1);
    }

    //qDebug()<<"restGoodIpList()"<<TemporaryParameter::gestance()->goodIpList;

}

