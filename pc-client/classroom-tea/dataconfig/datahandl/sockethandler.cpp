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
    initDefaultCourse();
    m_sendMsgTask = new QTimer(this);
    connect(m_sendMsgTask, SIGNAL(timeout()), this, SLOT(sendMessage()));
    m_sendAudioQualityTask = new QTimer(this);
    connect(m_sendAudioQualityTask, SIGNAL(timeout()), this, SLOT(sendAudioQuality()));

    m_netTimer = new QTimer();
    m_netTimer->setInterval(60000);
    connect(m_netTimer, SIGNAL(timeout()), this, SLOT(interNetworkChange()));
    connect(m_netTimer, SIGNAL(timeout()), this, SLOT(sendC2cDelay()));
    m_netTimer->start();

    m_socketOutTimeTimer = new QTimer();
    m_socketOutTimeTimer->setInterval(30000);
    m_socketOutTimeTimer->setSingleShot(true);
    connect(m_socketOutTimeTimer, SIGNAL(timeout()), this, SLOT(socketTimeOut()));
    m_socketOutTimeTimer->start();

    m_reGetCourseImgTask = new QTimer(this);
    m_reGetCourseImgTask->setInterval(5000);
    m_reGetCourseImgTask->setSingleShot(true);
    connect(m_reGetCourseImgTask,SIGNAL(timeout()),this,SLOT(reGetCourseImg()));

    restGoodIpList();
    m_socket = new YMTCPSocket(this);
    connect(m_socket, &YMTCPSocket::readMsg, this, &SocketHandler::readMessage);
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SIGNAL(sigNetworkOnline(bool)));
    connect(m_socket, SIGNAL(marsLongLinkStatus(bool)), this, SIGNAL(justChangeIp(bool)));

    //新的http协议
    connect(m_socket, SIGNAL(httpTimeOut(QString)), this, SIGNAL(autoChangeIpResult(QString)));

    QString netTypeStr = TemporaryParameter::gestance()->m_netWorkMode;
    //qDebug() << "===netTypeStr===" << netTypeStr;

    int netType = 3;
    if(netTypeStr.contains(QStringLiteral("wireless")))
    {
        netType = 3;
    }
    else
    {
        netType = 4;
    }


    if(StudentData::gestance()->m_plat == "T")
    {
        m_enterRoomMsg = QString("1#SYSTEM{\"command\":\"enterRoom\",\"content\":"
                                 "{\"qqvoiceVersion\":\"6.0.0\",\"appVersion\":\"%1\",\"recordVersion\":\"3.10.19\","
                                 "\"MD5Pwd\":\"%2\",\"agoraVersion\":\"1.8\",\"userId\":\"%3\","
                                 "\"userType\":\"%4\",\"sysInfo\":\"%5\",\"phone\":\"%6\",\"lessonId\":\"%7\","
                                 "\"deviceInfo\":\"%8\",\"lat\":\"%9\",\"lng\":\"%10\",\"netType\":\"%11\",\"lessonType\":\"%12\",\"appSource\":\"YIMI\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_appVersion).arg(StudentData::gestance()->m_mD5Pwd).arg(StudentData::gestance()-> m_selfStudent.m_studentId).arg("teacher").arg(StudentData::gestance()->m_sysInfo)
                .arg(StudentData::gestance()->m_phone).arg(StudentData::gestance()->m_lessonId).arg(StudentData::gestance()->m_deviceInfo).arg(StudentData::gestance()->m_lat).arg(StudentData::gestance()->m_lng).arg(netType).arg(YMUserBaseInformation::lessonType);
    }
    else{
        //assistent 关单角色
        m_enterRoomMsg = QString("1#SYSTEM{\"command\":\"enterRoom\",\"content\":"
                                 "{\"qqvoiceVersion\":\"6.0.0\",\"appVersion\":\"%1\",\"recordVersion\":\"2.3.2\","
                                 "\"MD5Pwd\":\"%2\",\"agoraVersion\":\"1.8\",\"userId\":\"%3\","
                                 "\"userType\":\"%4\",\"sysInfo\":\"%5\",\"phone\":\"%6\",\"lessonId\":\"%7\","
                                 "\"deviceInfo\":\"%8\",\"lat\":\"%9\",\"lng\":\"%10\",\"netType\":\"%11\",\"lessonType\":\"%12\",\"appSource\":\"YIMI\"},\"domain\":\"system\"}").arg(StudentData::gestance()->m_appVersion).arg(StudentData::gestance()->m_mD5Pwd).arg(StudentData::gestance()-> m_selfStudent.m_studentId).arg("assistent").arg(StudentData::gestance()->m_sysInfo)
                .arg(StudentData::gestance()->m_phone).arg(StudentData::gestance()->m_lessonId).arg(StudentData::gestance()->m_deviceInfo).arg(StudentData::gestance()->m_lat).arg(StudentData::gestance()->m_lng).arg(netType).arg(YMUserBaseInformation::lessonType);
    }
    qDebug() << "====m_enterRoomMsg====" << m_enterRoomMsg;

    TemporaryParameter::gestance()->m_currentCourse = getCurrentCourseId();
    m_lastHBTime.start();
    startSendMsg();
    startSendAudioQuality();
    m_currentPlanId = "";
    m_currentColumnId = "";
    m_currentQuestionId = "";
    m_JoinMicId = StudentData::gestance()->m_selfStudent.m_studentId;
}

void SocketHandler::interNetworkChange()
{
    int types = 0;
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
                TemporaryParameter::gestance()->m_netWorkMode = netInterface.name();//netInterface.hardwareAddress();
            }
            types++;
        }
    }

    TemporaryParameter::gestance()->m_netWorkMode.remove("#");
    TemporaryParameter::gestance()->m_netWorkMode.remove("\n");

    QString netTypeStr = TemporaryParameter::gestance()->m_netWorkMode;

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
    emit sigInterNetChange(netType);

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

//发送本地消息
void SocketHandler::sendLocalMessage(QString cmd, bool append, bool drawPage)
{
    qDebug() << "SocketHandler::sendLocalMessage:" << cmd << append << drawPage << m_isInit;
    //======================================
    //退出教室的时候, 直接发送exit room, 不需要在上课中的状态(即: 只有老师 和 CC, 在教室的情况)
    if(cmd.contains("exitRoom"))
    {
        sendMessage(cmd);
    }

    //======================================

    if(cmd.contains("courware")) //如果课件默认值是1则改为总页数
    {
        if(justCourseHasDefaultPage())
        {
            cmd.replace("\"pageIndex\":\"1\"", "\"pageIndex\":\"" + QString::number(getDefaultCourseSize()) + "\"");
        }
    }
    int tempPage = getCurrentCourseCurrentIndex();
    excuteMsg(cmd, StudentData::gestance()->m_selfStudent.m_studentId);

    if (drawPage)
    {
        if( getCurrentCourseSize() < 1)  //画一页
        {
            sigEnterOrSync(18);
            return;
        }
        //qDebug()  << "-----------SocketHandler::sendLocalMessage------------" ;

        drawCurrentPageData(getCurrentCourseId(),getCurrentCourseCurrentIndex());
        if(cmd.contains("pictureReport"))
        {
            ++tempPage;
            drawCurrentPageData(getCurrentCourseId(),tempPage);
        }
    }

    QJsonParseError err;
    QJsonDocument docData = QJsonDocument::fromJson(cmd.toUtf8(),&err);
    if (err.error == QJsonParseError::NoError)
    {
        QString command = docData.object().take("command").toString();
        //如果是旁听则不发送点击栏讲义和栏目目消息
        if((command.contains("column") || command.contains("lessonPlan") ) && m_JoinMicId != StudentData::gestance()->m_selfStudent.m_studentId)
        {
            qDebug() << "===column====" << cmd;
            return;
        }
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
    return getCourseCurrentPage(docId);
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
    qDebug() << "==SocketHandler::readMessage==" << recvNum << fromUser << msgJson;
    parseMsg(recvNum, fromUser, msgJson);
}

void SocketHandler::sendMessage(QString msg)
{
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
            {
                contentValue = jsonObj.take("content");
            }

            //qDebug() << "******m_plat******" << StudentData::gestance()->m_plat  <<  TemporaryParameter::gestance()->m_isStartClass << command;
            if (domain == "server")
            {
                if (command == "response")
                {
                    m_response = true;
                }
                else if (command == "totalTime")
                {
                    int currentPlayerTimer = contentValue.toObject().take("time").toString().toInt();
                    //qDebug() << "=====current::lesson::time=======" << contentValue.toObject().take("time").toString() << currentPlayerTimer;
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
                    m_hasConnectServer = true;
                    StudentData::gestance()->m_hasConnectServer = true;
                    qDebug() << "===enterRoom::userId===" << StudentData::gestance()->m_selfStudent.m_studentAId << StudentData::gestance()->m_plat << TemporaryParameter::gestance()->m_isStartClass <<__LINE__;
                    QString userId = contentValue.toObject().take("userId").toString();
                    StudentData::gestance()->insertIntoOnlineId(userId);
                    StudentData::gestance()->m_userTypeInfo.insert(userId, contentValue.toObject().value("userType").toString());
                    sigUpdateUserStatus();//更新教室内成员状态
                    //================================= >>>
                    //老师上课过程中, 如果CC/CR 进入教室, 需要提示一下
                    //如果不是自己, 不是学生
                    qDebug() << "======enterRoom=====" << userId << StudentData::gestance()->m_selfStudent.m_studentId << StudentData::gestance()->m_selfStudent.m_studentAId << __LINE__;
                    if(userId != StudentData::gestance()->m_selfStudent.m_studentId &&
                            userId != StudentData::gestance()->m_selfStudent.m_studentAId)
                    {
                        emit sigEnterOrSync(1002); //提示: 有人进入教室
                    }
                    //<<<=================================

                    //旁听, 进入教室的, 就直接return了
                    //学生, 进入教室，  则提示开始上课, 或者继续上课
                    if(StudentData::gestance()->m_plat == "L" && TemporaryParameter::gestance()->m_isStartClass
                            && fromUser != StudentData::gestance()->m_selfStudent.m_studentAId)
                    {
                        qDebug() << "===enterRoom::userId===" << __LINE__;
                        return;
                    }

                    //qDebug()<<"else if (command == enterRoom )"<<num<<StudentData::gestance()->m_selfStudent.m_studentId<<StudentData::gestance()->m_teacher.m_teacherId;
                    qDebug() << "===enterRoom::userId===" << userId << StudentData::gestance()->m_selfStudent.m_studentId << num;
                    if (userId == StudentData::gestance()->m_selfStudent.m_studentId && num == "0")//自己进入房间 开始同步
                    {
                        qDebug() << "===enterRoom::userId===" << __LINE__;
                        emit sigEnterOrSync( 1 ) ;
                        m_sendMsgNum++;
                        m_lastSendMsg = QString::number(m_sendMsgNum, 10) + "#SYSTEM{\"command\":\"synchronize\",\"content\":{\"currentIndex\":\"" + m_lastRecvNum
                                + "\",\"includeSelfMsg\":\"" + m_includeSelfMsg + "\"},\"domain\":\"system\"}";
                        m_response = false;
                        sendMessage(m_lastSendMsg);

                        StudentData::gestance()->insertIntoOnlineId(userId);

                        //信息上报
                        QJsonObject obj;
                        obj.insert("result","1");
                        obj.insert("errMsg","");
                        YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);
                    }
                    else
                    {
                        qDebug() << "===enterRoom::userId===" << StudentData::gestance()->m_student.count() << userId << StudentData::gestance()->m_selfStudent.m_studentAId << __LINE__;
                        if(userId == StudentData::gestance()->m_selfStudent.m_studentAId)
                        {
                            for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                            {
                                if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                                {
                                    //TemporaryParameter::gestance()->m_isAlreadyClass = true;
                                    //                                    StudentData::gestance()->insertIntoOnlineId(userId);
                                    emit sigSendUserId(StudentData::gestance()->m_student[i].m_studentId);
                                    if( StudentData::gestance()->justUserIsOnline(StudentData::gestance()->m_JoinMicId) && StudentData::gestance()->m_plat == "L" && StudentData::gestance()->m_applicationType == 1)
                                    {
                                        continue;
                                    }
                                    emit sigEnterOrSync(3); //提示: "开始上课", 或者 "继续上课"的窗口
                                    emit sigUpdateUserStatus();
                                    //qDebug()<< "=============userId========" << userId << m_isInit << TemporaryParameter::gestance()->m_isAlreadyClass;
                                    break;
                                }
                            }

                            qDebug() << "===enterRoom::userId===" << __LINE__;
                            return;
                        }

                        StudentData::gestance()->m_dataInsertion = true;
                        //                        StudentData::gestance()->insertIntoOnlineId(userId);
                        if(StudentData::gestance()->m_selfStudent.m_studentAId.contains(userId))
                        {
                            QPair<QString, QString> pairStatus("1", "1");
                            StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
                        }
                        qDebug() << "========StudentData::gestance()->m_cameraPhone=========" << StudentData::gestance()->m_student.count() << StudentData::gestance()->m_cameraPhone;
                        for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                        {
                            qDebug() << "===AAA===" << userId << StudentData::gestance()->m_student[i].m_studentId;
                            if(userId == StudentData::gestance()->m_student[i].m_studentId && StudentData::gestance()->m_plat != "L")
                            {
                                if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                                {
                                    //TemporaryParameter::gestance()->m_isAlreadyClass = true;
                                    qDebug() << "===enterRoom::userId===" << __LINE__;
                                    emit sigSendUserId(userId);
                                    emit sigEnterOrSync(3); //提示: "开始上课", 或者 "继续上课"的窗口
                                    qDebug()<< "=============userId========" << userId << m_isInit << TemporaryParameter::gestance()->m_isAlreadyClass;
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

                        //发送当前的课件信息
                        currentCourseDataStatus();

                        TemporaryParameter::gestance()->m_userBrushPermissionsId = m_userBrushPermissions;
                        emit sigAuthtrail(m_userBrushPermissions);
                        emit sigEnterOrSync(2) ;
                        emit sigIsOpenCorrect(correctViewIsOpen); //同步完成以后, 控制: 是否打开"批注"的窗口
                        m_sysnStatus = true;
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
                    //qDebug()<< "======onlineState=======" << __LINE__;
                    //如果老师在CC/CR都在教室 谁点击开始上课就是持麦者
                    //如果老师 CC/CR都在教室并且没有点击开始上课则都要弹出开始上课窗体
                    //如果老师不在教室，CC/CR在教室则需要弹出开始上课窗口
                    //如果老师已经是上麦者 CC/CR就是可以申请上麦
                    //如果CC/CR已经上麦 老师进来则可以申请上麦
                    QJsonArray contentArray = contentValue.toArray();
                    TemporaryParameter::gestance()->m_teacherIsOnline = false;
                    TemporaryParameter::gestance()->m_astudentIsOnline = false;
                    if (contentArray.size() > 1)
                    {
                        bool isJoinMic = false;
                        foreach (QJsonValue values, contentArray)
                        {
                            QString ids = values.toString();
                            if(ids == StudentData::gestance()->m_teacher.m_teacherId)
                            {
                                TemporaryParameter::gestance()->m_teacherIsOnline = true;
                                qDebug()<< "======teacher::Online=======";
                            }
                            StudentData::gestance()->m_dataInsertion = true;
                            StudentData::gestance()->insertIntoOnlineId(ids);
                            qDebug() << "===onlinestate===" << m_JoinMicId << ids << TemporaryParameter::gestance()->m_teacherIsOnline << TemporaryParameter::gestance()->m_isAlreadyClass;

                            for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
                            {
                                if(ids == StudentData::gestance()->m_student[i].m_studentId)
                                {
                                    if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
                                    {
                                        TemporaryParameter::gestance()->m_astudentIsOnline = true;
                                        emit sigSendUserId(ids);
                                        //emit sigEnterOrSync(3);
                                        qDebug()<< "======m_astudentIsOnline=======" << ids;
                                    }
                                }
                            }
                        }
                        sigUpdateUserStatus();//更新教室内成员状态
                        //如果老师学生都在线，并且上麦人是自己则开始上课弹窗
                        if(StudentData::gestance()->m_selfStudent.m_studentId == m_JoinMicId && StudentData::gestance()->m_plat == "T" && StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId) && TemporaryParameter::gestance()->m_isStartClass == false  && TemporaryParameter::gestance()->m_teacherIsOnline)
                        {
                            qDebug() << "====myasdfasd=======";
                            emit sigEnterOrSync(3);
                        }

                        if(StudentData::gestance()->m_applicationType != 1 && StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId) && TemporaryParameter::gestance()->m_isStartClass == false  && TemporaryParameter::gestance()->m_teacherIsOnline)
                        {
                            emit sigEnterOrSync(3);
                        }

                        bool isListenStatus = true;
                        //如果上麦的人不是自己并且上麦的人还在教室则以旁听身份进入教室
                        if(m_JoinMicId != StudentData::gestance()->m_selfStudent.m_studentId && StudentData::gestance()->m_onlineId.contains(m_JoinMicId))
                        {
                            qDebug()<< "======AAAAAAAADDDDDDDD======";
                            TemporaryParameter::gestance()->m_isStartClass = true;
                            isListenStatus = false;
                            StudentData::gestance()->m_plat = "L";
                            AudioVideoManager::getInstance()->closeLocalAudio();
                            emit sigEnterOrSync(117);
                        }
                        qDebug() << "====TemporaryParameter::gestance()->m_isAlreadyClassAAA==="<< m_JoinMicId << StudentData::gestance()->m_onlineId<<StudentData::gestance()->m_selfStudent.m_studentId << TemporaryParameter::gestance()->m_isAlreadyClass;
                        //如果学生都在线并且已经开课并且持麦者是自己则以旁听身份进入
                        if(TemporaryParameter::gestance()->m_isAlreadyClass
                                && m_JoinMicId.contains(StudentData::gestance()->m_selfStudent.m_studentId)
                                && StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId)
                                && isListenStatus && StudentData::gestance()->m_plat == "L")
                        {
                            qDebug() << "====TemporaryParameter::gestance()->m_isAlreadyClassBBB===" << TemporaryParameter::gestance()->m_isAlreadyClass;
                            StudentData::gestance()->m_plat = "T";
                            emit sigEnterOrSync(118); //117
                        }

                        //如果老师 不是上麦者并且不在线则弹出开始上课
                        if(StudentData::gestance()->m_plat == "T" && m_JoinMicId != StudentData::gestance()->m_selfStudent.m_studentId && StudentData::gestance()->m_onlineId.contains(m_JoinMicId) == false)
                        {
                            qDebug() << "=====JoinClassRoomAAAAA=====";
                            emit sigEnterOrSync(3);
                        }
                        //当前没有上麦者并且老师不在线则弹出继续上课并且隐藏上麦按钮
                        if(isJoinMic == false && StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_teacher.m_teacherId) == false
                                && StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId))
                        {
                            qDebug() << "=======isJoinMic=======";
                            emit sigEnterOrSync(3);
                            emit sigEnterOrSync(116);//为上麦的则隐藏上麦
                        }

                        qDebug()<< "======onlineState=======" << StudentData::gestance()->m_plat << TemporaryParameter::gestance()->m_astudentIsOnline << TemporaryParameter::gestance()->m_teacherIsOnline << __LINE__;

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
                    qDebug() << "======exitRoom====="  << StudentData::gestance()->m_plat
                             << StudentData::gestance()->m_selfStudent.m_studentAId
                             << StudentData::gestance()->m_onlineId
                             << TemporaryParameter::gestance()->m_isStartClass
                             << m_JoinMicId << userId << __LINE__;

                    //================================= >>>
                    //老师上课过程中, 如果CC/CR 离开教室, 需要提示一下
                    //如果不是自己, 不是学生
                    qDebug() << "======exitRoom=====" << userId << StudentData::gestance()->m_selfStudent.m_studentId << StudentData::gestance()->m_selfStudent.m_studentAId << __LINE__;
                    if(userId != StudentData::gestance()->m_selfStudent.m_studentId &&
                            userId != StudentData::gestance()->m_selfStudent.m_studentAId)
                    {
                        emit sigEnterOrSync(1003); //提示: 有人离开教室
                    }
                    //<<<=================================

                    //如果是上麦者掉线则弹出开始上课弹窗
                    if(m_JoinMicId.contains(userId))
                    {
                        qDebug() << "======exitRoom====="  << m_JoinMicId << userId << __LINE__;
                        StudentData::gestance()->m_selfStudent.m_listenId = StudentData::gestance()->m_selfStudent.m_studentId;
                        StudentData::gestance()->removeOnlineId(userId);//
                        sigUpdateUserStatus();//更新教室内成员状态

                        //且如果学生在线
                        if(StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId))
                        {
                            emit sigListenMicophone(); //提示: 老师已退出教室, CC 是否继续上课
                        }
                        return;
                    }

                    //旧逻辑
                    qDebug() << "======exitRoom=====" << StudentData::gestance()->m_selfStudent.m_studentAId << userId <<__LINE__;
                    if(StudentData::gestance()->m_selfStudent.m_studentAId == userId && m_JoinMicId.contains(StudentData::gestance()->m_selfStudent.m_studentId))
                    {
                        TemporaryParameter::gestance()->m_isStartClass = false;
                        StudentData::gestance()->removeOnlineId(userId);
                        emit sigExitRoomIds(userId);
                    }

                    //================================= >>>
                    StudentData::gestance()->removeOnlineId(userId);
                    sigUpdateUserStatus();//更新教室内成员状态
                    qDebug() << "======exitRoom22=====" << StudentData::gestance()->m_plat << StudentData::gestance()->m_onlineId << StudentData::gestance()->m_selfStudent.m_studentAId << userId <<__LINE__;
                    //如果当前程序, 自己现在是CC, 此时, 老师退出教室(当前程序会提示: 老师已退出, 学生停留在教室, 是否立即开始与学生沟通?)
                    //如果此时, 学生也跟着马上退出教室, 需要隐藏对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
                    //1. 自己是CC   2. 学生退出教室
                    if(StudentData::gestance()->m_plat == "L" &&
                            !StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId))
                    {
                        qDebug() << "======exitRoom22=====" << __LINE__;
                        emit sigDisapperListenMicophone(); //隐藏对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
                    }
                    //<<<=================================
                }
                else if(command == "changeAudio")
                {
                    m_supplier = contentValue.toObject().take("supplier").toString();
                    m_videoType = contentValue.toObject().take("videoType").toString();
                    TemporaryParameter::gestance()-> m_tempSupplier = TemporaryParameter::gestance()->m_supplier;
                    TemporaryParameter::gestance()->m_supplier = m_supplier;
                    TemporaryParameter::gestance()->m_videoType = m_videoType;
                    emit sigEnterOrSync(61); //改变频道跟音频 频道
                }
                else if(command == "enterFailed")
                {
                    //信息上报
                    QJsonObject obj;
                    obj.insert("result","0");
                    obj.insert("errMsg",contentValue.toObject().take("reason").toString());
                    YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);

                    emit sigEnterOrSync(0);
                }
                else if(command == "startClass")
                {
                    QString totalTime = contentValue.toObject().take("totalTime").toString();
                    QString userId = contentValue.toObject().take("userId").toString();

                    //==================================
                    //使用startClass的response中的user id比较
                    //判断当前是否是持麦者, 来控制"开始上课"/"继续上课"的状态
                    qDebug() << "***************888========" << userId << __LINE__;
                    if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
                    {
                        emit sigSetStartClassStatus(1); //自己是持麦者
                    }
                    else
                    {
                        emit sigSetStartClassStatus(0); //自己是旁听
                    }

                    //==================================
                    //QString supplieras = contentValue.toObject().take("supplier").toString();
                    //QString videoTypeas = contentValue.toObject().take("videoType").toString();
                    //qDebug() << "SocketHandler::parseMsg::startClass>>" << supplieras << videoTypeas;
                    //TemporaryParameter::gestance()->m_supplier = supplieras;
                    //TemporaryParameter::gestance()->m_videoType = videoTypeas;
                    TemporaryParameter::gestance()->m_isStartClass = true;
                    TemporaryParameter::gestance()->m_isAlreadyClass = true;
                    m_response = true;

                    QString stuId = StudentData::gestance()->m_selfStudent.m_studentAId;
                    QString teaId = StudentData::gestance()->m_teacher.m_teacherId;

                    //学生在线并且是持麦者的时候发送响应上麦请求
                    if(StudentData::gestance()->m_onlineId.contains(stuId) && StudentData::gestance()->m_plat == "T")
                    {
                        emit sigJoinMicCommand();
                    }

                    qDebug() << "===stuId==="<< StudentData::gestance()->m_onlineId << stuId << teaId << StudentData::gestance()->m_plat;
                    if(StudentData::gestance()->m_onlineId.contains(stuId) && StudentData::gestance()->m_onlineId.contains(teaId))//StudentData::gestance()->m_plat.contains("T"))
                    {
                        QPair<QString, QString> pairStatus("1", "1");
                        StudentData::gestance()->m_cameraPhone.insert(stuId, pairStatus);
                        qDebug() << "***************888========" << stuId;
                        emit sigStartClassTimeData(totalTime);
                    }

                    if(TemporaryParameter::gestance()->avPlaySetting.isHasSynchronize == false
                            && TemporaryParameter::gestance()->avPlaySetting.m_controlType == "play")
                    {
                        //同步播放时间
                        qDebug() << "avPlaySetting::" << TemporaryParameter::gestance()->avPlaySetting.m_avType << TemporaryParameter::gestance()->avPlaySetting.m_avType;
                        TemporaryParameter::gestance()->avPlaySetting.m_startTime = QString::number(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.playTime).secsTo(QDateTime::fromMSecsSinceEpoch(TemporaryParameter::gestance()->avPlaySetting.currentTime)) + TemporaryParameter::gestance()->avPlaySetting.m_startTime.toInt() );
                        emit sigAvUrl(TemporaryParameter::gestance()->avPlaySetting.m_avType, TemporaryParameter::gestance()->avPlaySetting.m_startTime, TemporaryParameter::gestance()->avPlaySetting.m_controlType, TemporaryParameter::gestance()->avPlaySetting.m_avUrl );
                        TemporaryParameter::gestance()->avPlaySetting.isHasSynchronize = true;
                    }
                    //同步上课时间
                    emit sigStartClassTimeData(totalTime);

                    //第一次开课
                    clearRecord();
                    emit sigAuthtrail(m_userBrushPermissions);
                }
                else if(command == "disconnect")
                {
                    QString userId = contentValue.toObject().take("userId").toString();

                    //if(userId == StudentData::gestance()->m_selfStudent.m_studentId)
                    qDebug() << "SocketHandler::SocketHandler121" << userId << StudentData::gestance()->m_selfStudent.m_studentAId << StudentData::gestance()->m_selfStudent.m_studentId << __LINE__;
                    if(userId != StudentData::gestance()->m_selfStudent.m_studentAId)
                    {
                        qDebug() << "SocketHandler::SocketHandler121" << __LINE__;
                        return;
                    }

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
                            TemporaryParameter::gestance()->m_phoneVersion[userId] = appVersion;

                            // 判断除自己之外的成员(学生、旁听)的腾讯SDK版本，只要其中有一个是1.8.2，则使用老版本SDK
                            if(userId != StudentData::gestance()->m_selfStudent.m_studentId)
                            {
                                QString qqvoiceVersion = values.toObject().take("qqvoiceVersion").toString();
                                if(qqvoiceVersion == "1.8.2")
                                {
                                    TemporaryParameter::gestance()->m_qqVoiceVersion = qqvoiceVersion;
                                    if(TemporaryParameter::gestance()->m_isUsingTencentV2)// 如果正在使用V2通道，则切换为V1通道
                                    {
                                        emit sigChangedV2ToV1();
                                    }
                                }
                            }

                            QString userType = values.toObject().take("userType").toString();

                            StudentData::gestance()->m_userTypeInfo.insert(userId,userType);
                            sigUpdateUserStatus();//更新教室内成员状态
                            if("student_A" == userType)
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

                                if(tVersion.toInt() < lowestInsertHomeWorkCode)
                                {
                                    sigCancleInsertHomeWork();
                                }

                                if(StudentData::gestance()->tempRecordVersion != "")//已经开过课
                                {
                                    if(StudentData::gestance()->tempRecordVersion == oldRecordVersion)
                                    {
                                        emit sigStudentAppversion(false, false);
                                        StudentData::gestance()->setCouldUseNewBoard(false);
                                    }else
                                    {
                                        emit sigStudentAppversion(true, true);
                                        StudentData::gestance()->setCouldUseNewBoard(true);
                                        //判断学生是否更换过版本 如果换到低版本 提示版本过低
                                        if(tVersion.toInt() < lowestNewBoardCode)
                                        {
                                            sigStuChangeVersionToOld();
                                        }
                                    }
                                }else if(StudentData::gestance()->tempRecordVersion == ""  )
                                {
                                    //没上过课根据A学生当前的版本是否支持16:9来判断
                                    if(tVersion.toInt() >= lowestNewBoardCode)
                                    {
                                        emit sigStudentAppversion(true, true);//支持16:9新模式
                                        StudentData::gestance()->setCouldUseNewBoard(true);
                                        StudentData::gestance()->tempRecordVersion = newRecorderVersion;
                                    }else
                                    {
                                        StudentData::gestance()->setCouldUseNewBoard(false);
                                        emit sigStudentAppversion(false, false);
                                        StudentData::gestance()->tempRecordVersion = oldRecordVersion;
                                    }
                                }
                            }
                        }

                    }

                }
                else if(command == "changeCmd") //在ERP系统中, 切换ABC通道的指令(只有老师端, 才有, 学生 + 旁听, 随老师切换)
                {
                    QString cmd =  contentValue.toObject().take("cmd").toString();
                    QString cmdData = contentValue.toObject().take("data").toString();
                    QString cmdPort = contentValue.toObject().take("port").toString();
                    if(cmd == "server")
                    {
                        //信息上报
                        QJsonObject socketJsonObj;
                        socketJsonObj.insert("currentSocketIp",StudentData::gestance()->m_address);
                        StudentData::gestance()->m_tempAddress = StudentData::gestance()->m_address;
                        m_isServerChangeIp = true;
                        //切换服务器
                        StudentData::gestance()->m_address = cmdData;//contentValue.toObject().take("data").toString();
                        StudentData::gestance()->m_port = cmdPort.toInt();//contentValue.toObject().take("port").toString().toInt()
                        TemporaryParameter::gestance()->enterRoomStatus = "C";
                        socketJsonObj.insert("doChangeSocketIp",StudentData::gestance()->m_address);
                        YMQosManager::gestance()->addBePushedMsg("changeSocketNetwork", socketJsonObj);
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
                    qDebug() << "changeCmd" << cmd << cmdData << cmdPort;
                }
                else if (command == "kickOut")
                {
                    //emit sigEnterOrSync(88);//账号在其他地方登录 被迫下线
                    qDebug() << QStringLiteral("账号在其他地方登录 被迫下线");
                }else if(command == "c2cDelay")
                {
                    QJsonObject obj;
                    obj.insert("socketIp",StudentData::gestance()->m_address);
                    obj.insert("tea_s",contentValue.toObject().take("tea_s"));
                    obj.insert("server_s",contentValue.toObject().take("server_s"));
                    obj.insert("stu",contentValue.toObject().take("stu"));
                    obj.insert("server_r",contentValue.toObject().take("server_r"));
                    qint64 timeDifference = YMQosManager::gestance()->getTimeDifference();
                    obj.insert("tea_r",QString::number(QDateTime::currentMSecsSinceEpoch() + timeDifference));
                    YMQosManager::gestance()->addBePushedMsg("c2cCircleDelay",obj);
                }
                else if(command == "startFailed")
                {
                    QString startUser = contentValue.toObject().take("startUser").toString();//正在上课的用户Id
                    emit sigStartLessonFail(startUser);
                }
                else if(command == "currentVideoSpanResponse")// 腾讯V2新增
                {
                    //TemporaryParameter::gestance()->videoSpan = contentValue.toObject().take("videoSpan").toString();
                    emit sigVideoSpan(contentValue.toObject().take("videoSpan").toString());
                    //qDebug()<<"############### parseMsg videoSpan#############################"<<contentValue.toObject().take("videoSpan").toString();
                }
            }
            else if (domain == "draw")
            {
                if(command == "questionAnswerFailed")//接收到提交作业失败信号
                {
                    emit sigQuestionAnswerFailed();
                }
                if(command == "lessonPlan") //老师\CC, 切换到: 新讲义的时候, 会受到这条命令, 学生没有切换讲义的权限, 只有老师/CC, 才有
                {
                    qDebug() << "=====contentObj======" << contentValue;
                    QString planId = contentValue.toObject().take("planId").toString();
                    QJsonArray columnsArray = contentValue.toObject().take("columns").toArray();
                    QString columnId;
                    for(int i = 0; i < columnsArray.size(); i++)
                    {
                        QJsonObject columnObj =  columnsArray.at(i).toObject();
                        columnId = columnObj.value("columnId").toString();
                        break;
                    }
                    QString lessonId = jsonObj.value("lessonId").toString();
                    qDebug()<< "===lessonId>>===" << lessonId << planId << columnId;
                    emit sigPlanChange(lessonId.toLong(), planId.toLong(), columnId.toLong());
                }
                if(command == "questionAnswer")
                {
                    QString questionId = contentValue.toObject().take("questionId").toString();
                    QString planId = contentValue.toObject().take("planId").toString();
                    QString columnId = contentValue.toObject().take("columnId").toString();
                    long lessonId = jsonObj.value("lessonId").toString().toLong();
                    qDebug() << "===questionAnswer===" << questionId << planId << columnId << lessonId;
                    setCurrentQuestionStatus(false);
                    emit sigAnalysisQuestionAnswer(lessonId, questionId, planId, columnId);
                    return;
                }
                if(command.contains("answerPicture"))
                {
                    QJsonObject imgPhotosObj = jsonObj.take("content").toObject();
                    qDebug()  << "****imgPhotosObj*******" << imgPhotosObj << jsonObj.take("content");
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
                    drawCurrentPageData(getCurrentCourseId(),getCurrentCourseCurrentIndex());
                }
                else
                {
                    //画一笔
                    qDebug() << "=====draw::Line======";
                    emit sigDrawLine(msg);
                }
            }
            else if (domain == "page")
            {
                excuteMsg(msg, fromUser);
                //画一页
                drawCurrentPageData(getCurrentCourseId(), getCurrentCourseCurrentIndex());
            }
            else if (domain == "auth")
            {
                if(command == "gotoPageRequest" )
                {
                    if(m_JoinMicId != StudentData::gestance()->m_selfStudent.m_studentId)
                    {
                        return;
                    }
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_userId = userId ;
                    m_isGotoPageRequst = true;
                    sigSendUserId(userId);
                    emit  sigEnterOrSync(8);
                }
                else if(command == "exitRequest")
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    //qDebug() << "exitRoom::enterRoomRequest:" << userId << StudentData::gestance()->m_plat << m_JoinMicId << StudentData::gestance()->m_selfStudent.m_studentAId;
                    if(StudentData::gestance()->m_selfStudent.m_studentAId != userId)
                    {
                        return;
                    }

                    TemporaryParameter::gestance()->m_exitRequestId = userId;
                    if(m_JoinMicId.contains(StudentData::gestance()->m_selfStudent.m_studentId))//如果是上麦者, 则弹出退出学生消息提醒, "申请退出教室"
                    {
                        emit sigSendUserId(userId);
                        emit sigEnterOrSync(10); //"申请退出教室"
                    }
                }
                else if(command == "finishReq")   //申请结束课程
                {
                    QString userId = contentValue.toObject().take("userId").toString();
                    TemporaryParameter::gestance()->m_exitRequestId = userId;
                    qDebug() << "finishResp::userId" << userId;
                    //如果当前是持麦者则弹出申请结束课程弹窗
                    if(m_JoinMicId.contains(StudentData::gestance()->m_selfStudent.m_studentId))
                    {
                        emit sigSendUserId(userId);
                        emit sigEnterOrSync(50);
                    }
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
                    qDebug() << "========enterRoom===" << userId << StudentData::gestance()->m_selfStudent.m_studentId;
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
                    if(StudentData::gestance()->m_plat == "L" && TemporaryParameter::gestance()->m_isStartClass)
                    {
                        return;
                    }
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
                    if(StudentData::gestance()->m_plat == "L" && TemporaryParameter::gestance()->m_isStartClass)
                    {
                        return;
                    }
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
                else if(command.contains("smReq"))//申请上麦权限
                {
                    int auth = contentValue.toObject().take("auth").toString().toInt();
                    QString userId = contentValue.toObject().take("userId").toString();
                    qDebug() << "=====smReq=====" << userId;
                    if(StudentData::gestance()->m_selfStudent.m_studentId != userId)
                    {
                        StudentData::gestance()->m_selfStudent.m_listenId = contentValue.toObject().take("userId").toString();
                        emit sigRequestMicrophone(auth,userId);
                    }
                    return;
                }
                else if(command.contains("smResp"))// 响应是否同意上麦权限
                {
                    int auth = contentValue.toObject().take("auth").toString().toInt();
                    QString userId = contentValue.toObject().take("userId").toString();
                    qDebug() << "=====smResp=====" << userId << StudentData::gestance()->m_selfStudent.m_studentId;
                    if(StudentData::gestance()->m_selfStudent.m_studentId.contains(userId))
                    {
                        //信息上报
                        QJsonObject connectMicrophoneObj;
                        connectMicrophoneObj.insert("socketip",StudentData::gestance()->m_address);
                        connectMicrophoneObj.insert("groupId",YMQosManager::gestance()->getJoinMicActionId());
                        if(auth == 1)
                        {
                            qDebug() << "=====smResp=====" << userId << __LINE__;
                            //StudentData::gestance()->m_selfStudent.m_listenId = contentValue.toObject().take("userId").toString();
                            StudentData::gestance()->m_plat = "T";//收到同意上麦则变成老师，权限是可以操作工具栏
                            AudioVideoManager::getInstance()->openLocalAudio();
                            if(StudentData::gestance()->m_selfStudent.m_studentId == StudentData::gestance()->m_teacher.m_teacherId)
                            {
                                AudioVideoManager::getInstance()->openLocalVideo();
                            }
                            sigUpdateUserStatus();//更新教室内成员状态

                            YMQosManager::gestance()->addBePushedMsg("connectMicrophoneFinished", connectMicrophoneObj);
                        }else
                        {
                            connectMicrophoneObj.insert("msg",QStringLiteral("拒绝上麦"));
                            YMQosManager::gestance()->addBePushedMsg("connectMicrophoneFailed", connectMicrophoneObj);
                        }

                        if(StudentData::gestance()->m_selfStudent.m_studentId == userId)
                        {
                            emit sigReponseMicrophone(auth);
                        }
                    }
                    else
                    {
                        //不是持麦者
                        //OperationChannel::gestance()->setUserPhone(userId, 0);
                        if(auth == 1)
                        {
                            qDebug() << "=====smResp=====" << userId << __LINE__;
                            StudentData::gestance()->m_plat = "L";
                            m_JoinMicId = userId;//上麦者的Id
                            StudentData::gestance()->m_JoinMicId = m_JoinMicId;
                            sigOtherGetMicOrder();
                        }
                        sigUpdateUserStatus();//更新教室内成员状态

                    }
                    return;
                }else if(command == "upperMic")
                {
                    QString userId = contentValue.toObject().take("uid").toString();
                    QString msgType = contentValue.toObject().take("type").toString();
                    QString ret = contentValue.toObject().take("ret").toString();
                    qDebug()<<"upperMicdddddddddddd"<<StudentData::gestance()->m_selfStudent.m_studentId<<userId;
                    //判断是否是cc
                    if(StudentData::gestance()->m_selfStudent.m_studentId == userId && msgType == "1")
                    {//cc
                        //显示是否上麦的弹窗
                        sigShowCCWhetherHoldMicView(ret.toInt());
                    }else if( msgType == "2" && StudentData::gestance()->m_selfStudent.m_studentId == StudentData::gestance()->m_teacher.m_teacherId)
                    {//老师
                        //处理cc是否上麦的响应  这里只处理 弹窗  具体上麦操作用 会发smResp命令 上麦操作在smResp中操作
                        sigHideTeaWaitHandMicView(ret.toInt());

                        if(ret.toInt() == 1)
                        {
                            m_JoinMicId = userId;//上麦者的Id
                            StudentData::gestance()->m_JoinMicId = m_JoinMicId;
                            if(m_JoinMicId == StudentData::gestance()->m_selfStudent.m_studentId)
                            {
                                StudentData::gestance()->m_plat = "T";
                            }else
                            {
                                StudentData::gestance()->m_plat = "L";
                            }
                            sigUpdateUserStatus();//更新教室内成员状态
                        }
                    }
                }
            }
            else if (domain == "control")
            {
                if(command.contains("reportFinished"))
                {
                    sigReportFinished();//改变试听课报告的状态
                }

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
                    //QString delay = infos.take("delay").toString();//查看学生网络状态属性，待定

                    if(infos.value("ishideapp").toString() == "1")
                    {
                        //qDebug() << "settinginfo:" << userId;
                        emit sigSendUserId(userId);
                        emit sigEnterOrSync(52); //提示: 学生没有好好在上课, Android, IOS 设备上, 把app最小化了的时候
                    }
                    qDebug() << "========aaaaaaaaaa==========" << userId << camera << microphone << StudentData::gestance()->m_cameraPhone << __LINE__;

                    //============================ >>>
                    bool bShowCameraMsg = true;
                    bool bShowMicMsg = true;

                    //比较本地记录的学生摄像头, 麦克风的状态, 如果和接口传过来的一样(都是关闭状态的), 那就不再提示Tool Tips: 某某学生 关闭本地摄像头
                    QPair<QString, QString> currentStatus = StudentData::gestance()->m_cameraPhone[userId];
                    QString strLocalCameraStatus = currentStatus.first; //得到本地记录的学生摄像头的状态
                    if(strLocalCameraStatus == camera)
                    {
                        bShowCameraMsg = false;
                    }
                    QString strLocalPhoneStatus = currentStatus.second; //得到本地记录的学生麦克风的状态
                    if(strLocalPhoneStatus == microphone)
                    {
                        bShowMicMsg = false;
                    }
                    //<<< ============================

                    QPair<QString, QString> pairStatus(camera, microphone);
                    StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
                    qDebug() << "====settinginfo======" << StudentData::gestance()->m_cameraPhone << userId << camera << microphone;
                    emit sigUserIdCameraMicrophone( userId, camera, microphone, bShowCameraMsg, bShowMicMsg);
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
                    double zoomRate = contentValue.toObject().take("zoomRate").toString().toDouble();
                    emit sigZoomInOut(0.0, offsetY, zoomRate);
                    setCurrentCursorOffsetY(offsetY);
                    emit sigOffsetY(offsetY);
                    qDebug() << "=========offsetY========" << offsetY;
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

                    if(StudentData::gestance()->m_plat == "L")
                    {
                        emit sigIsOpenAnswer(true, questionId, childQuestionId);
                    }

                    emit sigIsOpenAnswer(true, questionId, childQuestionId); //学生也会发这个消息, 比如: 切换: 经典例题中, 答案解析的1234567的时候, 正确答案的内容, 没有随着更新
                }
                else if(command.contains("openCorrect"))  //打开批改
                {
                    emit sigIsOpenCorrect(true);
                }
                else if(command.contains("correct"))  //老师的批改, 和CC之间, 同步
                {
                    emit sigCorrect(contentValue);
                }
                else if(command.contains("closeCorrect"))  //关闭批改
                {
                    emit sigIsOpenCorrect(false);
                }
                else if(command.contains("changeAudioResponse")) //学生端切换通道成功失败反馈
                {
                    QString responseStatus = contentValue.toObject().take("responseStatus").toString();
                    if( responseStatus == "0" )//responseStatus 为0时 切换通道失败 切换为原来的通道 1时成功
                    {
                        //QString supplier = contentValue.toObject().take("supplier").toString();
                        QString videoType = contentValue.toObject().take("videoType").toString();
                        TemporaryParameter::gestance()->m_supplier = TemporaryParameter::gestance()-> m_tempSupplier;
                        TemporaryParameter::gestance()->m_videoType = videoType;
                        qDebug()<<"changeAudioResponse"<<TemporaryParameter::gestance()->m_supplier<<TemporaryParameter::gestance()->m_videoType;
                        //发信号从新切换
                        getbackAisle();
                    }
                }
            }

        }
    }
    else
    {
        qDebug() << "=====error========" << msg;
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

//超时检测, 并重发
void SocketHandler::checkTimeOut()
{
    if (!m_response && m_lastHBTime.elapsed() > 3000)
    {
        m_lastHBTime.restart();
        m_socket->sendMsg(m_lastSendMsg);
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

            if (!justCourseHasDefaultPage())
            {
                TemporaryParameter::gestance()->m_pageSave.insert(getCurrentCourseId(), getCurrentCourseCurrentIndex());
            }
            addCommonCourse(docId, arr);
            TemporaryParameter::gestance()->m_currentCourse = docId;
        }
        else if (domain == "page" && command == "goto")
        {
            int pageI = contentVal.toObject().take("page").toString().toInt();
            goPageByindex(pageI);
        }
        else if (domain == "page" && command == "insert")
        {
            insertBlankPage();
        }
        else if (domain == "page" && command == "delete")
        {
            deleteCurrentPage();
        }
        else if (domain == "draw" && command == "picture" )
        {
            QString url = contentVal.toObject().take("url").toString();
            double width = contentVal.toObject().take("width").toString().toDouble();
            double height = contentVal.toObject().take("height").toString().toDouble();
            insertPicture(url,width,height);
        } else if (domain == "draw" && command == "pictureReport" )
        {
            QJsonArray imgArry = contentVal.toObject().take("urls").toArray();
            int tempPage = getCurrentCourseCurrentIndex();
            for(int a = 0; a<imgArry.size();a++)
            {
                QString url = imgArry.at(a).toObject().take("imageUrl").toString();
                insertReportPicture(url);
            }
            changeCurrentCursouIndex( ++tempPage );//默认显示第二页
        }
        else if (domain == "auth" && command == "control")
        {
            QString uid = contentVal.toObject().take("userId").toString();
            QString auth = contentVal.toObject().take("auth").toString();
            TemporaryParameter::gestance()->m_userBrushPermissionsId.insert(uid, auth);
            m_userBrushPermissions.insert(uid, auth);
        }
        else if(domain == "auth" && command.contains("smResp"))//同步的时候看看谁是上麦者
        {
            int auth = contentVal.toObject().take("auth").toString().toInt();
            QString userId = contentVal.toObject().take("userId").toString();
            qDebug() << "========auth smResp==========" << userId;
            if(auth == 1)
            {
                m_JoinMicId = userId;//上麦者的Id
                StudentData::gestance()->m_JoinMicId = m_JoinMicId;
                if(m_JoinMicId == StudentData::gestance()->m_selfStudent.m_studentId)
                {
                    StudentData::gestance()->m_plat = "T";
                }else
                {
                    StudentData::gestance()->m_plat = "L";
                }
                sigUpdateUserStatus();//更新教室内成员状态
            }
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
            TemporaryParameter::gestance()-> m_tempSupplier = TemporaryParameter::gestance()->m_supplier;
            TemporaryParameter::gestance()->m_supplier = m_supplier;
            TemporaryParameter::gestance()->m_videoType = m_videoType;
        }
        else if (domain == "draw" &&  (command == "trail" || command == "polygon" || command == "ellipse"))
        {
            //qDebug() << "=======m_currentCourse=========" << getCurrentCourseId();
            addTrailInCurrentPage(fromUser,msg);
        }
        else if (domain == "draw" && command == "undo") //撤销删除对应的当前记录
        {
            qDebug() << "=======sockethandler::fromUser========" << fromUser;
            unDoCurrentTrail(fromUser);
        }
        else if (domain == "draw" && command == "clear")
        {
            clearCurrentPageTrail();
        }
        else if(domain == "draw" && command == "question")
        {
            setCurrentQuestionStatus(true);
            emit sigSynQuestionStatus(true);
            return;
        }
        else if(domain == "draw" && command == "stopQuestion")
        {
            setCurrentQuestionStatus(false);
            emit sigSynQuestionStatus(false);
            return;
        }
        else if(domain == "draw" && command == "lessonPlan")
        {
            QJsonObject contentObj = contentVal.toObject();
            //qDebug() << "=====contentObj======" << contentObj;
            QString planId = contentObj.value("planId").toString();
            QJsonArray columnsArray = contentObj.value("columns").toArray();
            if (!justCourseHasDefaultPage())
            {
                TemporaryParameter::gestance()->m_pageSave.insert(getCurrentCourseId(), getCurrentCourseCurrentIndex());
            }

            //添加结构化课件
            addStructCourse(planId,columnsArray);
            TemporaryParameter::gestance()->m_currentCourse = getCurrentCourseId();
        }
        else if(domain == "draw" && command == "column")
        {
            //qDebug() << "========contentVal========" << contentVal.toObject();
            drawCurrentColumnData(contentVal.toObject());
        }
        else if(domain == "draw" && command == "autoPicture")
        {
            //qDebug() << "==========autoPicture=======" << getCurrentCourseId() << m_pages[getCurrentCourseId()].size();
            QString imageUrl = contentVal.toObject().value("imageUrl").toString();
            double imgWidth = contentVal.toObject().value("imgWidth").toString().toDouble();
            double imgHeight = contentVal.toObject().value("imgHeight").toString().toDouble();
            insertAutoPicture(imageUrl,imgWidth,imgHeight);
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
            //StudentData::gestance()->m_camera = camera;
            //StudentData::gestance()->m_microphone = microphone;
            QPair<QString, QString> pairStatus(camera, microphone);
            StudentData::gestance()->m_cameraPhone.insert(userId, pairStatus);
            qDebug() << "===init::camera===" << StudentData::gestance()->m_cameraPhone;
        }
        else if (domain == "control" && command == "avControl")
        {
            TemporaryParameter::gestance()->avPlaySetting.m_avType = contentVal.toObject().take("avType").toString();
            TemporaryParameter::gestance()->avPlaySetting.m_startTime = contentVal.toObject().take("startTime").toString();
            TemporaryParameter::gestance()->avPlaySetting.m_controlType = contentVal.toObject().take("controlType").toString();
            TemporaryParameter::gestance()->avPlaySetting.m_avUrl = contentVal.toObject().take("avUrl").toString();
            //qDebug()<<"avType =="<<avType<<"startTime =="<<startTime<<"controlType =="<<controlType<<"avUrl =="<<avUrl;
            //emit sigAvUrl(avType,startTime ,controlType ,avUrl );//.replace("\\","=")
        }
        else if(domain.contains("control") && command.contains("zoomInOut"))
        {
            offsetY =  contentVal.toObject().take("offsetY").toString().toDouble();
            setCurrentCursorOffsetY(offsetY);
            return;
        }
        else if(domain == "control" && command == "correct" ) //同步批改
        {
            emit sigCorrect(contentVal);
        }
        else if(domain == "control" && command == "openCorrect" ) //打开批改
        {
            correctViewIsOpen = true;
        }
        else if(domain == "control" && command == "closeCorrect")  //关闭批改
        {
            correctViewIsOpen = false;
        }
    }
    else
    {

    }
}

void SocketHandler::clearRecord()
{
    qDebug() << "SocketHandler::clearRecord" << m_isInit;
    if(!m_isInit)
    {
        m_isInit = true;
        TemporaryParameter::gestance()->m_pageSave.clear();

        setCourseInDefaultStatus();

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
    delete m_socket;
    delete m_sendMsgTask;
}


//网络撤销
void SocketHandler::undo()
{
    QString s("{\"domain\":\"draw\",\"command\":\"undo\",\"content\":{\"pageIndex\":\"" + QString::number(getCurrentCourseCurrentIndex(), 10) + "\"}}");
    sendLocalMessage(s, true, true);
}

//增加某一页
void SocketHandler::addPage()
{
    QString s("{\"domain\":\"page\",\"command\":\"insert\",\"content\":{\"page\":\"" + QString::number(getCurrentCourseCurrentIndex(), 10) + "\"}}");
    sendLocalMessage(s, true, true);
}
//删除某一页
void SocketHandler::deletePage()
{
    if(justCurrentPageIsCourse(getCurrentCourseId(), getCurrentCourseCurrentIndex()))
    {
        emit sigIsCourseWare();
        emit sigEnterOrSync(12);
        return;
    }
    QString s("{\"domain\":\"page\",\"command\":\"delete\",\"content\":{\"page\":\"" + QString::number(getCurrentCourseCurrentIndex(), 10) + "\"}}");
    sendLocalMessage(s, true, true);
}

//到某一页
void SocketHandler::goPage(int pageIndex)
{
    qDebug() << "=====SocketHandler::goPage====="<< getCurrentCourseId() << pageIndex << getCurrentCourseCurrentIndex();
    if( !TemporaryParameter::gestance()->m_isStartClass)
    {
        if (pageIndex < 0 || pageIndex > getCurrentCourseSize() - 1)
        {
            return;
        }
        drawCurrentPageData(getCurrentCourseId(),pageIndex);
        changeCurrentCursouIndex(pageIndex);
        getCurrentColumnData(getCurrentCourseId(),pageIndex);

        //上报当前课件信息
        QString coursewareInfo;
        QJsonObject courseObj;
        courseObj.insert("domain", "system");
        courseObj.insert("command", "statistics");

        QJsonObject contentObJ;
        contentObJ.insert("type", "courseware");

        QJsonObject courwareInfoObj;
        courwareInfoObj.insert("planId", m_currentPlanId);
        courwareInfoObj.insert("clounmId", m_currentColumnId);
        courwareInfoObj.insert("sumPage", QString::number(getCurrentCourseSize()));
        courwareInfoObj.insert("currentPageIndex", QString::number(getCurrentCourseCurrentIndex()));

        contentObJ.insert("courwareInfo", courwareInfoObj);
        courseObj.insert("content", contentObJ);
        coursewareInfo = QString(QJsonDocument(courseObj).toJson(QJsonDocument::Compact));
        this->sendLocalMessage(QString("0#SYSTEM") + coursewareInfo, false, false);

        return;
    }

    if (pageIndex < 0 || pageIndex > getCurrentCourseSize() - 1)
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
    sendLocalMessage(s.arg(QString::number(getCurrentCourseCurrentIndex(), 10).arg(url).arg(QString::number(width, 'f', 6)).arg(QString::number(height, 'f', 6))), true, true);
}

//清屏
void SocketHandler::clearScreen()
{
    QString s("{\"domain\":\"draw\",\"command\":\"clear\",\"content\":{\"page\":\"" + QString::number(getCurrentCourseCurrentIndex(), 10) + "\"}}");
    sendLocalMessage(s, true, true);
}

void SocketHandler::autoChangeIp()
{
    //信息上报
    QJsonObject socketJsonObj;
    socketJsonObj.insert("currentSocketIp",StudentData::gestance()->m_address);
    StudentData::gestance()->m_tempAddress = StudentData::gestance()->m_address;
    qDebug() << "current ip " << StudentData::gestance()->m_address << StudentData::gestance()->m_port << StudentData::gestance()->m_isTcpProtocol;


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
                qDebug() << "位置" << tempHasConnect;
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
        if(currentAutoChangeIpTimes == TemporaryParameter::gestance()->goodIpList.size())
        {
            //qDebug()<<QStringLiteral("全部切换完毕 掉线退出~~~~~~~~~~~  ");
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

    if(isSuccess)
    {
        m_response = true;
    }
    //qDebug() << "TemporaryParameter::gestance()->m_isFinishLesson:" << TemporaryParameter::gestance()->m_isFinishLesson;
    if(TemporaryParameter::gestance()->m_isFinishLesson) //如果是结束课程不进行重连操作
    {
        qDebug() << "===SocketHandler::justChangeIp===";
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
            //记录掉线次数 2次掉线自动切换ip
            ++currentReloginTimes;
            if(currentReloginTimes >= 2)
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
        return;
    }
    else
    {
        //自动连接网络
        emit sigAutoConnectionNetwork();

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
        m_isServerChangeIp = false;

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
        m_socket->sendMsg(m_lastSendMsg);
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
            qDebug() << "位置" << tempHasConnect;
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


void SocketHandler::sendReportImgs(QJsonArray imgarry)
{
    QJsonObject dataObj;
    dataObj.insert("domain", "draw");
    dataObj.insert("command", "pictureReport");

    QJsonObject contentObj;
    contentObj.insert("pageIndex", QString::number(getCurrentCourseCurrentIndex()));
    contentObj.insert("urls", imgarry);
    dataObj.insert("content", contentObj);
    QString commandStr = (QString)QJsonDocument(dataObj).toJson(QJsonDocument::Compact);
    qDebug() << "==TrailBoard::sendReportImgs==" << commandStr;

    int tempPage = getCurrentCourseCurrentIndex();
    sendLocalMessage(commandStr, true, true);

    //翻页
    QString pageStr = QString("{\"domain\":\"page\",\"command\":\"goto\",\"content\":{\"page\":\"" + QString::number( ++tempPage ) + "\"}}");
    sendLocalMessage(pageStr, true, false);
}

void SocketHandler::sendC2cDelay()
{
    qint64 timeDifference = YMQosManager::gestance()->getTimeDifference();
    QString tempString = QString("0#SYSTEM{\"command\":\"c2cDelay\",\"content\":{\"tea_s\":\"%1\"},\"domain\":\"system\"}").arg(QDateTime::currentMSecsSinceEpoch() + timeDifference);
    sendMessage(tempString);
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
    //qDebug() << "***********allDataObj********" << url << reqParm;
    //qDebug() << "=======aaa=========" << allDataObj << key;

    if(allDataObj.value("result").toString().toLower() == "success")
    {
        QString url = allDataObj.value("data").toString();
        qDebug() << "*********url********" << url;
        return url;
    }
    else
    {
        qDebug() << "SocketHandler::getOssSignUrl" << allDataObj;
    }

    return "";
}
#endif

#ifdef USE_OSS_AUTHENTICATION
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
            m_pages[m_currentCourse][m_currentPage].setImageUrl(newImgUrl, model.width, model.height);
            return newImgUrl;
        }
    }
    return imgUrl;
}
#endif

void SocketHandler::drawCurrentPageData(QString currentCourseId, int pageIndex)
{
    MessageModel model = m_pages[currentCourseId][pageIndex];
    model.setPage(m_pages[currentCourseId].size(), pageIndex);
#ifdef USE_OSS_AUTHENTICATION
    model.bgimg = checkOssSign(model.bgimg);
#endif
    currentBeBufferModel.clear();
    currentBeBufferModel = model;
    emit sigOffsetY(model.offsetY);
    emit sigDrawPage(model);

    showCurrentCourseThumbnail();

    //处理当前页需要被发送出去的数据

    bool isLongImg = (getCurrentMsgModel().questionId == "") ? false :  (getCurrentMsgModel().bgimg == ""  ? false : true);

    emit sigSendUrl(getCurrentMsgModel().bgimg, getCurrentMsgModel().width, getCurrentMsgModel().height, isLongImg, getCurrentMsgModel().questionId, getCurrentMsgModel().beShowedAsLongImg);
    qDebug() << "==TrailBoard::drawPage::new=="
             << getCurrentMsgModel().height
             << getCurrentMsgModel().questionId
             << getCurrentMsgModel().offsetY
             << getCurrentMsgModel().bgimg;
    //qDebug() << "=======TrailBoard::drawPage========" <<  getCurrentMsgModel().bgimg << isLongImg  << getCurrentMsgModel().width << getCurrentMsgModel().height << "question:" + getCurrentMsgModel().questionId;



    emit sigChangeCurrentPage(model.getCurrentPage());
    emit sigChangeTotalPage(model.getTotalPage());
}

bool SocketHandler::justCurrentPageIsBlank()
{
    if(getCurrentMsgModel().height == 1 && getCurrentMsgModel().questionId != "" && getCurrentMsgModel().questionId != "-1" && getCurrentMsgModel().questionId != "-2" && getCurrentMsgModel().bgimg != "")
    {
        return false;
    }
    return true;
}

bool SocketHandler::justCurrentPageIsCourse(QString currentCourseId, int pageIndex)
{
    MessageModel model = m_pages[currentCourseId][pageIndex];
    return model.isCourware;
}

void SocketHandler::insertReportPicture(QString imgUrl)
{
    QStringList strList = m_currentCourse.split("|");
    QString questionId = "-2";
    if(strList.size() > 1)
    {
        questionId = "-1";
    }
#ifdef USE_OSS_AUTHENTICATION
    MessageModel model = MessageModel(0, imgUrl, 1, 1, questionId, "0", 0, false, 0);
    model.beShowedAsLongImg = true;
    m_pages[m_currentCourse].insert(++m_currentPage,model);
#else

    MessageModel model = MessageModel(0, imgUrl, 1, 1, questionId, "0", 0, false);
    model.beShowedAsLongImg = true;
    m_pages[m_currentCourse].insert(++m_currentPage,model);
#endif
}

void SocketHandler::getCurrentColumnData(QString currentCourseId, int pageIndex)
{
    QStringList strList = currentCourseId.split("|");
    if(strList.size() > 1)//新课件的时候才发这个信号
    {
        QString planId = strList.at(0);
        QString columnId = strList.at(1);
        MessageModel model = m_pages[currentCourseId][pageIndex];
        m_pageSave.insert(m_currentCourse, m_currentPage);
        emit sigCurrentQuestionId(planId, columnId, model.questionId, model.offsetY, model.questionBtnStatus);
    }
}

void SocketHandler::drawCurrentColumnData(QJsonObject contentObj)
{
    QString columnId = contentObj.value("columnId").toString();
    QString planId = contentObj.value("planId").toString();
    QString docId = planId + "|" + columnId;
    qDebug() << "*********draw::column*********" << planId << columnId;
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
            qDebug() << "******return**********";
            return;

        }

        QString currentQustionId = m_pages[docId].at(m_currentPage).questionId;

        drawCurrentPageData(docId,m_currentPage);

        //qDebug() << "=======draw::column2222=======" << m_currentCourse << m_currentPage << planId << columnId << currentQustionId ;
        if(m_sysnStatus)
        {
            emit sigCurrentQuestionId(planId, columnId, currentQustionId, 0, false);
            showCurrentCourseThumbnail();
        }
        m_currentPlanId = planId;
        m_currentColumnId = columnId;
        m_currentQuestionId = currentQustionId;
        emit sigCurrentColumn(planId.toLong(), columnId.toLong());
    }
}

void SocketHandler::deleteCurrentPage()
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

void SocketHandler::insertBlankPage()
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

void SocketHandler::goPageByindex(int pageIndex)
{
    pageIndex = pageIndex < 0 ? 0 : pageIndex;
    if (pageIndex > m_pages[m_currentCourse].size() - 1)
        pageIndex = m_pages[m_currentCourse].size() - 1;
    m_currentPage = pageIndex;

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

                m_pageSave.insert(m_currentCourse, m_currentPage);
                if(m_sysnStatus)
                {
                    emit sigCurrentQuestionId(planId, columnId, questionId, m_offsetY, m_questionStatus);
                }
            }
        }
    }
}

void SocketHandler::currentCourseDataStatus()
{
    //画一页
    drawCurrentPageData(m_currentCourse, m_currentPage);
    qDebug() << "############m_sysnStatus##############" << m_currentPlanId << m_currentColumnId;
    if(m_currentPlanId == "" && m_currentColumnId == "")
    {
        return;
    }
    emit sigPlanChange(0, m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigCurrentQuestionId(m_currentPlanId, m_currentColumnId, m_currentQuestionId, offsetY, m_currentQuestionButStatus);
    emit sigCurrentColumn(m_currentPlanId.toLong(), m_currentColumnId.toLong());
    emit sigOffsetY(offsetY);
}

int SocketHandler::getCourseCurrentPage(QString courseId)
{
    int currentPage = 1;
    currentPage = m_pageSave.value(courseId, 1);
    qDebug() << "===getCourseCurrentPage=====" << currentPage << m_pages[courseId].size() << m_pageSave.value(courseId, 1);
    return currentPage;
}

void SocketHandler::setCourseInDefaultStatus()
{
    m_pages.clear();
    m_pageSave.clear();

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
    drawCurrentPageData(m_currentCourse,m_currentPage);
}

void SocketHandler::insertPicture(QString url,double width,double height)
{
    QStringList strList = m_currentCourse.split("|");
    QString questionId = "-2";
    if(strList.size() > 1)
    {
        questionId = "-1";
    }
    qDebug() << "=======picture===========" << m_currentCourse << m_currentPage  << url << questionId;
#ifdef USE_OSS_AUTHENTICATION
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, 1.0, 1.0, questionId, "0", 0, false, 0));
#else
    m_pages[m_currentCourse].insert(++m_currentPage, MessageModel(0, url, 1.0, 1.0, questionId, "0", 0, false));

#endif
}

void SocketHandler::addTrailInCurrentPage(QString userId,QString trailMsg)
{
    qDebug()<<"addTrailInCurrentPage"<<userId<<trailMsg<<m_currentPage;
    m_pages[m_currentCourse][m_currentPage].addMsg(userId, trailMsg);
}

void SocketHandler::unDoCurrentTrail(QString userId)
{
    m_pages[m_currentCourse][m_currentPage].undo(userId);
}

void SocketHandler::clearCurrentPageTrail()
{
    m_pages[m_currentCourse][m_currentPage].clear();
}

void SocketHandler::setCurrentQuestionStatus(bool status)
{
    if(status)
    {
        m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(true);
        m_currentQuestionButStatus = true;
    }else
    {
        m_pages[m_currentCourse][m_currentPage].setQuestionButStatus(false);
        m_currentQuestionButStatus = false;
    }
}

void SocketHandler::insertAutoPicture(QString imageUrl, double imgWidth, double imgHeight)
{
    m_pages[m_currentCourse][m_currentPage].bgimg = imageUrl;
    m_pages[m_currentCourse][m_currentPage].width = imgWidth;
    m_pages[m_currentCourse][m_currentPage].height = imgHeight;
    m_pages[m_currentCourse][m_currentPage].questionBtnStatus = false;
    m_pages[m_currentCourse][m_currentPage].setImageUrl(imageUrl, imgWidth, imgHeight);
}

void SocketHandler::setCurrentCursorOffsetY(double yValue)
{
    m_pages[m_currentCourse][m_currentPage].setOffsetY(yValue);
    qDebug() << "=========bufferoffsetY1========" << yValue;
}

void SocketHandler::addCommonCourse(QString courseId, QJsonArray imgArry)
{
    if (m_pages.contains("DEFAULT"))
    {
        m_pages.insert(courseId, m_pages.value("DEFAULT"));
        m_pages.remove("DEFAULT");
        m_currentCourse = courseId;
        m_currentPage = m_pages[m_currentCourse].size();
        for (int i = 0; i < imgArry.size(); ++i)
        {
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false, 0));
#else
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false));
#endif
        }
    }
    else if (!m_pages.contains(courseId))
    {
        QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
        list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
        list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
        m_pages.insert(courseId, list);
        m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = courseId;
        m_currentPage = 1;
        for (int i = 0; i < imgArry.size(); ++i)
        {
#ifdef USE_OSS_AUTHENTICATION
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false, 0));
#else
            m_pages[m_currentCourse].append(MessageModel(1, imgArry.at(i).toString(), 1.0, 1.0, "", "0", 0, false));
#endif
        }
    }
    else
    {
        m_pageSave.insert(m_currentCourse, m_currentPage);
        m_currentCourse = courseId;
        m_currentPage = m_pageSave.value(m_currentCourse, 0);
    }
    m_currentPlanId = courseId;
}

QString SocketHandler::getCurrentCourseId()
{
    return m_currentCourse;
}

int SocketHandler::getCurrentCourseCurrentIndex()
{
    return m_currentPage;
}

bool SocketHandler::justCourseHasDefaultPage()
{
    return m_pages.contains("DEFAULT");
}

void SocketHandler::addStructCourse(QString courseId, QJsonArray columnsArray)
{
    if(columnsArray.size() <= 0)
    {
        m_currentPage = 1;
        return;
    }
    QString tempCourseId  = "0";
    for(int i = 0; i < columnsArray.size(); i++)
    {
        QJsonObject columnObj = columnsArray.at(i).toObject();
        QString columnId = columnObj.value("columnId").toString();
        QJsonArray questionsArray = columnObj.value("questions").toArray();
        QString docId = courseId + "|" + columnId;
        if(i == 0 )
        {
            tempCourseId = docId;
        }
        if (m_pages.contains("DEFAULT"))
        {
            m_pages.insert(docId, m_pages.value("DEFAULT"));
            m_pages.remove("DEFAULT");
            m_currentCourse = docId;
            m_currentPage = m_pages[m_currentCourse].size();
            for(int z = 0; z < questionsArray.size(); z++)
            {
                QString questionId = questionsArray.at(z).toString();
#ifdef USE_OSS_AUTHENTICATION
                m_pages[m_currentCourse].append(MessageModel(1, getAllStructImgByid(m_currentCourse,questionId), 1.0, 1.0, questionId, columnId, 0, false, 0));
#else
                MessageModel tempModel = MessageModel(1, getAllStructImgByid(m_currentCourse,questionId), 1.0, 1.0, questionId, columnId, 0, false);
                QString courseContent = getAllStructTitleByid(m_currentCourse,questionId);
                if(courseContent != "")
                {
                    hasRegetContentSuccess = true;
                }
                tempModel.addCourseContent(courseContent);
                m_pages[m_currentCourse].append(tempModel);
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
            m_pageSave.insert(m_currentCourse, m_currentPage);
            m_currentCourse = docId;
            m_currentPage = 1;
            for(int z = 0; z < questionsArray.size(); z++)
            {
                QString questionId = questionsArray.at(z).toString();
#ifdef USE_OSS_AUTHENTICATION
                m_pages[m_currentCourse].append(MessageModel(1, getAllStructImgByid(m_currentCourse,questionId), 1.0, 1.0, questionId, columnId, 0, false, 0));
#else
                MessageModel tempModel = MessageModel(1, getAllStructImgByid(m_currentCourse,questionId), 1.0, 1.0, questionId, columnId, 0, false);
                QString courseContent = getAllStructTitleByid(m_currentCourse,questionId);
                if(courseContent != "")
                {
                    hasRegetContentSuccess = true;
                }
                tempModel.addCourseContent(courseContent);
                m_pages[m_currentCourse].append(tempModel);

#endif
            }
        }
        else
        {
            m_pageSave.insert(m_currentCourse, m_currentPage);
        }
    }
    m_currentCourse = tempCourseId;
}

int SocketHandler::getCurrentCourseSize()
{
    return m_pages[m_currentCourse].size();
}

int SocketHandler::getDefaultCourseSize()
{
    return m_pages.value("DEFAULT").size();
}

void SocketHandler::initDefaultCourse()
{
#ifdef USE_OSS_AUTHENTICATION
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);
#endif

    QList<MessageModel> list;
#ifdef USE_OSS_AUTHENTICATION
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0));
#else
    list.append(MessageModel(0, "", 1.0, 1.0, "", "0", 0, false));
#endif
    m_pages.insert("DEFAULT", list);
}

void SocketHandler::changeCurrentCursouIndex(int indexs)
{
    m_currentPage = indexs;
}

MessageModel SocketHandler::getCurrentMsgModel()
{
    return currentBeBufferModel;
}

void SocketHandler::addTrailInCurrentBufferModel(QString userId,QString trailMsg)
{
    currentBeBufferModel.addMsg(userId,trailMsg);
}

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

void SocketHandler::showCurrentCourseThumbnail()
{
    qDebug()<<"SocketHandler::showCurrentCourseThumbnail():  "<<m_currentCourse<<StudentData::gestance()->allCoursewareData.size();
    if(m_currentCourse != "DEFAULT")
    {
        QJsonArray imgArray;
        QJsonArray contentArray;
        bool couldShowImg = true;
        for(int a = 0; a < m_pages[m_currentCourse].size(); a++)
        {
            if(!hasRegetContentSuccess && m_pages[m_currentCourse].at(a).questionId != "" && m_pages[m_currentCourse].at(a).bgimg == "" && reGetCourseTimes < 3 )
            {
                couldShowImg = false;
                if(m_reGetCourseImgTask->isActive() == false)
                {
                    m_reGetCourseImgTask->start();
                }
                break;
            }
            imgArray.append(m_pages[m_currentCourse].at(a).bgimg);
            MessageModel tempModel = m_pages[m_currentCourse].at(a);
            contentArray.append(tempModel.getCourseContent());
        }
        if(couldShowImg)
        {
            emit sigShowAllCourseImg(imgArray,contentArray,m_currentCourse);
        }
    }
}

void SocketHandler::reGetCourseImg()
{
    qDebug()<<"SocketHandler::reGetCourseImg()";
    reGetCourseTimes ++;

    m_reGetCourseImgTask->stop();

    QMap<QString, QList<MessageModel> >::Iterator  it = m_pages.begin();

    while(it != m_pages.end())
    {
        QList<MessageModel> tempListModel = m_pages[it.key()];
        for(int a = 0; a < m_pages[it.key()].size(); a++)
        {
            if(!QString(it.key()).contains("|"))
            {
                break;
            }
            if(tempListModel.at(a).questionId != "" && tempListModel.at(a).questionId != "-1")
            {
                QString tempImgUrl = getAllStructImgByid(it.key(),tempListModel.at(a).questionId);
                QString courseContent = getAllStructTitleByid(it.key(),tempListModel.at(a).questionId);
                if(tempImgUrl == "")
                {
                    tempImgUrl = tempListModel.at(a).bgimg;
                }
                MessageModel tempModel = MessageModel(1,tempImgUrl, 1.0, 1.0, tempListModel.at(a).questionId, tempListModel.at(a).columnType, 0, tempListModel.at(a).questionBtnStatus);
                tempModel.addCourseContent(courseContent);
                if(courseContent != "")
                {
                    hasRegetContentSuccess = true;
                }
                m_pages[it.key()].replace(a,tempModel);
            }
        }
        it++;
    }

    showCurrentCourseThumbnail();
}

QString SocketHandler::getAllStructImgByid(QString courseId,QString questionId)
{
    qDebug()<<"getAllStructImgByid"<<courseId<<questionId<<StudentData::gestance()->allCoursewareData.size();
    if(courseId.contains("|"))
    {
        long columnId = QString(courseId.split("|").at(1)).toLong();
        if(StudentData::gestance()->allCoursewareData.contains(columnId))
        {
            return StudentData::gestance()->allCoursewareData.value(columnId).value(questionId).value("baseImage").toObject().value("imageUrl").toString();
        }
    }
    return "";
}

QString SocketHandler::getAllStructTitleByid(QString courseId,QString questionId)
{
    if(courseId.contains("|"))
    {
        long columnId = QString(courseId.split("|").at(1)).toLong();
        if(StudentData::gestance()->allCoursewareData.contains(columnId))
        {
            return StudentData::gestance()->allCoursewareData.value(columnId).value(questionId).value("content").toString();
        }
    }
    return "";
}
