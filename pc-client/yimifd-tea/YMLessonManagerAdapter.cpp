#include "YMLessonManagerAdapter.h"
#include "YMUserBaseInformation.h"
#include "YMEncryption.h"
#include <QJsonDocument>
#include "QProcess"
#include "QFile"
#include "QDir"
#include <QStandardPaths>
#include <QCoreApplication>
//#include <QMessageBox>
#include "debuglog.h"

//#define MSG_BOX_TITLE  QString(u8"溢米辅导")

std::string key = "Q-RRt2H2";

YMLessonManagerAdapter::YMLessonManagerAdapter(QObject * parent)
    : QObject(parent)
    ,teaInClassRoomFlag(false)
    ,offSingle(1)
{
    m_httpClint = YMHttpClient::defaultInstance();
    connect(m_httpClint, SIGNAL(onRequstTimerOut()), this, SIGNAL(requstTimeOuted()));
    m_timer = new QTimer();
    m_timer->setInterval(20000);
    m_timer->setSingleShot(true);

    m_getIpTimer = new QTimer();
    m_getIpTimer->setInterval(20000);
    m_getIpTimer->setSingleShot(true);
}

void YMLessonManagerAdapter::errorLog(QString message)
{
    QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString filePath = docPath + "/YiMi/";
    qDebug() << "********YMAccountManager::errorLog**********" << filePath;
    QDir dir(filePath);
    if(!dir.exists())
    {
        dir.mkdir(filePath);
    }

    QFile file(filePath + "teacherlog.txt");

    if(file.open(QFile::WriteOnly | QFile::Append))
    {
        QTextStream textOut(&file);
        textOut << message + "\r\n";
        textOut.flush();
    }
    file.close();
}

//获取: 课程表
void YMLessonManagerAdapter::getTeachLessonInfo(QString dateTime)
{
    QJsonObject loadScheduleDataObj;
    loadScheduleDataObj.insert("userId",YMUserBaseInformation::id);
    loadScheduleDataObj.insert("userName",YMUserBaseInformation::userName);
    loadScheduleDataObj.insert("appVersion",YMUserBaseInformation::appVersion);
    loadScheduleDataObj.insert("actionType","lessonSchedule");
    YMQosManager::gestance()->addBePushedMsg("loadScheduleData", loadScheduleDataObj);

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;

    QString sign;
    reqParm.insert("queryDate", dateTime);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", "3.0"); //接口标注 传3.0
    sign = YMEncryption::signMapSort(reqParm);

    reqParm.insert("queryDate", dateTime);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", "3.0"); //接口标注 传3.0
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = m_httpClint->httpUrl + "/lesson/getTeacherLessonSchedule";
    QByteArray dataArray = m_httpClint->httpPostForm(url, reqParm);
    //qDebug()<<QString::fromUtf8( dataArray.mid(0,20000)) <<"lesson table ";
    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "YMLessonManagerAdapter::getTeachLessonInfo objectData22" << objectData;

    teachLessonInfoChanged(objectData);
    //QString datas;
    //this->errorLog("YMLessonManagerAdapter::getTeachLessonInfo" + datas.prepend(dataArray));
    emit loadingFinished();

    if(objectData.value("success").toBool())
    {
        loadScheduleDataObj.insert("result","1");
        loadScheduleDataObj.insert("errMsg","");
    }else
    {
        loadScheduleDataObj.insert("result","0");
        loadScheduleDataObj.insert("errMsg","get lessonlist data fail ");
    }
    YMQosManager::gestance()->addBePushedMsg("loadScheduleDataFinished", loadScheduleDataObj);
}

//获取: 课程列表
void YMLessonManagerAdapter::getTeachLessonListInfo(QJsonObject data)
{
    QJsonObject loadScheduleDataObj;
    loadScheduleDataObj.insert("userId",YMUserBaseInformation::id);
    loadScheduleDataObj.insert("userName",YMUserBaseInformation::userName);
    loadScheduleDataObj.insert("appVersion",YMUserBaseInformation::appVersion);
    loadScheduleDataObj.insert("actionType","lessonList");
    YMQosManager::gestance()->addBePushedMsg("loadScheduleData", loadScheduleDataObj);

    QDateTime timess = QDateTime::currentDateTime();

    QString keywords = data.value("keywords").toString();
    QString pageIndex = data.value("pageIndex").toString();
    QString pageSize = QString::number(data.value("pageSize").toInt());
    QString queryStartDate = data.value("queryStartDate").toString();
    QString queryEndDate = data.value("queryEndDate").toString();
    QString queryStatus = data.value("queryStatus").toString();
    QString queryPeriod = data.value("queryPeriod").toString();

    QVariantMap dataMap;
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", "3.0"); //接口标注传3.0
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    dataMap.insert("keywords", keywords);
    dataMap.insert("pageIndex", pageIndex);
    dataMap.insert("pageSize", pageSize);
    dataMap.insert("queryStartDate", queryStartDate);
    dataMap.insert("queryEndDate", queryEndDate);
    dataMap.insert("queryStatus", queryStatus);
    dataMap.insert("queryPeriod", queryPeriod);

    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);
    //qDebug() << "lessonList::" << dataMap;
    QString url = m_httpClint->httpUrl + "/lesson/getTeacherLesson";

    QByteArray dataArray = m_httpClint->httpPostForm(url, dataMap);
    //qDebug()<<dataArray <<"lessonlist data";
    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "YMLessonManagerAdapter::getTeachLessonListInfo" << objectData;

    QJsonObject lessonData = objectData.value("data").toObject();
    teacherLesonListInfoChanged(lessonData);
    this->errorLog("YMLessonManagerAdapter::getTeachLessonListInfo");
    emit loadingFinished();

    if(objectData.value("success").toBool())
    {
        loadScheduleDataObj.insert("result","1");
        loadScheduleDataObj.insert("errMsg","");
    }else
    {
        loadScheduleDataObj.insert("result","0");
        loadScheduleDataObj.insert("errMsg","get lessonlist data fail ");
    }
    YMQosManager::gestance()->addBePushedMsg("loadScheduleDataFinished", loadScheduleDataObj);
}

//查看课件
//void YMLessonManagerAdapter::getLookCourse(QJsonObject lessonInfo)
//{
//    QString startTime = lessonInfo.value("startTime").toString();
//    QString lessonId = QString::number(lessonInfo.value("lessonId").toInt());

//    QStringList courseData;
//    courseData << YMUserBaseInformation::type;
//    courseData << YMUserBaseInformation::id;
//    courseData << YMUserBaseInformation::token;
//    courseData << lessonId;
//    QString timeRep = startTime.replace("-","").replace("-","");
//    QString time = timeRep.mid(0,6);
//    courseData << time;
//    courseData << YMUserBaseInformation::appVersion;
//    courseData << YMUserBaseInformation::apiVersion;

//    QString runPath = QCoreApplication::applicationDirPath();
//    QProcess *process = new QProcess(this);

//    //qDebug() << "YMLessonManagerAdapter::getLookCourse"
//    //         << courseData;
//    process->start(runPath + "/CourwarePreviewer.exe",courseData);
//}
//查看课件
void YMLessonManagerAdapter::getLookCourse(QJsonObject lessonInfo)
{
    //qDebug() << "YMLessonManagerAdapter::getLookCourse" << YMUserBaseInformation::userName << __LINE__;
    QString m_systemPublicFilePath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";
    QDir isDir;
    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }

    QString tempdata = QString("{\"code\": -1,\"data\": {\"endTime\": \"2018-03-29 22:38:00\", \"lessonId\": %7,\"lessonSecondCount\": 79920,"
                               " \"qqSign\": \"eJxlj11\","
                               "  \"socketFlag\": 1,"
                               " \"startFlag\": 0,"
                               "\"startTime\": \"2018-03-29 00:26:00\","
                               "  \"student\": [{"
                               " \"functionSwitch\": \"\","
                               "\"headPicture\": \"http://static.1mifd.com/static-files/user_pics/stu_head_pic/male.png\","
                               " \"id\": 10001399,"
                               " \"mobileNo\": \"17796652904\",\"realName\": \"\","
                               "\"type\": \"A\"       }       ],\"teacher\": {"
                               " \"functionSwitch\": { \"agora\": \"1\","
                               "   \"tencent\": \"0\"                                },"
                               " \"headPicture\": \"http://static.1mifd.com/static-files/user_pics/stu_head_pic/male.png\","
                               "\"mobileNo\": \"13764380323\",  \"realName\": \"\",   \"teacherId\": 900000506 },"
                               " \"title\": \"\", \"title_short\": \"299914 演示 00:26- 22:38\"  },"
                               "\"message\": \"SUCCESS\",  \"result\": \"success\",  \"success\": true}###{"
                               "\"MD5Pwd\": \"%1\","
                               "\"address\": \"111.231.67.238\","
                               "\"apiVersion\": \"%2\","
                               "\"appVersion\": \"%3\","
                               " \"deviceInfo\": \"%4\","
                               " \"id\": \"%5\","
                               "  \"lat\": \"31.2243\","
                               " \"lessonType\": \"A\","
                               "   \"lng\": \"121.4768\","
                               " \"logTime\": \"2018-03-29 13:32:27\","
                               "\"mobileNo\": \"13764380323\","
                               "\"port\": \"5122\","
                               "\"token\": \"%6\","
                               "\"lessonStatus\": \"%8\","
                               "\"udpPort\": \"5120\","
                               "\"userName\": \"%9\"}")
            .arg(YMUserBaseInformation::passWord) \
            .arg(YMUserBaseInformation::apiVersion) \
            .arg(YMUserBaseInformation::appVersion) \
            .arg(YMUserBaseInformation::deviceInfo) \
            .arg(YMUserBaseInformation::id) \
            .arg(YMUserBaseInformation::token) \
            .arg(QString::number(lessonInfo.value("lessonId").toInt())) \
            .arg(QString::number(lessonInfo.value("lessonStatus").toInt())) \
            .arg(YMUserBaseInformation::userName);

    QString filename("courware.ini");
    QFile file(m_systemPublicFilePath + filename);
    file.open(QIODevice::WriteOnly);
    file.write(tempdata.toLatin1());
    file.flush();
    file.close();
    QString runPath = QCoreApplication::applicationDirPath();
    QProcess *process = new QProcess(this);
    process->start(runPath + "/CourwarePreviewer.exe", QStringList());
}
//进入教室
void YMLessonManagerAdapter::getEnterClass(QString lessonId,int interNetGrade)
{
    //信息上报
    currentLessonId = lessonId;
    QJsonObject enterClassroomObj;
    enterClassroomObj.insert("lessonType",lessonType);
    enterClassroomObj.insert("lessonId",lessonId);
    enterClassroomObj.insert("userId",YMUserBaseInformation::id);
    enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
    enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
    enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
    enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
    YMQosManager::gestance()->addBePushedMsg("enterClassroom", enterClassroomObj);

    QNetworkConfigurationManager mgr;
    if(0 == interNetGrade && !mgr.isOnline())
    {
        //信息上报
        QJsonObject enterClassroomObj;
        enterClassroomObj.insert("lessonType",lessonType);
        enterClassroomObj.insert("lessonId",currentLessonId);
        enterClassroomObj.insert("userId",YMUserBaseInformation::id);
        enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
        enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
        enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
        enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
        enterClassroomObj.insert("result",0);
        enterClassroomObj.insert("api_name","enterClass");
        enterClassroomObj.insert("errMsg",QStringLiteral("客户端没有连接网络"));
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        emit requstTimeOuted();
        return;
    }

    m_listenOrClass = true;
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("lessonId", lessonId);
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("sysInfo", "WIN");
    dataMap.insert("deviceInfo", "1");
    dataMap.insert("appSource", "YIMI");
    dataMap.insert("umengAppKey", "597ac22d75ca350dd600227a");
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString url = m_httpClint->httpUrl + "/lesson/enterClass?";

    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    QString sign;
    //数据拼接
    QVariantMap::iterator it;
    for(it = dataMap.begin(); it != dataMap.end(); ++it)
    {
        sign.append(it.key()).append("=").append(QString::fromUtf8( it.value().toByteArray()));
        if(it != dataMap.end() - 1)
        {
            sign.append("&");
        }
    }
    url.append(sign).append("&sign=");

    sign = QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper();
    url.append(sign);

    httpRequest.setUrl(QUrl(url));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), this, SLOT(getEnterClassresult(QNetworkReply*)));

    httpAccessmanger->post(httpRequest, "");
    isStop = false;
    m_timer->stop();
    m_timer->start();
    connect(m_timer, SIGNAL(timeout()), this, SLOT(enterClassTimerOut()));
    /*QEventLoop httploop;
    connect(httpAccessmanger,SIGNAL(finished(QNetworkReply*)),&httploop,SLOT(quit()));
    connect(m_timer,&QTimer::timeout,&httploop,&QEventLoop::quit);
    QNetworkReply *reply = httpAccessmanger->post(httpRequest,"");

    m_timer->start();
    httploop.exec();

    if(m_timer->isActive()){
        m_timer->stop();
    }
    else
    {
        emit requstTimeOuted();
        return;
    }

    QByteArray dataArray= reply->readAll();
    // qDebug()<<"get enter  class room  bada "<<dataArray;

    if(dataArray.length() == 0){
        lessonlistRenewSignal();
        return;
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "YMLessonManagerAdapter::getEnterClass:dataArray" << dataArray.length() << dataObject;
    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString() == "success"
            && dataObject.value("message").toString() == "SUCCESS"){
        m_classData = dataObject;
        //qDebug() << "YMLessonManagerAdapter::getEnterClass" << dataObject;
        getCloudServer();
    }*/

}

void YMLessonManagerAdapter::enterClassTimerOut()
{
    m_timer->stop();
    emit requstTimeOuted();
    qDebug() << "YMLessonManagerAdapter::enterClassTimerOut";
}

void YMLessonManagerAdapter::getEnterClassresult(QNetworkReply *reply)
{
    bool hasTimeOut = false;
    if(!m_timer->isActive())
    {
        hasTimeOut = true;
    }

    m_timer->stop();
    //信息上报
    QJsonObject enterClassroomObj;
    enterClassroomObj.insert("lessonType",lessonType);
    enterClassroomObj.insert("lessonId",currentLessonId);
    enterClassroomObj.insert("userId",YMUserBaseInformation::id);
    enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
    enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
    enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
    enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
    enterClassroomObj.insert("api_name","enterClass");
    enterClassroomObj.insert("result",0);

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if(200 != statusCode)
    {
        lessonlistRenewSignal();
        enterClassroomObj.insert("errMsg",QStringLiteral("接口服务器系统异常，接口返回") + QString::number(statusCode));
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        return;
    }

    QByteArray dataArray = reply->readAll();
    // qDebug()<<"get enter  class room  bada "<<dataArray;

    if(dataArray.length() == 0)
    {
        lessonlistRenewSignal();
        if(hasTimeOut)
        {
            enterClassroomObj.insert("errMsg",QStringLiteral("enterClass接口访问超时"));
        }else
        {
            enterClassroomObj.insert("errMsg",QStringLiteral("enterClass接口返回数据异常，接口返回数据为空"));
        }
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        return;
    }

    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "YMLessonManagerAdapter::getEnterClass:dataArray" << dataArray.length() << dataObject;

    YMUserBaseInformation::m_bHasExistError = false;

    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString().toLower() == "success"
            && dataObject.value("message").toString().toUpper() == "SUCCESS")
    {
        m_classData = QJsonObject();
        m_classData = dataObject;
        teaInClassRoomFlag =  dataObject.value("teaInClassRoomFlag").toBool();
        //qDebug() << "YMLessonManagerAdapter::getEnterClassresult" << dataObject;

        if(teaInClassRoomFlag && dataObject.value("classTeacherId").toString() != YMUserBaseInformation::id)
        {
            emit sigIsJoinClassroom(QStringLiteral("课程顾问"));
            return;
        }

        getCloudServer();
    }
    else
    {
        YMUserBaseInformation::m_bHasExistError = true;
        QString strMsg = dataObject.value("message").toString();
        emit sigMessageBoxInfo(strMsg);
        if(strMsg == "" || strMsg.contains(QStringLiteral("云教室尚未开放")))//过滤无效数据
        {
            enterClassroomObj.insert("result",1);
            enterClassroomObj.insert("errMsg","");
        }else
        {
            enterClassroomObj.insert("errMsg",QStringLiteral("接口返回错误码，接口返回错误码为") + strMsg);
        }
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        //QString strMsg = dataObject.value("message").toString();
        //QMessageBox::information(NULL, MSG_BOX_TITLE,  strMsg, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << "YMLessonManagerAdapter::getEnterClassresult failed" << dataObject;
    }
}

//查看录播
void YMLessonManagerAdapter::getRepeatPlayer(QJsonObject lessonInfo)
{
    QString startTime = lessonInfo.value("startTime").toString();
    QString lessonId = QString::number(lessonInfo.value("lessonId").toInt());

    qDebug() << "YMLessonManagerAdapter::getRepeatPlayer"
             << lessonInfo
             << startTime
             << lessonInfo.value("startTime").toString()
             << lessonId;
    m_repeatData = lessonInfo;
    QVariantMap dataMap;
    QDateTime timess = QDateTime::currentDateTime();
    dataMap.insert("lessonId", lessonId);
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("type", YMUserBaseInformation::type);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();

    dataMap.insert("sign", sign);
    QString url = m_httpClint->httpUrl + "/lesson/getStuTrailVideoList"; //录播列表
    int reqCode = m_httpClint->httpPostVariant(url, dataMap, this);
    m_respHandlers.insert(reqCode, &YMLessonManagerAdapter::onRespGetRepeatPlayer);
}

void YMLessonManagerAdapter::getCloudServer()
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("appVersion", "2.4"); //appVersion参数传2.4  接口标注的传 2.4
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString md5sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5sign).toUpper();
    dataMap.insert("sign", sign);

    m_getIpTimer->stop();
    m_getIpTimer->start();
    QByteArray dataArray = m_httpClint->httpPostForm(m_httpClint->httpUrl + "/server/getCloudServerIp", dataMap);

    bool hasTimeOut = false;
    if(!m_getIpTimer->isActive())
    {
        hasTimeOut = true;
    }

    m_getIpTimer->stop();

    //信息上报
    QJsonObject enterClassroomObj;
    enterClassroomObj.insert("lessonType",lessonType);
    enterClassroomObj.insert("lessonId",currentLessonId);
    enterClassroomObj.insert("userId",YMUserBaseInformation::id);
    enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
    enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
    enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
    enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
    enterClassroomObj.insert("api_name","getCloudServerIp");
    enterClassroomObj.insert("result",0);

    if(dataArray.length() <= 0)
    {
        //判断是否有缓存ip
        if("" != getBufferEnterRoomIP() && "" != getBufferEnterRoomPort())
        {
            m_port = getBufferEnterRoomPort();
            m_ipAddress = getBufferEnterRoomIP();
            if(m_listenOrClass)
            {
                enterClass();
            }
            else
            {
                enterListen();
            }
            return;
        }else{
            lessonlistRenewSignal();

            if(hasTimeOut)
            {
                enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口访问超时"));
            }else
            {
                enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口数据获取失败: 数据为空"));
            }
            YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
            return;
        }
    }

    //qDebug()<<"weqwqeqewqdataArraydataArraydataArray"<<dataArray;
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("data"))
    {
        QJsonObject dataObj = dataObject.value("data").toObject();
        //m_ipAddress = dataObj.value("domain").toString();
        m_port = QString::number(dataObj.value("port").toInt());
        m_ipAddress = dataObj.value("ip").toString();
        m_udpPort = QString::number(dataObj.value("udpPort").toInt());
        int type = dataObj.value("type").toInt();
        qDebug() << "YMLessonManagerAdapter::getCloudServer" << dataObj << type << m_ipAddress << __LINE__;

        if(type == 2)
        {
            if(m_ipAddress == "")
            {
                enterClassroomObj.insert("errMsg",QStringLiteral("dns解析失败并且无本地缓存IP，解析失败原因为") + dataArray);
                YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
                return;
            }
            resetSelectIp(1, m_ipAddress);
            if(m_listenOrClass)
            {
                enterClass();
            }
            else
            {
                enterListen();
            }
            return;
        }
        if(type == 1)
        {
            //腾讯云的 移动解析 Http DNS 服务
            //备用ip: 119.28.28.28
            QString url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
            QByteArray data = m_httpClint->httpGetIp(url.arg(des_encrypt(m_ipAddress)));
            QString IpAddress = des_decrypt(QByteArray::fromHex(data).toStdString());
            IpAddress = IpAddress.split(",").at(0);
            IpAddress = IpAddress.split(";").at(0);
            m_ipAddress = IpAddress;

            if(m_ipAddress == "")
            {
                enterClassroomObj.insert("errMsg",QStringLiteral("dns解析失败并且无本地缓存IP，解析失败原因为") + IpAddress);
                YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
                return;
            }
            //resetSelectIp(2,m_ipAddress);
            if(m_listenOrClass)
            {
                enterClass();
            }
            else
            {
                enterListen();
            }
            return;
        }
        else
        {
            m_ipAddress = "47.100.136.26";
            m_port = 5122;
            m_udpPort = 5120;
            if(m_listenOrClass)
            {
                //resetSelectIp(2,m_ipAddress);
                enterClass();
            }
            else
            {
                enterListen();
            }
        }
    }else
    {
        enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口数据获取失败:  ") + dataArray);
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
    }
}

void YMLessonManagerAdapter::getCloudServerIpTimeOut()
{
    m_getIpTimer->stop();
    //信息上报
    QJsonObject enterClassroomObj;
    enterClassroomObj.insert("lessonType",lessonType);
    enterClassroomObj.insert("lessonId",currentLessonId);
    enterClassroomObj.insert("userId",YMUserBaseInformation::id);
    enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
    enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
    enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
    enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
    enterClassroomObj.insert("result",0);
    enterClassroomObj.insert("api_name","getCloudServerIp");
    enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口访问超时"));
    YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
}

YMLessonManagerAdapter::~YMLessonManagerAdapter()
{
    this->disconnect(m_httpClint, 0, 0, 0);
}

void YMLessonManagerAdapter::onRespGetRepeatPlayer(const QString &data)
{
    QJsonObject dataObject = QJsonDocument::fromJson(data.toUtf8()).object();

    QString lessonId = QString::number(m_repeatData.value("lessonId").toInt());
    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    QString path = year.mid(0, 6).append("/").append(lessonId);
    //qDebug() << "YMLessonManagerAdapter::onRespGetRepeatPlayer"
    //<< path;
    downLoadFile(dataObject, path);
}

void YMLessonManagerAdapter::downLoadFile(QJsonObject dataObject, QString fileDir)
{
    qDebug() << "YMLessonManagerAdapter::downLoadFile dataObject " << dataObject << fileDir;
    QVariantMap result = dataObject.toVariantMap();
    QVariantList datalist = result["data"].toList();
    QVariantList filedata;
    //待定
    if(datalist.size() <= 0)
    {
        qDebug() << "YMLessonManagerAdapter::downLoadFile::data" << datalist;
        emit sigRepeatPlayer();
        return;
    }
    QVariantMap data = datalist.at(datalist.size() - 1).toMap();
    //qDebug() << "hasVoice" << data["hasVoice"];
    filedata = getStuTraila(data["id"].toString(), data["number"].toString(), fileDir);

    QString encryptPath;
    if(filedata.size() > 0)
    {
        encryptPath = filedata.at(0).toString() + "/";
        encryptPath += filedata.at(1).toString();
    }
    QFile file(encryptPath);

    if(file.size() < 1024) //录播文件, 如果小于1kb的话, 删除, 重新下载
    {
        if(file.size() == 0)
        {
            emit sigRepeatPlayer();
            return;
        }
        QDir dir(filedata.at(0).toString());
        dir.setFilter(QDir::Files);
        for(int z = 0; z < dir.count(); z ++)
        {
            dir.remove(dir[z]);
        }
        filedata = getStuTraila(data["id"].toString(), data["number"].toString(), fileDir);
        qDebug() << "YMLessonManagerAdapter::downLoadFile::data" << datalist;
    }
    if(datalist.size() > 1)
    {
        setDownValue(0, datalist.size());
    }
    else
    {
        setDownValue(0, datalist.size() + 1);
    }
    for(int a = 0; a < datalist.size(); a++)
    {
        QVariantMap data = datalist.at(a).toMap();
        if(data["hasVoice"].toInt() == 1)
        {
            if(datalist.size() == 1)
            {
                downloadChanged(1);
            }
            getStuVideo(data["id"].toString(), data["number"].toString(), fileDir);
            if(datalist.size() > 1)
            {
                downloadChanged(a);
            }
            else
            {
                downloadChanged(a + 1);
            }
        }
    }
    downloadFinished();

    QString lessonId = QString::number(m_repeatData.value("lessonId").toInt());
    QString gradeName = m_repeatData.value("gradeName").toString();
    QString subjectName = m_repeatData.value("subjectName").toString();

    QStringList courseData;
    courseData << lessonId;
    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    QString time = year.mid(0, 6);
    courseData << time;

    QByteArray arrydata;
    arrydata.append(QStringLiteral("【"));
    arrydata.append(QStringLiteral("编号")).append(lessonId.toUtf8()).append(QStringLiteral("】"));
    arrydata.append(gradeName.toUtf8()).append("/").append(subjectName.toUtf8()).append(" ").append(m_repeatData.value("realName").toString().toUtf8());
    courseData << arrydata.toHex();
    courseData << filedata.at(0).toString().toUtf8().toHex(); //文件路径进行加密
    courseData << filedata.at(1).toString();
    //qDebug() << "Cord::FilePath" << filedata.at(0).toString() << filedata.at(1).toString();

    courseData << YMUserBaseInformation::type;
    courseData << YMUserBaseInformation::token;
    courseData << YMUserBaseInformation::apiVersion;
    courseData << YMUserBaseInformation::appVersion;
    courseData << YMUserBaseInformation::userName;

#ifdef USE_OSS_UPLOAD_LOG
    courseData << YMUserBaseInformation::id;
#endif
    QString runPath = QCoreApplication::applicationDirPath();
    //qDebug() << "=====datetimeSpan.toLocalTime()====="<< datetimeSpan.toLocalTime() << currentDate.toLocalTime();
    qDebug() << "===RunPath:======" << filedata << courseData;
    qDebug() << "RunPath:" << filedata << YMUserBaseInformation::userName;

    QProcess::startDetached(runPath + "/player.exe", courseData);
}

//获取音频文件
void YMLessonManagerAdapter::getStuVideo(QString videoId, QString fileName, QString fileDir)
{
    QString m_systemPublicFilePath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/";
    m_systemPublicFilePath.append(fileDir).append("/");
    //qDebug() << "YMLessonManagerAdapter::getStuVideo"
    //<< m_systemPublicFilePath << videoId
    //   << fileName << fileDir;
    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QFile file(m_systemPublicFilePath.append(fileName).append(".mp3"));
    if(file.exists() == false)
    {
        QDateTime timess = QDateTime::currentDateTime();
        QVariantMap dataMap;
        dataMap.insert("userId", YMUserBaseInformation::id);
        dataMap.insert("videoId", videoId);
        dataMap.insert("type", YMUserBaseInformation::type);
        dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
        dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
        dataMap.insert("token", YMUserBaseInformation::token);
        dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
        QString md5Sign = YMEncryption::signMapSort(dataMap);
        QString sign = YMEncryption::md5(md5Sign).toUpper();
        dataMap.insert("sign", sign);

        QString url = m_httpClint->httpUrl + "/lesson/getStuVideo?" + md5Sign + "&sign=" + sign;

        qDebug() << "YMLessonManagerAdapter::getStuVideo: " << url << __LINE__;
        QByteArray readData = m_httpClint->httpDownloadFile(url);

        QString m_systemPublicFilePath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        m_systemPublicFilePath += "/YiMi/";
        m_systemPublicFilePath.append(fileDir).append("/");
        QDir wdir;
        QDir isDir;

        if (!isDir.exists(m_systemPublicFilePath))
        {
            wdir.mkpath(m_systemPublicFilePath);
        }

        QFile file(m_systemPublicFilePath.append(fileName).append(".mp3"));
        file.open(QIODevice::WriteOnly);
        file.write(readData);
        file.flush();
        file.close();
    }
}

//获取轨迹文件
QVariantList YMLessonManagerAdapter::getStuTraila(QString trailId, QString fileName, QString fileDir)
{
    //qDebug() << "YMLessonManagerAdapter::getStuTraila" << trailId << fileName << fileDir;
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("trailId", trailId);
    dataMap.insert("type", YMUserBaseInformation::type);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString signMd5 = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signMd5).toUpper();

    dataMap.insert("sign", sign);
    QString url = m_httpClint->httpUrl + "/lesson/getStuTrail?" + signMd5 + "&sign=" + sign;
    QByteArray data = m_httpClint->httpGetVariant(url, this);
    //qDebug() << "data::" << data.length();
    QString m_systemPublicFilePath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/";
    m_systemPublicFilePath.append(fileDir).append("/");

    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QFile file(m_systemPublicFilePath + fileName + ".txt");
    file.open(QIODevice::WriteOnly);//打开只写模式 放在写入之前
    file.write(data);//写入
    file.flush();
    file.close();

    //加密
    encrypt(m_systemPublicFilePath + fileName + ".txt", m_systemPublicFilePath + fileName + ".encrypt");
    QFile::remove(m_systemPublicFilePath + fileName + ".txt");

    QVariantList allresultlist;
    allresultlist << DebugLog::getDocumentDir().append("/YiMi/").append(fileDir);
    allresultlist << fileName.append(".encrypt");
    return allresultlist;
}

//进入旁听
void YMLessonManagerAdapter::getListen(QString userId)
{
    qDebug() << "YMLessonManagerAdapter::getListen::" << userId;
    if(userId.trimmed() == "0") //非法的user id
    {
        return;
    }

    m_listenOrClass = false;
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("lessonId", userId);
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("sysInfo", "WIN");
    dataMap.insert("deviceInfo", "1");
    dataMap.insert("appSource", "YIMI");
    dataMap.insert("umengAppKey", "597ac22d75ca350dd600227a");
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);


    QByteArray dataArray = m_httpClint->httpPostForm(m_httpClint->httpUrl + "/lesson/enterClass", dataMap);
    if(dataArray.length() <= 0)
    {
        lessonlistRenewSignal();
        return;
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "enterClass::data:" << dataObject;
    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString().toLower() == "success"
            && dataObject.value("message").toString().toUpper() == "SUCCESS")
    {
        m_classData = QJsonObject();
        m_classData = dataObject;
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_listen = dataObj.value("startFlag").toInt();
        teaInClassRoomFlag =  dataObj.value("teaInClassRoomFlag").toBool();
        reportFlag = dataObj.value("reportFlag").toInt();
        offSingle = dataObj.value("offSingle").toInt();
        applicationType = dataObj.value("applicationType").toInt();
        QString ccEnterRoom = dataObj.value("ccEnterRoom").toString();

        qDebug() << "====status====" << reportFlag << offSingle << applicationType;
        YMUserBaseInformation::m_bHasExistError = false;
        if("YES" == ccEnterRoom && 1 == offSingle && 1 == applicationType)
        {
            sigCCHasInRoom();
            return;
        }

        if(teaInClassRoomFlag)
        {
            QJsonObject teacherObj = dataObj.value("teacher").toObject();
            QString realName = teacherObj.value("realName").toString();
            QString teacherName = realName;
            emit sigIsJoinClassroom(teacherName);
            return;

        }

        YMUserBaseInformation::m_bHasExistError = false;
        getCloudServer();
    }
    else
    {
        YMUserBaseInformation::m_bHasExistError = true;
        QString strMsg = dataObject.value("message").toString();
        emit sigMessageBoxInfo(strMsg);
        qDebug() << "YMLessonManagerAdapter::getListen failed" << dataObject;
    }
}

void YMLessonManagerAdapter::enterListen()
{
    qDebug() << "YMLessonManagerAdapter::enterListen" << m_listen << teaInClassRoomFlag << applicationType << offSingle  << __LINE__;

    QString ipPort = m_port;
    QString address = m_ipAddress;
    QString udpPort = m_udpPort;
    setBufferEnterRoomIp(m_ipAddress,m_port);
    QVariantMap dataOthermap;
    dataOthermap.insert("address", address);
    dataOthermap.insert("port", ipPort);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("MD5Pwd", YMUserBaseInformation::MD5Pwd);
    dataOthermap.insert("mobileNo", YMUserBaseInformation::mobileNo);
    dataOthermap.insert("id", YMUserBaseInformation::id);
    dataOthermap.insert("lessonType", lessonType);

    dataOthermap.insert("udpPort", udpPort);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);
    if(YMUserBaseInformation::latitude != "" && YMUserBaseInformation::longitude != "")
    {
        dataOthermap.insert("lng", YMUserBaseInformation::longitude);
        dataOthermap.insert("lat", YMUserBaseInformation::latitude);
    }

    //如果是标准的试听课并且可以关单就可以上麦
    //否则就是普通的旁听
    bool isCC_CR = false;

    //applicationType == 1                     标准
    //lessonType == 1 || lessonType == 0       试听课
    //offSingle 关单权限
    if((applicationType == 1 /*&& (lessonType == 1 || lessonType == 0)*/) //标准试听课
            && offSingle == 1)
    {
        isCC_CR = true;
    }

    //非标准试听课 只要没开课旁听都不可以进
    if(!isCC_CR && m_listen != 1)
    {
        listenChange(m_listen);
        return;
    }
    QString m_systemPublicFilePath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QString iniPath;
    QString runPath = QCoreApplication::applicationDirPath();
    //追加打印, 方便通过日志分析
    qDebug() << "YMLessonManagerAdapter::enterListen" << applicationType << offSingle << teaInClassRoomFlag << isCC_CR << lessonType << __LINE__;
    if(isCC_CR)
    {
        dataOthermap.insert("plat","L"); //L旁听，T老师，可以上麦
        iniPath = (m_systemPublicFilePath + "temp.ini");
        runPath += "/classroom.exe";
    }else
    {
        dataOthermap.insert("plat","T");//L家长旁听
        iniPath = (m_systemPublicFilePath + "stutempattend.ini");
        runPath+="/attendclassroom.exe";
    }
    QFile file(iniPath);
    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();
    //qDebug() << "filePath:" << m_systemPublicFilePath + "stutempattend.ini";

    if(!file.exists())
    {
        //信息上报
        QJsonObject enterClassroomObj;
        enterClassroomObj.insert("lessonType",lessonType);
        enterClassroomObj.insert("lessonId",currentLessonId);
        enterClassroomObj.insert("userId",YMUserBaseInformation::id);
        enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
        enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
        enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
        enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
        enterClassroomObj.insert("result",0);
        enterClassroomObj.insert("errMsg",QStringLiteral("进入教室失败，配置文件不存在"));
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
    }

    if(!YMUserBaseInformation::m_bHasExistError)
    {
        YMUserBaseInformation::m_bHasExistError = false;
        QProcess *enterRoomprocess = new QProcess(this);
        enterRoomprocess->start(runPath, QStringList());
        programRuned();
        connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
    }
}

void YMLessonManagerAdapter::enterClass()
{
    qDebug() << "YMLessonManagerAdapter::enterClass" << m_listen << teaInClassRoomFlag << __LINE__;

    QString ipPort = m_port;
    QString address = m_ipAddress;
    QString udpPort = m_udpPort;
    setBufferEnterRoomIp(m_ipAddress,m_port);
    QVariantMap dataOthermap;
    dataOthermap.insert("address", address);
    dataOthermap.insert("port", ipPort);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("MD5Pwd", YMUserBaseInformation::MD5Pwd);
    dataOthermap.insert("mobileNo", YMUserBaseInformation::mobileNo);
    dataOthermap.insert("id", YMUserBaseInformation::id);
    dataOthermap.insert("lessonType", lessonType);
    dataOthermap.insert("udpPort", udpPort);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);

    if(YMUserBaseInformation::latitude != "" && YMUserBaseInformation::longitude != "")
    {
        dataOthermap.insert("lat", YMUserBaseInformation::latitude);
        dataOthermap.insert("lng", YMUserBaseInformation::longitude);
    }
    if(teaInClassRoomFlag)
    {
        dataOthermap.insert("plat","L");//L旁听，T老师
    }else{
        dataOthermap.insert("plat","T");//L旁听，T老师
    }
    QString m_systemPublicFilePath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QFile file(m_systemPublicFilePath + "temp.ini");
    //qDebug() << "m_systemPublicFilePath" << m_systemPublicFilePath;
    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();

    if(!file.exists())
    {
        //信息上报
        QJsonObject enterClassroomObj;
        enterClassroomObj.insert("lessonType",lessonType);
        enterClassroomObj.insert("lessonId",currentLessonId);
        enterClassroomObj.insert("userId",YMUserBaseInformation::id);
        enterClassroomObj.insert("userName",YMUserBaseInformation::userName);
        enterClassroomObj.insert("lessonPlanStartTime",lessonPlanStartTime);
        enterClassroomObj.insert("lessonPlanEndTime",lessonPlanEndTime);
        enterClassroomObj.insert("appVersion",YMUserBaseInformation::appVersion);
        enterClassroomObj.insert("result",0);
        enterClassroomObj.insert("errMsg",QStringLiteral("进入教室失败，配置文件不存在"));
        YMQosManager::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
    }

    if(!YMUserBaseInformation::m_bHasExistError)
    {
        YMUserBaseInformation::m_bHasExistError = false;

        QString runPath = QCoreApplication::applicationDirPath();
        runPath += "/classroom.exe";
        qDebug() << "onRespCloudServer::runPath:" << runPath;

        QProcess *enterRoomprocess = new QProcess(this);
        enterRoomprocess->start(runPath, QStringList());
        programRuned();
        connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
    }
}

void YMLessonManagerAdapter::onResponse(int reqCode, const QString &data)
{
    //qDebug() << "YMLessonManagerAdapter::onResponse" << reqCode << data;
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        requestData = data;
        m_respHandlers.remove(reqCode);
    }
}

QString YMLessonManagerAdapter::des_decrypt(const std::string &cipherText)
{
    std::string clearText; // 明文
    DES_cblock keyEncrypt;
    memset(keyEncrypt, 0, 8);
    if (key.length() <= 8)
        memcpy(keyEncrypt, key.c_str(), key.length());
    else
        memcpy(keyEncrypt, key.c_str(), 8);

    DES_key_schedule keySchedule;
    DES_set_key_unchecked(&keyEncrypt, &keySchedule);

    const_DES_cblock inputText;
    DES_cblock outputText;
    std::vector<unsigned char> vecCleartext;
    unsigned char tmp[8];

    for (int i = 0; i < cipherText.length() / 8 ; i++)
    {
        memcpy(inputText, cipherText.c_str() + i * 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_DECRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCleartext.push_back(tmp[j]);
    }

    //    if (cipherText.length() % 8 != 0)
    //    {
    //        int tmp1 = cipherText.length() / 8 * 8;
    //        int tmp2 = cipherText.length() - tmp1;
    //        memset(inputText, 0, 8);
    //        memcpy(inputText, cipherText.c_str() + tmp1, tmp2);
    //        // 解密函数
    //        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_DECRYPT);
    //        memcpy(tmp, outputText, 8);
    //        for (int j = 0; j < 8; j++)
    //            vecCleartext.push_back(tmp[j]);
    //    }
    clearText.clear();
    clearText.assign(vecCleartext.begin(), vecCleartext.end());
    return QString::fromStdString(clearText);
}

QString YMLessonManagerAdapter::des_encrypt(const QString &clearText)
{
    DES_cblock keyEncrypt;
    memset(keyEncrypt, 0, 8);

    if (key.length() <= 8)
        memcpy(keyEncrypt, key.c_str(), key.length());
    else
        memcpy(keyEncrypt, key.c_str(), 8);

    DES_key_schedule keySchedule;
    DES_set_key_unchecked(&keyEncrypt, &keySchedule);

    const_DES_cblock inputText;
    DES_cblock outputText;
    std::vector<unsigned char> vecCiphertext;
    unsigned char tmp[8];
    for (int i = 0; i < clearText.length() / 8; i++)
    {
        memcpy(inputText, clearText.toStdString().c_str() + i * 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_ENCRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCiphertext.push_back(tmp[j]);
    }

    if (clearText.length() % 8 != 0)
    {
        int tmp1 = clearText.length() / 8 * 8;
        int tmp2 = clearText.length() - tmp1;
        memset(inputText, 8 - clearText.length() % 8, 8);
        memcpy(inputText, clearText.toStdString().c_str() + tmp1, tmp2);

        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_ENCRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCiphertext.push_back(tmp[j]);
    }
    else
    {
        memset(inputText, 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_ENCRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCiphertext.push_back(tmp[j]);
    }

    QByteArray arr;
    for (int i = 0; i < vecCiphertext.size(); i++)
    {
        arr.append(vecCiphertext.at(i));
    }
    return arr.toHex();
}

void YMLessonManagerAdapter::encrypt(QString source, QString target)
{
    QFile file(source);
    if (!file.open(QIODevice::ReadOnly))
    {
        //   //   // qDebug() << "open file error:file path = " << source;
        return;
    }
    QFile outFile(target);
    if (!outFile.open(QIODevice::WriteOnly))
    {
        //   //   // qDebug() << "open file error:file path = " << target;
        return;
    }

    QDataStream out(&outFile);
    QTextStream in(&file);
    in.setCodec("UTF-8");
    while (! in.atEnd())
    {
        QString line = in.readLine();
        //qDebug() << "asdasdas" << line;
        out << YMCrypt::encrypt(line);
    }
}

QList<QString> YMLessonManagerAdapter::decrypt(QString source)
{
    QFile file(source);
    QList<QString> list;
    if (!file.open(QIODevice::ReadOnly))
    {
        //   //   // qDebug() << "open file error:file path = " << source;
        return list;
    }
    QDataStream in(&file);
    while (! in.atEnd())
    {
        QString line;
        in >> line;
        list.append(YMCrypt::decrypt(line));
    }
    return list;

}

QJsonObject YMLessonManagerAdapter::getLiveLessonDetailData(QString lessonId)
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("lessonId", lessonId);
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);

    QByteArray dataArray = m_httpClint->httpPostForm(m_httpClint->httpUrl + "/lesson/getLvbLessonInfo", dataMap);
    //qDebug()<< QString::fromUtf8( dataArray)<<"231131231321321";
    QJsonObject obj = QJsonDocument::fromJson(dataArray).object();
    return obj;//QVariant( dataArray).toJsonObject();
}

void YMLessonManagerAdapter::resetSelectIp(int type, QString ip)
{
    this->errorLog("YMLessonManagerAdapter::resetSelectIp");
    QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString systemPublicFilePath;
    if (docPath == "")
    {
        systemPublicFilePath = "C:/";
    }
    else
    {
        systemPublicFilePath = docPath + "/";
    }
    systemPublicFilePath += "YiMi/temp/";
    QDir dir;
    if( !dir.exists(systemPublicFilePath))
    {
        dir.mkdir(systemPublicFilePath);
    }
    QString fileName = systemPublicFilePath + "/stuconfig.ini";

    QString selectIp;
    QSettings * m_settings = new QSettings (fileName, QSettings ::IniFormat);

    m_settings->beginGroup("SelectItem");
    selectIp = m_settings->value("ipitem").toString();
    if(type == 1)
    {
        m_settings->setValue("ipitem", ip);
    }
    if(type == 2 && selectIp == "")
    {
        m_settings->setValue("ipitem", ip);
    }

    m_settings->endGroup();

}

void YMLessonManagerAdapter::getEmLessons(QJsonObject data)
{
    QString lessonType = data.value("lessonType").toString();
    QString subjectId = data.value("subjectId").toString();
    QString gradeId = data.value("gradeId").toString();
    QString startTime = data.value("startTime").toString();
    QString endTime = data.value("endTime").toString();
    QString clientId = data.value("clientId").toString();
    QString lessonId = data.value("lessonId").toString();
    QString studentName = data.value("studentName").toString();
    QString teacherName = data.value("teacherName").toString();
    int pageSize = data.value("pageSize").toInt();
    int pageIndex = data.value("pageIndex").toInt();
    QDateTime currentTime = QDateTime::currentDateTime();

    //qDebug() << "YMLessonManagerAdapter::getEmLessons" << subjectId << gradeId << clientId << lessonType;

    QVariantMap dataMap;
    if(lessonType != "" )
    {
        dataMap.insert("lessonType", lessonType.toInt());
    }
    else
    {
        dataMap.insert("lessonType", lessonType);
    }

    if(subjectId != "")
    {
        dataMap.insert("subjectId", subjectId.toInt());
    }
    else
    {
        dataMap.insert("subjectId", subjectId);
    }

    if(gradeId != "")
    {
        dataMap.insert("gradeId", gradeId.toInt());
    }
    else
    {
        dataMap.insert("gradeId", gradeId);
    }

    if(clientId != "")
    {
        dataMap.insert("clientId", clientId.toLong());
    }
    else
    {
        dataMap.insert("clientId", clientId);
    }

    if(lessonId != "")
    {
        dataMap.insert("lessonId", lessonId.toLong());
    }
    else
    {
        dataMap.insert("lessonId", lessonId);
    }
    dataMap.insert("pageIndex", pageIndex);
    dataMap.insert("pageSize", pageSize);
    dataMap.insert("startTime", startTime);
    dataMap.insert("endTime", endTime);
    dataMap.insert("studentName", studentName);
    dataMap.insert("teacherName", teacherName);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("apiVersion", "3.0"); //接口标注3.0
    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);
    //qDebug() << "=======YMLessonManagerAdapter::getEmLessons======" << dataMap;
    QString url = m_httpClint->httpUrl + "/lesson/getEmLessons";
    QByteArray dataArray = m_httpClint->httpPostForm(url, dataMap);
    QJsonObject objData = QJsonDocument::fromJson(dataArray).object();
    QJsonObject emLessonObj =  objData.value("data").toObject();
    this->errorLog("YMLessonManagerAdapter::getEmLessons");
    //qDebug() << "YMLessonManagerAdapter::getEmLessons" << emLessonObj;
    emit sigEmLesson(emLessonObj);
}

void YMLessonManagerAdapter::getUserSubjectInfo()
{
    //this->errorLog("YMLessonManagerAdapter::getUserSubjectInfo");
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);
    QString url = m_httpClint->httpUrl + "/lesson/getUserSubjectInfo";
    QByteArray dataArray = m_httpClint->httpPostForm(url, dataMap);
    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject objData = QJsonDocument::fromJson(dataArray).object();
    QJsonObject dataObj = objData.value("data").toObject();
    //this->errorLog("YMLessonManagerAdapter::getEmLessons::" + dataObj.size());
    //qDebug() << "YMLessonManagerAdapter::getUserSubjectInfo" << dataObj;
    emit sigUserSubjectInfo(dataObj);
}

int YMLessonManagerAdapter::getLessonComment(QString lessonId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("lessonId", lessonId);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);
    QString url = m_httpClint->httpUrl + "/lesson/getLessonComment";
    QByteArray dataArray = m_httpClint->httpPostForm(url, dataMap);

    if(dataArray.length() == 0)
    {
        return 0;
    }

    QJsonObject objJson = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "===objJson===" << objJson;
    QJsonObject objData = objJson.value("data").toObject();
    int iApplicationType = objData.value("applicationType").toInt();
    int iLessonType = objData.value("lessonType").toInt();
    int iReportFlag = objData.value("reportFlag").toInt();


    int dataMark = 0;//0 表示没有试听课报告 1查看试听课报告 2填写试听课报告
    if(iApplicationType == 1 && (iLessonType ==0 || iLessonType == 1))
    {
        if(iReportFlag == 1)
        {
            dataMark = 1;
        }
        else
        {
            dataMark = 1;
        }
    }
    qDebug() << "===YMLessonManagerAdapter::getReportFlag====11" << iApplicationType << iLessonType << iReportFlag;
    qDebug() << "===YMLessonManagerAdapter::getReportFlag====22" << lessonId << dataMark << objJson;

    return dataMark;
}

int YMLessonManagerAdapter::getReportFlag(QString lessonId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("lessonId", lessonId);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);
    QString url = m_httpClint->httpUrl + "/lesson/getLessonReportFlag";//
    QByteArray dataArray = m_httpClint->httpPostForm(url, dataMap);

    if(dataArray.length() == 0)
    {
        return 0;
    }

    QJsonObject objData = QJsonDocument::fromJson(dataArray).object();
    int dataMark = objData.value("data").toInt();

    qDebug() << "===YMLessonManagerAdapter::getReportFlag====" << url << dataMark;
    return dataMark;
}

//获取年级信息
QJsonObject YMLessonManagerAdapter::getGrades()
{
    QString url = m_httpClint->httpUrl + "/lesson/getGrades";
    QByteArray dataArray = m_httpClint->httpGetIp(url);
    QJsonObject objData;
    if(dataArray.length() == 0)
    {
        return objData;
    }

    objData = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "====YMLessonManagerAdapter::getGrades=====" << url << objData;
    return objData;
}

void YMLessonManagerAdapter::setBufferEnterRoomIp(QString currentIp,QString port)
{
    QSettings m_setting("QtEnter.dll", QSettings::IniFormat);
    m_setting.beginGroup("EnterIp");
    m_setting.setValue("currentIpTea",currentIp);
    m_setting.setValue("currentPortTea",port);
    m_setting.endGroup();
}

QString YMLessonManagerAdapter::getBufferEnterRoomIP()
{
    QSettings m_setting("QtEnter.dll", QSettings::IniFormat);
    m_setting.beginGroup("EnterIp");
    return m_setting.value("currentIpTea").toString();
}

QString YMLessonManagerAdapter::getBufferEnterRoomPort()
{
    QSettings m_setting("QtEnter.dll", QSettings::IniFormat);
    m_setting.beginGroup("EnterIp");
    return m_setting.value("currentPortTea").toString();
}
