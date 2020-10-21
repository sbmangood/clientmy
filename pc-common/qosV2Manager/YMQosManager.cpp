#include "YMQosManager.h"
#include <QStandardPaths>
#include <QCoreApplication>
#include <QUuid>
#include "../../pc-common/pingback/pingbackmanager.h"

/*
*qos 数据传输类
*/

const QString YMQosManager::kXBK_Click_class = "XBKCloudClassroom_teacher_click_class";
const QString YMQosManager::kXBK_Click_pointer = "XBKCloudClassroom_teacher_click_pointer";
const QString YMQosManager::kXBK_Click_remove_pointer = "XBKCloudClassroom_teacher_remove_pointer";
const QString YMQosManager::kXBK_Click_timer = "XBKCloudClassroom_teacher_click_timer";
const QString YMQosManager::kXBK_Click_selection = "XBKCloudClassroom_teacher_click_selection";
const QString YMQosManager::kXBK_Click_responder = "XBKCloudClassroom_teacher_click_responder";
const QString YMQosManager::kXBK_Click_countdown = "XBKCloudClassroom_teacher_click_countdown";
const QString YMQosManager::kXBK_Click_reward = "XBKCloudClassroom_teacher_click_reward";
const QString YMQosManager::kXBK_Click_authorization = "XBKCloudClassroom_teacher_click_authorization";
const QString YMQosManager::kXBK_Click_mute = "XBKCloudClassroom_teacher_click_mute";
const QString YMQosManager::kXBK_Click_allmute = "XBKCloudClassroom_teacher_click_Allmute";
const QString YMQosManager::kXBK_Click_onStage = "XBKCloudClassroom_teacher_click_OnStage";
const QString YMQosManager::kXBK_Click_downStage = "XBKCloudClassroom_teacher_click_DownStage";
const QString YMQosManager::kXBK_Click_stu_responder = "XBKCloudClassroom_student_click_responder";
const QString YMQosManager::kXBK_Click_stu_responderResult = "XBKCloudClassroom_student_result_responder";
const QString YMQosManager::kXBK_HearTable_networkQuality = "XBKsocketIpNetworkQuality";
const QString YMQosManager::kXBK_Click_enterClassroom = "XBKenterClassroom";
const QString YMQosManager::kXBK_Click_enterClassroomFInish = "XBKenterClassroomFinished";
const QString YMQosManager::kXBK_Click_camera = "XBKcamera";
const QString YMQosManager::kXBK_Click_cameraCall = "XBKcameraCall";
const QString YMQosManager::kXBK_HearTable_socketDisconnect = "XBKsocketDisconnect";
const QString YMQosManager::kXBK_HearTable_audioQuality = "XBKaudioQuality";
const QString YMQosManager::kXBK_Click_courseware = "XBKcourseware";
const QString YMQosManager::kXBK_Click_tea_feedback = "XBKCloudClassroom_teacher_click_feedback";
const QString YMQosManager::kXBK_Click_stu_feedback = "XBKCloudClassroom_student_click_feedback";
const QString YMQosManager::kXBK_Click_SwitchRole = "switchIdentity";


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
        m_lessonId = roomMemberInformationObj.value("lessonId").toString();
    }
    documets = QJsonDocument::fromJson(jsonStringList.at(1).toUtf8(), &errors);
    if(errors.error == QJsonParseError::NoError)
    {
        selfInformationObj = documets.object();
    }
    basicJsonData = getBasicJsonData();
    this->registerClassroomEventInfo();
}

void YMQosManager::addBePushedMsg(QString msgHeaderType, QJsonObject msgData)
{
    QString tempMsg = getPushMsg(msgHeaderType,msgData);
    QJsonParseError errors;
    QJsonDocument::fromJson(tempMsg.toLatin1(), &errors);
    if(errors.error == QJsonParseError::NoError)
    {
        //msgBufferList.append(tempMsg);
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
    QMap<QString,QString> dataObj;// = basicJsonData;
    YimiLogType ymLogType = YimiLogType::CLICK;
    if(kXBK_Click_class == msgHeaderType)
    {
        //开始上课
        ymLogType = YimiLogType::CLICK;
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_pointer == msgHeaderType)
    {
        //教鞭
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_remove_pointer == msgHeaderType)
    {
        //取消教鞭
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_timer == msgHeaderType)
    {
        //计时器
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_selection == msgHeaderType)
    {
        //随机选人
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_responder == msgHeaderType)
    {
        //抢答器
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_countdown == msgHeaderType)
    {
        //倒计时
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_reward == msgHeaderType)
    {
        //课堂奖励
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("student_id",msgData.value("student_id").toString());
    }
    else if(kXBK_Click_authorization == msgHeaderType)
    {
        //授权
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("student_id",msgData.value("student_id").toString());
    }
    else if(kXBK_Click_mute == msgHeaderType)
    {
        //静音
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("student_id",msgData.value("student_id").toString());
    }
    else if(kXBK_Click_allmute == msgHeaderType)
    {
        //全体静音
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_Click_onStage == msgHeaderType)
    {
        //上台
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("student_id",msgData.value("student_id").toString());
    }
    else if(kXBK_Click_downStage == msgHeaderType)
    {
        //下台
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("student_id",msgData.value("student_id").toString());
    }
    else if(kXBK_Click_stu_responder == msgHeaderType)
    {
        //抢答
        msgObj.insert("msgType",msgHeaderType);
        //dataObj.insert("lessonId",m_lessonId);
        //dataObj.insert("socketIp",msgData.value("socketIp").toString());
        //dataObj.insert("student_id",msgData.value("student_id").toString());
    }
    else if(kXBK_Click_stu_responderResult == msgHeaderType)
    {
        //抢中
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_HearTable_networkQuality == msgHeaderType)
    {
        //当前socketIP网络质量（每分钟）
        ymLogType = YimiLogType::HEARTBEAT;
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp").toString());
        dataObj.insert("lost",msgData.value("lost").toString());
        dataObj.insert("delay",msgData.value("delay").toString());
    }
    else if(kXBK_Click_enterClassroom == msgHeaderType)
    {
        //进入教室
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("lessonId",msgData.value("lessonId").toString());
        dataObj.insert("lessonType",msgData.value("lessonType").toString());
        dataObj.insert("lessonPlanStartTime",msgData.value("lessonPlanStartTime").toString());
        dataObj.insert("lessonPlanEndTime",msgData.value("lessonPlanEndTime").toString());
    }
    else if(kXBK_Click_enterClassroomFInish == msgHeaderType)
    {
        //进入教室【触发成功】
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("lessonPlanStartTime",msgData.value("lessonPlanStartTime").toString());
        dataObj.insert("lessonPlanEndTime",msgData.value("lessonPlanEndTime").toString());
        dataObj.insert("result",msgData.value("result").toString());
        dataObj.insert("errMsg",msgData.value("errMsg").toString());
    }
    else if(kXBK_Click_camera == msgHeaderType)
    {
        //打开关闭摄像头
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("cameraStatus",QString::number(msgData.value("cameraStatus").toInt()));
    }
    else if(kXBK_Click_cameraCall == msgHeaderType)
    {
        //打开摄像头
        msgObj.insert("msgType",msgHeaderType);
    }
    else if(kXBK_HearTable_socketDisconnect == msgHeaderType)
    {
        //掉线上报
        ymLogType = YimiLogType::HEARTBEAT;
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("currentSocketIp",msgData.value("currentSocketIp").toString());
        dataObj.insert("errMsg",msgData.value("errMsg").toString());
    }
    else if(kXBK_HearTable_audioQuality == msgHeaderType)
    {
        //音频通话质量
        ymLogType = YimiLogType::HEARTBEAT;
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("channel",msgData.value("channel").toString());
        dataObj.insert("sendLossRate",msgData.value("sendLossRate").toString());
        dataObj.insert("recvLossRate",msgData.value("recvLossRate").toString());
        dataObj.insert("receivedFrameRate",msgData.value("receivedFrameRate").toString());
        dataObj.insert("videoLost",msgData.value("videoLost").toString());
        dataObj.insert("audioLost",msgData.value("audioLost").toString());
        dataObj.insert("sender_userid",msgData.value("sender_userid").toString());
        dataObj.insert("sender_usertype",msgData.value("sender_usertype").toString());
    }
    else if(kXBK_Click_courseware == msgHeaderType)
    {
        //课件展示出来后上报
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("coursewareUrl",msgData.value("coursewareUrl").toString());
        dataObj.insert("startDownLoadTime",msgData.value("startDownLoadTime").toString());
        dataObj.insert("endDownLoadTime",msgData.value("endDownLoadTime").toString());
        dataObj.insert("fileName",msgData.value("fileName").toString());
        dataObj.insert("fileType",msgData.value("fileType").toString());
        dataObj.insert("downLoadResult",msgData.value("downLoadResult").toString());
    }
    else if(kXBK_Click_tea_feedback == msgHeaderType)
    {
        //老师问题反馈
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("className",msgData.value("className").toString());
        dataObj.insert("help_user",msgData.value("help_user").toString());
        dataObj.insert("help_content",msgData.value("help_content").toString());
    }
    else if(kXBK_Click_stu_feedback == msgHeaderType)
    {
        //学生问题反馈
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("className",msgData.value("className").toString());
        dataObj.insert("help_user",msgData.value("help_user").toString());
        dataObj.insert("help_content",msgData.value("help_content").toString());
    }else if(kXBK_Click_SwitchRole == msgHeaderType)
    {
        //切换用户类型
        msgObj.insert("msgType",msgHeaderType);
        dataObj.insert("switchRole",msgData.value("switchRole").toString());
    }
    /*
    else if("lessonBaseInfo" == msgHeaderType)//roleType
    {
        //进教室时上报
        //msgObj.insert("msgType","lessonBaseInfo");//enterClassroomFinished
        msgObj.insert("msgType","enterClassroomFinished");
        dataObj.insert("lessonType",QString::number(roomMemberInformationObj.value("lessonType").toInt()));
        dataObj.insert("lessonPlanStartTime",roomMemberInformationObj.value("startTime").toString());
        dataObj.insert("lessonPlanEndTime",roomMemberInformationObj.value("endTime").toString());
        dataObj.insert("appVersion",selfInformationObj.value("appVersion").toString());

        //外围传的数据
        dataObj.insert("result",msgData.value("result"));//1成功/0失败
        dataObj.insert("errMsg",msgData.value("errMsg"));//成功/错误消息

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
        dataObj.insert("result",msgData.value("result"));//'1成功/0失败/默认为“”
        dataObj.insert("errMsg",msgData.value("errMsg"));

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

    }
    */
    //dataObj.insert("time",QString::number(QDateTime::currentMSecsSinceEpoch() + timeDifference));
    //msgObj.insert("data",dataObj);
    QJsonDocument tempDoc ;
    tempDoc.setObject(msgObj);
    qDebug()<<"YMQosManager::getPushMsg msgObj"<<dataObj;
    yimipingback::PingbackManager::gestance()->SendEvent(msgHeaderType,ymLogType,dataObj);
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
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
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

    //错误处理
    //判断是否丢弃该消息 后期优化处理
    msgBufferList.append(currentBePushedMsg);
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

QMap<QString,QString> YMQosManager::getBasicJsonData()
{
    QMap<QString,QString> dataObj;
//    dataObj.insert("time","");
    dataObj.insert("sessionId",getSessionId());
//    dataObj.insert("eventId","");//对应原来的msgType
//    dataObj.insert("userId","");
    dataObj.insert("uuid",getMacString());
    dataObj.insert("company","YIMI");
    dataObj.insert("business","");
    dataObj.insert("sdkVersion","V100");
    dataObj.insert("userType",currentUserType);
    dataObj.insert("Type","CLICK");
    dataObj.insert("NetType",getCurrentNetWorkType());
    dataObj.insert("operatorType","");
    dataObj.insert("os","BACKEND");
//    dataObj.insert("channel","");
    dataObj.insert("requestCnt","1");
    dataObj.insert("appVersion",selfInformationObj.value("appVersion").toString());
    dataObj.insert("appType","yimi");
    dataObj.insert("deviceInfo",deviceInfo);
    dataObj.insert("osVersion",osVersion);
//    dataObj.insert("info","");
    dataObj.insert("AppAction","OPEN");
//    dataObj.insert("stayTime","");

/*
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
*/
    qDebug() << "===getBasicJsonData===" << dataObj;
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

QString YMQosManager::getSessionId()
{
    QUuid uid = QUuid::createUuid();
    QString hexStr = uid.toString().replace("{","").replace("-","").replace("}","").mid(0,16);
    int timeSpan = QDateTime::currentDateTime().toTime_t();
    QString sessionId = hexStr + QString::number(timeSpan) + "001";
    return sessionId;
}

void YMQosManager::registerClassroomEventInfo()
{
    QList<QString> eventId_List;
    eventId_List.insert(0,kXBK_Click_class);
    eventId_List.insert(1,kXBK_Click_pointer);
    eventId_List.insert(2,kXBK_Click_remove_pointer);
    eventId_List.insert(3,kXBK_Click_timer);
    eventId_List.insert(4,kXBK_Click_selection);
    eventId_List.insert(5,kXBK_Click_responder);
    eventId_List.insert(6,kXBK_Click_countdown);
    eventId_List.insert(7,kXBK_Click_reward);
    eventId_List.insert(8,kXBK_Click_authorization);
    eventId_List.insert(9,kXBK_Click_mute);
    eventId_List.insert(10,kXBK_Click_allmute);
    eventId_List.insert(11,kXBK_Click_onStage);
    eventId_List.insert(12,kXBK_Click_downStage);
    eventId_List.insert(13,kXBK_Click_stu_responder);
    eventId_List.insert(14,kXBK_HearTable_networkQuality);
    eventId_List.insert(15,kXBK_Click_enterClassroom);
    eventId_List.insert(16,kXBK_Click_camera);
    eventId_List.insert(17,kXBK_HearTable_socketDisconnect);
    eventId_List.insert(18,kXBK_HearTable_audioQuality);
    eventId_List.insert(19,kXBK_Click_courseware);
    eventId_List.insert(20,kXBK_Click_tea_feedback);
    eventId_List.insert(21,kXBK_Click_stu_feedback);
    yimipingback::PingbackManager::gestance()->RegisterRoomEventList(eventId_List);
}


void YMQosManager::registerClassroomInfo(const QString& socketIp)
{
    QJsonObject jsonObj;
    jsonObj.insert("lessonId",m_lessonId);
    jsonObj.insert("lessonType","ORDER");
    jsonObj.insert("serverip",socketIp);
    yimipingback::PingbackManager::gestance()->RegisterRoomEventParams(jsonObj);
    qDebug() << "==YMQosManager::registerClassroomInfo==" << jsonObj;
}

