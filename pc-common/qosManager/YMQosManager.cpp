#include "YMQosManager.h"
#include <QStandardPaths>
#include <QCoreApplication>

/*
*qos 数据传输类
*/

YMQosManager::YMQosManager(QObject *parent)
    : QObject(parent)
{
    httpAccessmanger = new QNetworkAccessManager(this);
    connect(httpAccessmanger,SIGNAL(finished(QNetworkReply*)),this,SLOT(onPushMsgToServerReply(QNetworkReply*)));

    timeoutTimer = new QTimer(this);
    timeoutTimer->setInterval(10000);
    timeoutTimer->setSingleShot(true);

    findDataTimer = new QTimer(this);
    findDataTimer->setInterval(200);
    findDataTimer->setSingleShot(true);
    connect(findDataTimer,SIGNAL(timeout()),this,SLOT(checkPushMsgToServe()));
    findDataTimer->start();

    m_accessManager = new QNetworkAccessManager(this);
    getServerDateTime();

}

YMQosManager::~YMQosManager()
{

}

void YMQosManager::initQosManager(QString initData,QString userType)
{
    getBePushedUrl();
    getDeviceInfo();
    getLocalBufferMsg();
    currentUserType = userType;
    QStringList jsonStringList = initData.split("###");
    if(jsonStringList.size() < 2)
    {
        basicJsonData = getBasicJsonData();
        return;
    }
    QJsonParseError errors;
    QJsonDocument documets = QJsonDocument::fromJson(jsonStringList.at(0).toUtf8(), &errors);
    if(errors.error == QJsonParseError::NoError)
    {
        roomMemberInformationObj = documets.object().value("data").toObject();
    }
    documets = QJsonDocument::fromJson(jsonStringList.at(1).toUtf8(), &errors);
    if(errors.error == QJsonParseError::NoError)
    {
        selfInformationObj = documets.object();
    }
    basicJsonData = getBasicJsonData();
}

void YMQosManager::addBePushedMsg(QString msgHeaderType, QJsonObject msgData)
{
    QString tempMsg = getPushMsg(msgHeaderType,msgData);
    QJsonParseError errors;
    QJsonDocument::fromJson(tempMsg.toLatin1(), &errors);
    if(errors.error == QJsonParseError::NoError && !msgBufferList.contains(tempMsg))
    {
        msgBufferList.append(tempMsg);
    }
    //qDebug()<<"msgBufferList"<<msgBufferList;
}

void YMQosManager::pushMsgToServer(QByteArray msg)
{
    QNetworkRequest httpRequest;

    httpRequest.setUrl(QUrl(pushUrl));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);

    timeoutTimer->stop();

    httpAccessmanger->post(httpRequest, msg);
    timeoutTimer->start();
}

QString YMQosManager::getPushMsg(QString msgHeaderType, QJsonObject msgData)
{
    QJsonObject msgObj;
    QJsonObject dataObj = basicJsonData;
    if("XBKCloudClassroom_teacher_click_feedback" == msgHeaderType)
    {
        msgObj.insert("msgType","XBKCloudClassroom_teacher_click_feedback");
        dataObj.insert("lessonId",msgData.value("lessonId"));
        dataObj.insert("socketIp",msgData.value("socketIp"));
        dataObj.insert("className",msgData.value("className"));
        dataObj.insert("help_user",msgData.value("help_user"));
        dataObj.insert("help_content",msgData.value("help_content"));
    }
    else if("XBKCloudClassroom_student_click_feedback" == msgHeaderType)
    {
        msgObj.insert("msgType","XBKCloudClassroom_student_click_feedback");
        dataObj.insert("lessonId",msgData.value("lessonId"));
        dataObj.insert("socketIp",msgData.value("socketIp"));
        dataObj.insert("className",msgData.value("className"));
        dataObj.insert("help_user",msgData.value("help_user"));
        dataObj.insert("help_content",msgData.value("help_content"));
    }
    else if("lessonBaseInfo" == msgHeaderType)//roleType
    {
        //进教室时上报
        //msgObj.insert("msgType","lessonBaseInfo");//enterClassroomFinished
        msgObj.insert("msgType","enterClassroomFinished");
        dataObj.insert("lessonType",QString::number(roomMemberInformationObj.value("lessonType").toInt()));
        dataObj.insert("lessonPlanStartTime",roomMemberInformationObj.value("startTime").toString());
        dataObj.insert("lessonPlanEndTime",roomMemberInformationObj.value("endTime").toString());
        dataObj.insert("appVersion",selfInformationObj.value("appVersion").toString());
        if(msgData.value("api_name").toString() != "")
        {
            dataObj.insert("api_name",msgData.value("api_name"));
        }
        if(msgData.value("server_ip").toString() != "")
        {
            dataObj.insert("server_ip",msgData.value("server_ip"));
        }
        //外围传的数据
        dataObj.insert("result",msgData.value("result"));//1成功/0失败
        dataObj.insert("errMsg",msgData.value("errMsg"));//成功/错误消息
         if(msgData.value("result").toInt() == 0)
        {
            dataObj.insert("errType",msgData.value("errType"));
        }

    }else if("network" == msgHeaderType)//
    {
        //切换网络时上报 wifi 网线
        msgObj.insert("msgType","network");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketIp"));//当前连接的服务器ip

    }else if("audioQuality" == msgHeaderType)//
    {
        //老师和学生都进入教室，进行视音频通话后，双端每分钟上报一次
        msgObj.insert("msgType","audioQuality");

        //外围传的数据
        dataObj.insert("receivedFrameRate",msgData.value("receivedFrameRate"));//视频接收帧率 声网 qq用
        dataObj.insert("videoLost",msgData.value("videoLost"));//端到端视频丢包率 声网 网易用
        dataObj.insert("audioLost",msgData.value("audioLost"));//端到端音频丢包率 声网 网易用
        dataObj.insert("sendLossRate",msgData.value("sendLossRate"));//发送丢包率 qq用
        dataObj.insert("recvLossRate",msgData.value("recvLossRate"));//接收丢包率 qq用
        dataObj.insert("channel",msgData.value("channel"));//通道 agora/tencent/netease

    }else if("camera" == msgHeaderType)//点击打开摄像头时上报
    {
        //摄像头开关上报
        msgObj.insert("msgType","camera");
    }else if("cameraFinished" == msgHeaderType)//打开摄像头结果上报
    {
        //摄像头开关上报
        msgObj.insert("msgType","cameraFinished");

        //外围传的数据
        //dataObj.insert("cameraStatus",msgData.value("cameraStatus"));// 开关状态 open/close
        dataObj.insert("result",msgData.value("result"));//'1成功/0失败/默认为“”
        dataObj.insert("errMsg",msgData.value("errMsg"));

    }else if("courseware" == msgHeaderType)//
    {
        //课件下载时间
        msgObj.insert("msgType","courseware");

        //外围传的数据
        dataObj.insert("coursewareUrl",msgData.value("coursewareUrl").toString());//课件地址
        dataObj.insert("startDownLoadTime",msgData.value("startDownLoadTime"));
        dataObj.insert("endDownLoadTime",msgData.value("endDownLoadTime"));
        dataObj.insert("downLoadResult",msgData.value("downLoadResult"));//下载结果 success/failed

    }else if("crash" == msgHeaderType)//
    {
        //崩溃上报
        msgObj.insert("msgType","crash");
        dataObj.insert("appVersion",selfInformationObj.value("appVersion").toString());
        //外围传的数据
        dataObj.insert("crashTime",msgData.value("crashTime"));//崩溃时间
        dataObj.insert("crashMsg",msgData.value("crashMsg"));
        dataObj.insert("crashType",msgData.value("crashType"));//1/教室内-0教室外

    }else if("c2cDelay" == msgHeaderType)//
    {
        //老师每分钟发一个延时信令给学生端，学生端收到后上报
        msgObj.insert("msgType","C2CDelay");

        dataObj.insert("socketIp",msgData.value("socketIp").toString());//当前连接的socket服务器的IP
        dataObj.insert("tea_s",msgData.value("tea_s"));//老师发送的命令时间
        dataObj.insert("server_s",msgData.value("server_s"));//服务端收到的命令时间/转发学生的时间
        dataObj.insert("stu",msgData.value("stu"));//学生收到的命令时间

    }else if("c2cCircleDelay" == msgHeaderType)//
    {
        //老师每分钟发一个延时信令给学生端，学生端收到后上报
        msgObj.insert("msgType","C2CCircleDelay");

        dataObj.insert("socketIp",msgData.value("socketIp").toString());//当前连接的socket服务器的IP
        dataObj.insert("tea_s",msgData.value("tea_s"));//老师发送的命令时间
        dataObj.insert("server_s",msgData.value("server_s"));//服务端收到的命令时间/转发学生的时间
        dataObj.insert("stu",msgData.value("stu"));//学生收到的命令时间
        dataObj.insert("server_r",msgData.value("server_r"));//服务端接收时间戳
        dataObj.insert("tea_r",msgData.value("tea_r"));//老师接收的命令时间

    }else if("appLanuch" == msgHeaderType)//
    {
        //APP启动时长 初始化用时
        msgObj.insert("msgType","appLaunch");

        //外围传入数据
        dataObj.insert("time",msgData.value("time").toString());
        dataObj.insert("appVersion",msgData.value("appVersion").toString());

    }else if("socketIpNetworkQuality" == msgHeaderType )//每分钟上报一次
    {
        msgObj.insert("msgType","socketIpNetworkQuality");
        dataObj.insert("lessonType",QString::number(roomMemberInformationObj.value("lessonType").toInt()));

        //外围传的数据
        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp"));
        dataObj.insert("lost",msgData.value("lost"));
        dataObj.insert("delay",msgData.value("delay"));

    }else if("thirdIpNetworkQuality" == msgHeaderType )//访问百度 每分钟上报一次
    {
        msgObj.insert("msgType","thirdIpNetworkQuality");
        dataObj.insert("lessonType",QString::number(roomMemberInformationObj.value("lessonType").toInt()));

        //外围传的数据
        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp"));
        dataObj.insert("lost",msgData.value("lost"));
        dataObj.insert("delay",msgData.value("delay"));

    }else if("enterClassroom" == msgHeaderType)//点击进入教室时上报
    {
        msgObj.insert("msgType","enterClassroom");

        //外围传的数据
        dataObj.insert("lessonType",msgData.value("lessonType"));
        dataObj.insert("lessonId",msgData.value("lessonId"));
        dataObj.insert("userId",msgData.value("userId"));
        dataObj.insert("userName",msgData.value("userName"));
        dataObj.insert("lessonPlanStartTime",msgData.value("lessonPlanStartTime"));
        dataObj.insert("lessonPlanEndTime",msgData.value("lessonPlanEndTime"));
        dataObj.insert("appVersion",msgData.value("appVersion"));

    }else if("enterClassroomFinished" == msgHeaderType)//进入教室结果上报
    {
        msgObj.insert("msgType","enterClassroomFinished");

        //外围传的数据
        dataObj.insert("lessonType",msgData.value("lessonType"));
        dataObj.insert("lessonId",msgData.value("lessonId"));
        dataObj.insert("userId",msgData.value("userId"));
        dataObj.insert("userName",msgData.value("userName"));
        dataObj.insert("lessonPlanStartTime",msgData.value("lessonPlanStartTime"));
        dataObj.insert("lessonPlanEndTime",msgData.value("lessonPlanEndTime"));
        dataObj.insert("appVersion",msgData.value("appVersion"));
        dataObj.insert("api_name",msgData.value("api_name"));
        dataObj.insert("result",msgData.value("result"));//'1成功/0失败/默认为“”
        dataObj.insert("errMsg",msgData.value("errMsg"));
        if(msgData.value("result").toInt() == 0)
        {
            dataObj.insert("errType",msgData.value("errType"));
        }

    }else if("loadScheduleData" == msgHeaderType)//刷新课程表 课程列表点击时上报
    {
        msgObj.insert("msgType","loadScheduleData");

        dataObj.insert("lessonType","");
        dataObj.insert("lessonId","");

        //外围传的数据
        dataObj.insert("userId",msgData.value("userId"));
        dataObj.insert("userName",msgData.value("userName"));
        dataObj.insert("appVersion",msgData.value("appVersion"));
        dataObj.insert("actionType",msgData.value("actionType"));//lessonSchedule(课程表)/lessonList(课程列表)

    }else if("loadScheduleDataFinished" == msgHeaderType)//刷新课程表 课程列表返回结果时时上报
    {
        msgObj.insert("msgType","loadScheduleDataFinished");

        dataObj.insert("lessonType","");
        dataObj.insert("lessonId","");

        //外围传的数据
        dataObj.insert("userId",msgData.value("userId"));
        dataObj.insert("userName",msgData.value("userName"));
        dataObj.insert("appVersion",msgData.value("appVersion"));
        dataObj.insert("actionType",msgData.value("actionType"));//lessonSchedule(课程表)/lessonList(课程列表)
        dataObj.insert("result",msgData.value("result"));//'1成功/0失败/默认为“”
        dataObj.insert("errMsg",msgData.value("errMsg"));
    }else if("changeAuidoChannel" == msgHeaderType)
    {
        msgObj.insert("msgType","changeAudioChannel");
        //外围传的数据

        //数据转换

        QString tempsupplier = msgData.value("currentChannel").toString();
        if("1" == tempsupplier)
        {
            tempsupplier = "agora";
        }else if("2" == tempsupplier)
        {
            tempsupplier = "tencent";
        }else if("3" == tempsupplier)
        {
            tempsupplier = "netease";
        }
        dataObj.insert("currentChannel",tempsupplier);//agora/tencent/netease
        tempsupplier = msgData.value("doChangeChannel").toString();
        if("1" == tempsupplier )
        {
            tempsupplier = "agora";
        }else if("2" == tempsupplier)
        {
            tempsupplier = "tencent";
        }else if("3" == tempsupplier)
        {
            tempsupplier = "netease";
        }
        QString tAudioType = msgData.value("currentAudioType").toString();
        if("0" == tAudioType)
        {
            tAudioType = "1";
        }else if("1" == tAudioType)
        {
            tAudioType = "2";
        }

        dataObj.insert("doChangeChannel",tempsupplier);
        dataObj.insert("currentAudioType",tAudioType);
        dataObj.insert("actionType",msgData.value("actionType"));

    }else if("changeAuidoChannelFinished" == msgHeaderType)
    {
        msgObj.insert("msgType","changeAudioChannelFinished");
        //外围传的数据
        //数据转换
        QString tempsupplier = msgData.value("currentChannel").toString();
        if("1" == tempsupplier)
        {
            tempsupplier = "agora";
        }else if("2" == tempsupplier)
        {
            tempsupplier = "tencent";
        }else if("3" == tempsupplier)
        {
            tempsupplier = "netease";
        }
        dataObj.insert("currentChannel",tempsupplier);//agora/tencent/netease
        tempsupplier = msgData.value("beforeChannel").toString();
        if("1" == tempsupplier )
        {
            tempsupplier = "agora";
        }else if("2" == tempsupplier)
        {
            tempsupplier = "tencent";
        }else if("3" == tempsupplier)
        {
            tempsupplier = "netease";
        }
        QString tAudioType = msgData.value("currentAudioType").toString();
        if("0" == tAudioType)
        {
            tAudioType = "1";
        }else if("1" == tAudioType)
        {
            tAudioType = "2";
        }

        dataObj.insert("beforeChannel",tempsupplier);
        dataObj.insert("currentAudioType",tAudioType);
        dataObj.insert("actionType",msgData.value("actionType"));
        dataObj.insert("result",msgData.value("result"));//'1成功/0失败/默认为“”
        dataObj.insert("errMsg",msgData.value("errMsg"));

    }else if("cameraCall" == msgHeaderType)
    {
        msgObj.insert("msgType","cameraCall");

    }else if("socketDisconnect" == msgHeaderType)
    {
        msgObj.insert("msgType","socketDisconnect");

        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp"));
        dataObj.insert("errMsg",msgData.value("errMsg"));//超时/连接失败/读取失败/socket异常/正常退出/程序崩溃/其他
    }else if("changeSocketNetwork" == msgHeaderType)
    {
        msgObj.insert("msgType","changeSocketNetwork");

        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp"));
        dataObj.insert("actionType",msgData.value("passive"));
        dataObj.insert("doChangeSocketIp",msgData.value("doChangeSocketIp"));

    }else if("changeSocketNetworkFinished" == msgHeaderType)
    {
        msgObj.insert("msgType","changeSocketNetworkFinished");

        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp"));
        dataObj.insert("actionType",msgData.value("passive"));
        dataObj.insert("beforeSocketIp",msgData.value("beforeSocketIp"));
        dataObj.insert("result",msgData.value("result"));
        dataObj.insert("errMsg",msgData.value("errMsg"));

    }else if("changeAuidoChannel_getmessage" == msgHeaderType)
    {
        msgObj.insert("msgType","changeAudioChannel_getmessage");

        //数据转换
        QString tempsupplier = msgData.value("currentChannel").toString();
        if("1" == tempsupplier)
        {
            tempsupplier = "agora";
        }else if("2" == tempsupplier)
        {
            tempsupplier = "tencent";
        }else if("3" == tempsupplier)
        {
            tempsupplier = "netease";
        }
        dataObj.insert("currentChannel",tempsupplier);//agora/tencent/netease
        tempsupplier = msgData.value("beforeChannel").toString();
        if("1" == tempsupplier )
        {
            tempsupplier = "agora";
        }else if("2" == tempsupplier)
        {
            tempsupplier = "tencent";
        }else if("3" == tempsupplier)
        {
            tempsupplier = "netease";
        }
        QString tAudioType = msgData.value("currentAudioType").toString();
        if("0" == tAudioType)
        {
            tAudioType = "1";
        }else if("1" == tAudioType)
        {
            tAudioType = "2";
        }

        dataObj.insert("beforeChannel",tempsupplier);
        dataObj.insert("currentAudioType",tAudioType);

        dataObj.insert("actionType",msgData.value("actionType"));
        dataObj.insert("result",msgData.value("result"));
        dataObj.insert("errMsg",msgData.value("errMsg"));

    }else if("connectMicrophone" == msgHeaderType)//上麦
    {
        msgObj.insert("msgType","connectMicrophone");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
        dataObj.insert("groupId",msgData.value("groupId"));
    }else if("connectMicrophoneFinished" == msgHeaderType)//上麦成功
    {
        msgObj.insert("msgType","connectMicrophoneFinished");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
        dataObj.insert("groupId",msgData.value("groupId"));

    }else if("connectMicrophoneFailed" == msgHeaderType)//上麦失败
    {
        msgObj.insert("msgType","connectMicrophoneFailed");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
        dataObj.insert("groupId",msgData.value("groupId"));
        dataObj.insert("msg",msgData.value("msg"));//系统错误（除拒绝上麦外），拒绝上麦

    }else if("agreeConnectMicrophone" == msgHeaderType)//点击同意上麦
    {
        msgObj.insert("msgType","agreeConnectMicrophone");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));

    }else if("listeningReport" == msgHeaderType)//点击试听课报告
    {
        msgObj.insert("msgType","listeningReport");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));

    }else if("listeningReportFinished" == msgHeaderType)//试听课报告加载成功
    {
        msgObj.insert("msgType","listeningReportFinished");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));

    }else if("listeningReportFailed" == msgHeaderType)//试听课报告加载失败
    {
        msgObj.insert("msgType","listeningReportFailed");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
        dataObj.insert("msg",msgData.value("msg"));//超时（20秒）,用户主动取消,系统错误

    }else if("submit" == msgHeaderType)//点击导入试听课报告
    {
        msgObj.insert("msgType","submit");

        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));

    }else if("submitFinished" == msgHeaderType)//试听课报告导入成功
    {
        msgObj.insert("msgType","submitFinished");
        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
        dataObj.insert("url",msgData.value("url"));

    }else if("submitFailed" == msgHeaderType)//试听课报告导入失败
    {
        msgObj.insert("msgType","submitFailed");
        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
        dataObj.insert("msg",msgData.value("msg"));//超时（20秒）,用户主动取消,系统错误

    }else if("ccCourseCompleted" == msgHeaderType)
    {
        msgObj.insert("msgType","ccCourseCompleted");
        //外围传的数据
        dataObj.insert("socketIp",msgData.value("socketip"));
    }
    dataObj.insert("actionTime",QDateTime::currentMSecsSinceEpoch() + timeDifference);
    msgObj.insert("data",dataObj);
    QJsonDocument tempDoc ;
    tempDoc.setObject(msgObj);
    qDebug()<<"YMQosManager::getPushMsg msgObj"<<msgObj;
    return tempDoc.toJson(QJsonDocument::Compact);
}

void YMQosManager::getLastExitMsgInfo()
{

}

void YMQosManager::checkPushMsgToServe()
{
    //qDebug()<<"YMQosManager::checkPushMsgToServe()"<<msgBufferList.size();
    if(msgBufferList.size() > 0)
    {
        findDataTimer->stop();
        //push msg to server
        QString tempMsg = msgBufferList.takeFirst();
        currentBePushedMsg = tempMsg;
        //异步发送数据
        pushMsgToServer(tempMsg.toUtf8());
    }else
    {//继续检测
        findDataTimer->start();
    }
}

void YMQosManager::onPushMsgToServerReply(QNetworkReply *reply)
{
    if(reply->error() == QNetworkReply::NoError)
    {
        QByteArray byteArray;
        byteArray = reply->readAll();
        reply->deleteLater();
        //数据处理
        QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();
        qDebug()<<"YMQosManager::onPushMsgToServerReply("<<dataObj.value("result").toString() << dataObj;
        if("success" == dataObj.value("result").toString())
        {
            //继续检测是否有数据要发送
            serverErrorTimes = 0;
            findDataTimer->start();
            return;
        }
    }else
    {
        if(!msgBufferList.contains(currentBePushedMsg))
        {
            msgBufferList.append(currentBePushedMsg);
        }
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug()<<"YMQosManagerForStuM::onPushMsgToServerReply error"<<reply->error()<<statusCode;
        if(404 == statusCode)
        {
            ++serverErrorTimes;
            if( serverErrorTimes == 20)
            {
                findDataTimer->stop();
            }
            qDebug()<<"YMQosManager::onPushMsgToServerReply error"<<reply->error()<<statusCode;
            return;
        }
    }

    findDataTimer->start();
}

QString YMQosManager::getMacString()
{
    QString  strMac;
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();
    for (int i = 0; i < ifaces.count(); i++)
    {
        QNetworkInterface iface = ifaces.at(i);
        if ( iface.flags().testFlag(QNetworkInterface::IsUp) && iface.flags().testFlag(QNetworkInterface::IsRunning) && !iface.flags().testFlag(QNetworkInterface::IsLoopBack))
        {
            for (int j=0; j<iface.addressEntries().count(); j++)
            {
                strMac = iface.hardwareAddress();
                i = ifaces.count();
                break;
            }
        }
    }
    if(strMac.isEmpty()) {
        foreach(QNetworkInterface iface,ifaces)
        {
            if(!iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
                strMac = iface.hardwareAddress();
                break;
            }
        }
    }
    qDebug()<<"YMQosManager::getMacString()"<<strMac;
    return strMac;
}

QString YMQosManager::getCurrentNetWorkType()
{
    int types = 0;
    QString netWorkType = "";
    QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface netInterface, list)
    {
        if (!netInterface.isValid())
        {
            continue;
        }

        QNetworkInterface::InterfaceFlags flags = netInterface.flags();
        if (flags.testFlag(QNetworkInterface::IsRunning)
                && !flags.testFlag(QNetworkInterface::IsLoopBack))
        {
            if(types == 0)
            {
                netWorkType = netInterface.name();
            }
            types++;
        }
    }

    if(netWorkType.contains(QStringLiteral("wireless")))
    {
        return "wifi";
    }
    return "cable";
}

void YMQosManager::writeMsgToLocalBuffer(QString msgHeaderType,QJsonObject msgData)
{
    QString tempMsg = getPushMsg(msgHeaderType,msgData);
    //写入本地
    QFile file("crash.dll");
    if(file.open(QIODevice::ReadWrite | QIODevice::Truncate))
    {
        file.write(tempMsg.toUtf8());
        file.flush();
        file.close();
    }
}

void YMQosManager::getLocalBufferMsg()
{
    QFile file("crash.dll");
    if(!file.exists())
    {
        return;
    }
    if(file.open(QIODevice::ReadWrite))
    {
        QString crashmsg = file.readAll();
        file.remove();
        file.close();
        QJsonParseError errors;
        QJsonDocument::fromJson(crashmsg.toLatin1(), &errors);
        if(errors.error == QJsonParseError::NoError)
        {
            msgBufferList.append(crashmsg);
        }
    }
}

void YMQosManager::getBePushedUrl()
{
    if(!QFile::exists("Qtyer.dll"))
    {
        pushUrl = "https://galaxy.yimifudao.com/client";
    }
    QSettings * m_setting = new QSettings("Qtyer.dll", QSettings::IniFormat);

    // 环境类型  测试环境:0  正式环境:1 手动配置
    m_setting->beginGroup("EnvironmentType");
    int environmentType = m_setting->value("type").toInt();
    m_setting->endGroup();

    m_setting->beginGroup("V2.4");
    httpUrl = m_setting->value("formal").toString();
    m_setting->endGroup();


    if(environmentType == 1)
    {
        pushUrl = "https://galaxy.yimifudao.com/client";
    }else
    {
        pushUrl = "https://galaxy-test.yimifudao.com/client";
    }
    qDebug()<<"pushUrl"<<pushUrl;
}

void YMQosManager::getDeviceInfo()
{
    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\", QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    deviceInfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));
    deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    reg.endGroup();
    osVersion = QSysInfo::prettyProductName();
    osVersion.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
}

void YMQosManager::getServerDateTime()
{
    QDateTime times = QDateTime::currentDateTime();

    QMap<QString, QString> maps;
    //    maps.insert("userId", "105479");
    //    maps.insert("lessonId", "331255");
    //    maps.insert("type", "TEA");
    //    maps.insert("apiVersion", "2.4");
    //    maps.insert("appVersion", "1.0.0");
    maps.insert("token", selfInformationObj.value("token").toString());
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  maps.begin();
    for(int i = 0; it != maps.end() ; it++, i++)
    {

        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());
    QUrl url("http://" + httpUrl + "/now");
    QByteArray post_data;//上传的数据可以是QByteArray或者file类型
    QString str = urls;

    post_data.append(str);

    m_request.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    m_request.setUrl(url);
    QEventLoop loop;
    QTimer::singleShot(15000, &loop, SLOT(quit()));
    connect(m_accessManager, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    m_reply = m_accessManager->post(m_request, post_data);
    loop.exec();
    QByteArray replyData = m_reply->readAll();
    QJsonObject dataObj = QJsonDocument::fromJson(replyData).object();
    if(dataObj.value("success").toBool())
    {
        timeDifference = dataObj.value("data").toVariant().toLongLong() - QDateTime::currentMSecsSinceEpoch();
    }

}

qint64 YMQosManager::getTimeDifference()
{
    return timeDifference;
}

QJsonObject YMQosManager::getBasicJsonData()
{
    QJsonObject dataObj;
    dataObj.insert("appType","yimi");
    dataObj.insert("appDeviceType","PC");
    dataObj.insert("appVersion",selfInformationObj.value("appVersion").toString());
    if(roomMemberInformationObj.contains("lessonType"))
    {
        dataObj.insert("lessonType",QString::number(roomMemberInformationObj.value("lessonType").toInt()));
    }else{
        dataObj.insert("lessonType","");
    }
    dataObj.insert("deviceType","PC");
    dataObj.insert("deviceInfo",deviceInfo);
    dataObj.insert("deviceIdentity",getMacString());
    dataObj.insert("osVersion",osVersion);
    dataObj.insert("lessonId",QString::number(roomMemberInformationObj.value("lessonId").toVariant().toLongLong()));
    dataObj.insert("userType",currentUserType);
    dataObj.insert("userName",selfInformationObj.value("userName").toString());
    dataObj.insert("userId",selfInformationObj.value("id").toString());
    dataObj.insert("networkType",getCurrentNetWorkType());//网络类型 3g/4g/wifi/cable/else
    dataObj.insert("operatorType","");//运营商类型：1-移动、2-联通、3-电信
    return dataObj;
}

bool YMQosManager::getIsChangeChannel()
{
    return isChangeChannel;
}

void YMQosManager::setChangeChannelValue(bool isChangeChannels)
{
    isChangeChannel = isChangeChannels;
}

QString YMQosManager::makeJoinMicActionId()
{
    qsrand(QTime(0,0,0).secsTo(QTime::currentTime()));
    joinMicActionId = "";
    for(int i = 0; i < 6; i++)
    {
        joinMicActionId.append(QString::number(qrand()%10));
    }
    return joinMicActionId;
}

QString YMQosManager::getJoinMicActionId()
{
    return joinMicActionId;
}

QString YMQosManager::getH5NeedBasicData()
{
    QString basicH5Data = "&appType=yimi&appDeviceType=PC&deviceInfo=";
    basicH5Data.append(basicJsonData.value("deviceInfo").toString());
    basicH5Data.append("&deviceIdentity=").append(basicJsonData.value("deviceIdentity").toString());
    basicH5Data.append("&osVersion=").append(basicJsonData.value("osVersion").toString());
    basicH5Data.append("&appVersion=").append(selfInformationObj.value("appVersion").toString());
    basicH5Data.append("&operatorType=");
    basicH5Data.append("&netType=").append(basicJsonData.value("networkType").toString());
    return basicH5Data;
}

