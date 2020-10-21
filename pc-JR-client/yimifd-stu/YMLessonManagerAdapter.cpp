#include "YMLessonManagerAdapter.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"

#include <QStandardPaths>
#include <QCoreApplication>
#include "YMFileTransportEventHandler.h"
#include "../../pc-common/pingback/pingbackmanager.h"
/*
*获取课程表、课程列表、进入教室类
*
*/

std::string key = "Q-RRt2H2";

YMLessonManagerAdapter::YMLessonManagerAdapter(QObject *parent)
    : QObject(parent)
{
    m_httpClint = YMHttpClient::defaultInstance();
    connect(m_httpClint, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut()));

    m_timer = new QTimer();
    m_timer->setInterval(20000);
    m_timer->setSingleShot(true);

    m_getIpTimer = new QTimer();
    m_getIpTimer->setInterval(20000);
    m_getIpTimer->setSingleShot(true);
}

//获取学生课程表
void YMLessonManagerAdapter::getStudentLessonInfo(QString dateTime)
{
    QJsonObject loadScheduleDataObj;
    loadScheduleDataObj.insert("userId",YMUserBaseInformation::id);
    loadScheduleDataObj.insert("userName",YMUserBaseInformation::userName);
    loadScheduleDataObj.insert("appVersion",YMUserBaseInformation::appVersion);
    loadScheduleDataObj.insert("actionType","lessonSchedule");
    YMQosManagerForStuM::gestance()->addBePushedMsg("loadScheduleData", loadScheduleDataObj);

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;

    reqParm.insert("queryDate", dateTime);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", "3.0"); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    QString url = m_httpClint->httpUrl + "/lesson/getStuLessonSchedule";
    QByteArray dataByte = m_httpClint->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    //qDebug() << "YMLessonManagerAdapter::getStudentLessonInfo" << objectData;

    emit studentLessonInfoChanged(objectData);
    emit lodingFinished();
    if(objectData.value("success").toBool())
    {
        loadScheduleDataObj.insert("result","1");
        loadScheduleDataObj.insert("errMsg","");
    }else
    {
        loadScheduleDataObj.insert("result","0");
        loadScheduleDataObj.insert("errMsg","get lessonlist data fail ");
    }
    YMQosManagerForStuM::gestance()->addBePushedMsg("loadScheduleDataFinished", loadScheduleDataObj);
}

//获取学生课程列表
void YMLessonManagerAdapter::getStudentLessonListInfo(QJsonObject data)
{
    QJsonObject loadScheduleDataObj;
    loadScheduleDataObj.insert("userId",YMUserBaseInformation::id);
    loadScheduleDataObj.insert("userName",YMUserBaseInformation::userName);
    loadScheduleDataObj.insert("appVersion",YMUserBaseInformation::appVersion);
    loadScheduleDataObj.insert("actionType","lessonList");
    YMQosManagerForStuM::gestance()->addBePushedMsg("loadScheduleData", loadScheduleDataObj);

    QDateTime timess = QDateTime::currentDateTime();

    QString keywords = data.value("keywords").toString();
    int pageIndex = data.value("pageIndex").toInt();
    int pageSize = data.value("pageSize").toInt();
    QString querySubject = data.value("querySubject").toString();
    QString queryStartDate = data.value("queryStartDate").toString().replace("/", "-");
    QString queryEndDate = queryStartDate;
    QString queryStatus = data.value("queryStatus").toString();
    QString queryPeriod = data.value("queryPeriod").toString();

    QVariantMap dataMap;
    //    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", "5.0"); //接口标注传3.0
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    dataMap.insert("keywords", keywords);
    dataMap.insert("pageIndex", pageIndex);
    dataMap.insert("pageSize", pageSize);
    dataMap.insert("querySubject", querySubject);
    dataMap.insert("queryStartDate", queryStartDate);
    dataMap.insert("queryEndDate", queryEndDate);
    dataMap.insert("queryStatus", queryStatus);
    //    dataMap.insert("queryPeriod", queryPeriod);

    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);

    QString url = m_httpClint->httpUrl + "/oneToMore/lesson/v2/studentLessonList";

    QByteArray dataByte = m_httpClint->httpPostVariant(url, dataMap);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    QJsonObject lessonData = objectData.value("data").toObject();

    qDebug() << "YMLessonManagerAdapter::getStudentLessonListInfo" << url << dataMap<< objectData;
    emit studentLesonListInfoChanged(lessonData);
    emit lodingFinished();

    if(objectData.value("success").toBool())
    {
        loadScheduleDataObj.insert("result","1");
        loadScheduleDataObj.insert("errMsg","");
    }else
    {
        loadScheduleDataObj.insert("result","0");
        loadScheduleDataObj.insert("errMsg","get lessonlist data fail ");
    }
    YMQosManagerForStuM::gestance()->addBePushedMsg("loadScheduleDataFinished", loadScheduleDataObj);
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
    YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroom", enterClassroomObj);

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
        enterClassroomObj.insert("errType",1);
        enterClassroomObj.insert("errMsg",QStringLiteral("客户端没有连接网络"));
        YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        emit requestTimerOut();
        return;
    }
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
    m_timer->stop();
    m_timer->start();
    connect(m_timer, SIGNAL(timeout()), this, SLOT(enterClassTimerOut()));
}

void YMLessonManagerAdapter::enterClassTimerOut()
{
    m_timer->stop();
    emit requestTimerOut();
    qDebug() << "YMLessonManagerAdapter::getEnterClassTimerOut";
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
    enterClassroomObj.insert("result",0);
    enterClassroomObj.insert("api_name","enterClass");

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if(200 != statusCode)
    {
        lessonlistRenewSignal();
        enterClassroomObj.insert("errType",3);
        enterClassroomObj.insert("errMsg",QStringLiteral("接口服务器系统异常，接口返回") + QString::number(statusCode));
        YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        return;
    }

    QByteArray dataArray = reply->readAll();
    if(dataArray.length() <= 0)
    {
        lessonlistRenewSignal();
        if(hasTimeOut)
        {
            enterClassroomObj.insert("errType",2);
            enterClassroomObj.insert("errMsg",QStringLiteral("enterClass接口访问超时"));
        }else
        {
            enterClassroomObj.insert("errType",5);
            enterClassroomObj.insert("errMsg",QStringLiteral("enterClass接口返回数据异常，接口返回数据为空"));
        }
        YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
        return;
    }

    YMUserBaseInformation::m_bHasExistError = false;
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString().toLower() == "success"
            && dataObject.value("message").toString().toUpper() == "SUCCESS")
    {
        m_classData = dataObject;

        if(YMUserBaseInformation::stuUserType)
        {
            getCloudServer();
            //qDebug()<<QStringLiteral("学生进入教室");
        }
        else
        {
            //qDebug()<<QStringLiteral("老师进入教室");
            if(dataObject.value("data").toObject().value("startFlag") == 1)
            {
                getCloudServer();
            }
            else
            {
                emit lessonlistRenewSignal();
                emit showEnterRoomStatusTips(QStringLiteral("还未开始上课，暂时无法旁听"));
                enterClassroomObj.insert("errType",9);
                enterClassroomObj.insert("errMsg",QStringLiteral("还未开始上课，暂时无法旁听"));
                YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
                //qDebug()<<QStringLiteral("还未开始上课，暂时无法旁听")<<" m_classData = m_classData ="<<dataObject.value("data").toObject().value("startFlag");
            }
        }
    }
    else
    {
        YMUserBaseInformation::m_bHasExistError = true;
        QString strMsg = dataObject.value("message").toString();
        emit sigMessageBoxInfo(strMsg);
        qDebug() << "YMLessonManagerAdapter::getEnterClassresult failed." << dataObject;
        if(strMsg == "" || strMsg.contains(QStringLiteral("云教室尚未开放")))//过滤无效数据
        {
            enterClassroomObj.insert("result",1);
            enterClassroomObj.insert("errMsg","");
        }else
        {
            enterClassroomObj.insert("errType",3);
            enterClassroomObj.insert("errMsg",QStringLiteral("接口返回错误码，接口返回错误码为") + strMsg);
        }
        YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
    }
}

////查看课件
//void YMLessonManagerAdapter::getLookCourse(QJsonObject lessonInfo)
//{
//    //qDebug() << "YMLessonManagerAdapter::getLookCourse:" << lessonInfo;
//    QString startTime = lessonInfo.value("startTime").toString();
//    QString lessonId = QString::number(lessonInfo.value("lessonId").toInt());

//    QStringList courseData;
//    courseData << "STU";
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

//    qDebug() << "YMLessonManagerAdapter::getLookCourse"
//             << courseData << startTime << lessonId
//             << time << runPath +"/CourwarePreviewer.exe" ;
//    process->start(runPath + "/CourwarePreviewer.exe",courseData);
//}

//查看旧课件
void YMLessonManagerAdapter::getLookCourse(QJsonObject lessonInfo)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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
                               "  \"isMiniClass\": 1,"
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
            .arg("5.0") \
            .arg(YMUserBaseInformation::appVersion) \
            .arg(YMUserBaseInformation::deviceInfo) \
            .arg(YMUserBaseInformation::id) \
            .arg(YMUserBaseInformation::token) \
            .arg(QString::number(lessonInfo.value("lessonId").toInt())) \
            .arg(QString::number(lessonInfo.value("lessonStatus").toInt()))  \
            .arg(YMUserBaseInformation::userName);

    QString filename("courware.ini");
    QFile file(m_systemPublicFilePath + filename);
    file.open(QIODevice::WriteOnly);
    file.write(tempdata.toLatin1());
    file.flush();
    file.close();
    QString runPath = QCoreApplication::applicationDirPath();
    QProcess *process = new QProcess(this);
    process->start(runPath + "/CourwarePreviewerOld.exe", QStringList());
}

//查看旧录播
void YMLessonManagerAdapter::getRepeatPlayer(QJsonObject lessonInfo)
{

    qDebug() << "YMLessonManagerAdapter::getRepeatPlayer" << lessonInfo;
    tempLessonIds = QString::number(lessonInfo.value("lessonId").toInt());

    m_repeatData = lessonInfo;
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("lessonId", tempLessonIds);
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("type", YMUserBaseInformation::type);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    QString url = m_httpClint->httpUrl;
    url.append("/lesson/getStuTrailVideoList?");

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
        //  // qDebug()<<it.key()<<it.value();
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

    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), this, SLOT(getRecorderresult(QNetworkReply*)));

    httpAccessmanger->post(httpRequest, "");
}

void YMLessonManagerAdapter::getRecorderresult(QNetworkReply *reply)
{
    QByteArray dataArray = reply->readAll();

    //qDebug()<<"dataarray"<<dataArray;
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();

    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    //qDebug() << "year::" << year;// << lessonInfo;
    QString path = year.mid(0, 6).append("/").append(tempLessonIds);

    downLoadFile(dataObject, path);
    //        QStringList courseData;
    //        QProcess *playerProcess= new QProcess(this);
    //        playerProcess->startDetached("C:/Users/Administrator/Desktop/yimi_pc/yimifudao.exe",courseData);

}

//下载录播文件
void YMLessonManagerAdapter::downLoadFile(QJsonObject dataObject, QString fileDir)
{
    QJsonArray dataArray = dataObject.value("data").toArray();
    QJsonObject dataObj;
    qDebug() << "YMLessonManagerAdapter::downLoadFile::data" << dataObject << dataArray.size() << __LINE__;

    if(dataArray.size() > 0)
    {
        dataObj =  dataArray.at(dataArray.size() - 1).toObject(); //获取最后一条数据得到录播轨迹文件
    }
    else
    {
        emit sigRepeatPlayer();
        return;
    }

    QVariantList filedata;

    QString id = QString::number(dataObj.value("id").toInt());
    QString number = QString::number(dataObj.value("number").toInt());
    filedata = getStuTraila(id, number, fileDir); //下载轨迹文件

    QString encryptPath;
    if(filedata.size() > 0)
    {
        encryptPath = filedata.at(0).toString() + "/";
        encryptPath += filedata.at(1).toString();
    }
    QFile file(encryptPath);
    qDebug() << "YMLessonManagerAdapter::downLoadFile::data" << file.size() << __LINE__;

    if(file.size() < 1024) //录播文件, 如果小于1kb的话, 删除, 重新下载
    {
        if(file.size() == 0)
        {
            emit sigRepeatPlayer();
            return;
        }
        QDir dir(filedata.at(0).toString());
        dir.setFilter(QDir::Files);
        for(uint z = 0; z < dir.count(); z ++)
        {
            dir.remove(dir[z]);
        }
        filedata = getStuTraila(id, number, fileDir);
        //qDebug() << "YMLessonManagerAdapter::downLoadFile::data" << datalist;
    }
    if(dataArray.size() > 1)
    {
        setDownValue(0, dataArray.size()); //设置进度条开始和结束大小信号
    }
    else
    {
        setDownValue(0, dataArray.size() + 1);
    }
    //循环下载
    for(int i = 0; i < dataArray.size(); i++)
    {
        QJsonObject childObj = dataArray.at(i).toObject();
        QString id = QString::number(childObj.value("id").toInt());
        QString number = QString::number(childObj.value("number").toInt());
        int hasVoice = childObj.value("hasVoice").toInt();
        if(hasVoice == 1)
        {
            if(dataArray.size() == 1)
            {
                downloadChanged(1);
            }
            getStuVideo(id, number, fileDir);
            if(dataArray.size() > 1)
            {
                downloadChanged(i);
            }
            else
            {
                downloadChanged(i + 1);
            }
        }
    }
    //下载完成信号
    downloadFinished();
    //qDebug()<<QStringLiteral("下载结束ssssssssssss");

    QString lessonId = QString::number(m_repeatData.value("lessonId").toInt());
    QString subject = m_repeatData.value("subject").toString();
    QString names = m_repeatData.value("name").toString();

    QStringList courseData;
    courseData << lessonId;
    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    QString time;// = year.mid(0,6);
    courseData << time;
    QByteArray arrydata;
    arrydata.append(QStringLiteral("【"));
    arrydata.append(QStringLiteral("编号")).append(lessonId.toLatin1()).append(QStringLiteral("】 ")).append(subject.toUtf8()).append(QStringLiteral("/")).append(names.toUtf8()).append(" ").append(m_repeatData.value("teacherName").toString());
    courseData << arrydata.toHex();

    courseData << filedata.at(0).toString().toUtf8().toHex();//路径加密
    courseData << filedata.at(1).toString();

    courseData << YMUserBaseInformation::type;
    courseData << YMUserBaseInformation::token;
    courseData << YMUserBaseInformation::apiVersion;
    courseData << YMUserBaseInformation::appVersion;
    courseData << YMUserBaseInformation::userName;


#ifdef USE_OSS_UPLOAD_LOG
    courseData << YMUserBaseInformation::id;
#endif
    //qDebug() << "YMLessonManagerAdapter::downLoadFile player.exe start begin"<<filedata.size() ;
    QString runPath = QCoreApplication::applicationDirPath();
    QProcess *playerProcess = new QProcess(this);
    playerProcess->start(runPath + "/playerOld.exe", courseData);
    //qDebug() << "YMLessonManagerAdapter::downLoadFile player.exe startfinish" ;
    // process->deleteLater();
    //    QString runPath = QCoreApplication::applicationDirPath();
    //     //QStringList courseData;
    //    QProcess *playerProcess= new QProcess(this);
    //    playerProcess->startDetached("C:/Users/Administrator/Desktop/yimi_pc/yimifudao.exe",courseData);

}

//获取录播文件信息进行加密文件
QVariantList YMLessonManagerAdapter::getStuTraila(QString trailId, QString fileName, QString fileDir)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/";
    m_systemPublicFilePath.append(fileDir).append("/");
    QVariantList allresultlist;
    if(QFile::exists(m_systemPublicFilePath + fileName + ".encrypt") == false )
    {
        isdownLoad = true ;

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
        //QString dataStr;
        qDebug() << "YMLessonManagerAdapter::getStuTraila::data" << data.length(); // << dataStr.prepend(data);


        QDir isDir;

        //设置顶端配置路径
        if (!isDir.exists(m_systemPublicFilePath))
        {
            isDir.mkpath(m_systemPublicFilePath);
        }

        QFile file(m_systemPublicFilePath + fileName + ".txt");
        file.open(QIODevice::WriteOnly);//打开只写模式 放在写入之前
        file.write(data);//写入
        file.flush();
        file.close();

        //加密
        encrypt(m_systemPublicFilePath + fileName + ".txt", m_systemPublicFilePath + fileName + ".encrypt");
        QFile::remove(m_systemPublicFilePath + fileName + ".txt");
    }
    else
    {
        isdownLoad = false;
    }
    allresultlist << QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation).append("/YiMi/").append(fileDir);
    allresultlist << fileName.append(".encrypt");
    //qDebug()<<"fdsadddddd"<<allresultlist;
    return allresultlist;
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

    for (uint i = 0; i < cipherText.length() / 8 ; i++)
    {
        memcpy(inputText, cipherText.c_str() + i * 8, 8);
        DES_ecb_encrypt(&inputText, &outputText, &keySchedule, DES_DECRYPT);
        memcpy(tmp, outputText, 8);

        for (int j = 0; j < 8; j++)
            vecCleartext.push_back(tmp[j]);
    }

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
    for (uint i = 0; i < vecCiphertext.size(); i++)
    {
        arr.append(vecCiphertext.at(i));
    }
    return arr.toHex();
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
//加密函数
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

void YMLessonManagerAdapter::enterClass()
{
    QString ipPort = m_port;
    QString address = m_ipAddress;
    QString udpPort = m_udpPort;
    setBufferEnterRoomIp(m_ipAddress,m_port);
    //qDebug() << "address:" << address;
    QVariantMap dataOthermap;
    dataOthermap.insert("address", address);
    dataOthermap.insert("port", ipPort);
    dataOthermap.insert("udpPort", udpPort);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);

    dataOthermap.insert("plat", "S");

    dataOthermap.insert("lessonType", lessonType);
    //qDebug()<<QStringLiteral("课程类型 ")<<lessonType;
    // 经纬度 默认为 0
    if(YMUserBaseInformation::geolocation.split(",").size() == 2)
    {
        dataOthermap.insert("lng", YMUserBaseInformation::geolocation.split(",").at(0)); //维度
        dataOthermap.insert("lat", YMUserBaseInformation::geolocation.split(",").at(1)); //经度
    }
    else
    {
        dataOthermap.insert("lat", "0");
        dataOthermap.insert("lng", "0");
    }
    //拼接两位随机数 旁听的时候加

    if(YMUserBaseInformation::stuUserType)
    {
        dataOthermap.insert("id", YMUserBaseInformation::id);
    }
    else
    {
        qsrand(QTime(0, 0, 0).secsTo(QTime::currentTime()));

        QString  tempstring = QString::number(qrand() % 100);
        if(tempstring.length() == 1)
        {
            tempstring = "0" + tempstring;
        }
        dataOthermap.insert("id", YMUserBaseInformation::id + tempstring);
    }

    dataOthermap.insert("mobileNo", YMUserBaseInformation::mobileNo);
    dataOthermap.insert("MD5Pwd", YMUserBaseInformation::MD5Pwd);

    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }

    QString filename = "";
    if(YMUserBaseInformation::stuUserType)
    {
        filename = "stutemp.ini";
    }
    else
    {
        filename = "stutempattend.ini";
    }
    QFile file(m_systemPublicFilePath + filename);
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
        enterClassroomObj.insert("errType",6);
        enterClassroomObj.insert("errMsg",QStringLiteral("进入教室失败，配置文件不存在"));
        YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
    }

    QString runPath = QCoreApplication::applicationDirPath();

    //qDebug() << "onRespCloudServer::runPath:" << runPath;
    QProcess *enterRoomprocess = new QProcess(this);
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
    //enterRoomprocess->start(runPath,QStringList());
    //attendclassroom
    if(YMUserBaseInformation::stuUserType)
    {
        runPath += "/teastudentclassroom.exe";
    }
    else
    {
        runPath += "/attendclassroom.exe";
    }

    if(!YMUserBaseInformation::m_bHasExistError)
    {
        YMUserBaseInformation::m_bHasExistError = false;
        enterRoomprocess->start(runPath, QStringList());
        enterRoomprocess->waitForStarted(5000);
        emit hideEnterClassRoomItem();
    }

    downloadFinished();
}

//保存录播文件
void YMLessonManagerAdapter::getStuVideo(QString videoId, QString fileName, QString fileDir)
{
    QString systemPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString mp3Path = systemPath + "/YiMi/" + fileDir + "/";
    //qDebug() << "YMLessonManagerAdapter::getStuVideo" << mp3Path << videoId << fileName << fileDir;

    QDir isDir; //设置顶端配置路径
    if (!isDir.exists(mp3Path))
    {
        isDir.mkpath(mp3Path);
    }

    QFile file(mp3Path.append(fileName).append(".mp3"));
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
        QByteArray readData = m_httpClint->httpDownloadFile(url);

        file.open(QIODevice::WriteOnly);
        file.write(readData);
        file.flush();
        file.close();
    }
}

void YMLessonManagerAdapter::getCloudServer()
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
    enterClassroomObj.insert("api_name","getCloudServerIp");

    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("appVersion", "2.4"); //appVersion参数传2.4  接口标注的传 2.4
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString md5sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5sign).toUpper();
    dataMap.insert("sign", sign);
    // QString url = m_httpClint->httpUrl + "/server/getCloudServer";
    QString url = m_httpClint->httpUrl + "/server/getCloudServerIp";

    m_getIpTimer->stop();
    m_getIpTimer->start();

    QByteArray dataArray = m_httpClint->httpPostVariant(url, dataMap);

    bool hasTimeOut = false;
    if(!m_getIpTimer->isActive())
    {
        hasTimeOut = true;
    }

    m_getIpTimer->stop();

    if(dataArray.length() <= 0)
    {
        //判断是否有缓存ip
        if("" != getBufferEnterRoomIP() && "" != getBufferEnterRoomPort())
        {
            m_port = getBufferEnterRoomPort();
            m_ipAddress = getBufferEnterRoomIP();
            enterClass();
            return;
        }else
        {

            lessonlistRenewSignal();
            if(hasTimeOut)
            {
                enterClassroomObj.insert("errType",2);
                enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口访问超时"));
            }else
            {
                enterClassroomObj.insert("errType",4);
                enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口数据获取失败: 数据为空"));
            }
            YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
            return;
        }
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("data"))
    {
        QJsonObject dataObj = dataObject.value("data").toObject();
        //m_ipAddress = dataObj.value("domain").toString();
        m_port = QString::number(dataObj.value("port").toInt());
        m_ipAddress = dataObj.value("ip").toString();
        m_udpPort = QString::number(dataObj.value("udpPort").toInt());

        //qDebug() << "onRespCloudServer::ip" << m_ipAddress << m_port;

        int type = dataObj.value("type").toInt();

        if(type == 2) //服务端指定Ip
        {
            if(m_ipAddress == "")
            {
                enterClassroomObj.insert("errType",6);
                enterClassroomObj.insert("errMsg",QStringLiteral("dns解析失败并且无本地缓存IP，解析失败原因为") + dataArray);
                YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
                return;
            }
            resetSelectIp(1, m_ipAddress);
            enterClass();
            return;
        }
        if(type == 1) //服务器未指定Ip
        {
            //腾讯云的 移动解析 Http DNS 服务
            //备用ip: 119.28.28.28
            QString url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
            QByteArray dataArray = m_httpClint->httpGetIp(url.arg(des_encrypt(m_ipAddress)));

            QString IpAddress = des_decrypt(QByteArray::fromHex(dataArray).toStdString());

            IpAddress = IpAddress.split(",").at(0);
            IpAddress = IpAddress.split(";").at(0);
            m_ipAddress = IpAddress;
            if(m_ipAddress == "")
            {
                enterClassroomObj.insert("errType",6);
                enterClassroomObj.insert("errMsg",QStringLiteral("dns解析失败并且无本地缓存IP，解析失败原因为") + IpAddress);
                YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
                return;
            }

            //resetSelectIp(2,m_ipAddress);
            enterClass();
            return;
        }
        else
        {
            m_ipAddress = "120.132.3.5";
            m_port = "5122";
            m_udpPort = "5120";
            //resetSelectIp(2,m_ipAddress);
            enterClass();
        }
    }else
    {
        enterClassroomObj.insert("errType",4);
        enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口数据获取失败:  ") + dataArray);
        YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
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
    enterClassroomObj.insert("errType",2);
    enterClassroomObj.insert("errMsg",QStringLiteral("getCloudServerIp接口访问超时"));
    YMQosManagerForStuM::gestance()->addBePushedMsg("enterClassroomFinished", enterClassroomObj);
}

YMLessonManagerAdapter::~YMLessonManagerAdapter()
{
    this->disconnect(m_httpClint, 0, 0, 0);
}

void YMLessonManagerAdapter::onResponse(int reqCode, const QString &data)
{
    //qDebug() << "YMLessonManagerAdapter::onResponse" << reqCode;
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
    }
}

void YMLessonManagerAdapter::setUserType(bool isStuUser)
{
    YMUserBaseInformation::stuUserType = isStuUser;
    //qDebug()<<"YMUserBaseInformation::stuUserType="<<isStuUser;
}

void YMLessonManagerAdapter::resetSelectIp(int type, QString ip)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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
    //    qDebug() << "===YMLessonManagerAdapter::getReportFlag====11" << iApplicationType << iLessonType << iReportFlag;
    //    qDebug() << "===YMLessonManagerAdapter::getReportFlag====22" << lessonId << dataMark << objJson;

    return dataMark;
}

void YMLessonManagerAdapter::setBufferEnterRoomIp(QString currentIp,QString port)
{
    QSettings m_setting("QtEnter.dll", QSettings::IniFormat);
    m_setting.beginGroup("EnterIp");
    m_setting.setValue("currentIpStu",currentIp);
    m_setting.setValue("currentPortStu",port);
    m_setting.endGroup();
}

QString YMLessonManagerAdapter::getBufferEnterRoomIP()
{
    QSettings m_setting("QtEnter.dll", QSettings::IniFormat);
    m_setting.beginGroup("EnterIp");
    return m_setting.value("currentIpStu").toString();
}

QString YMLessonManagerAdapter::getBufferEnterRoomPort()
{
    QSettings m_setting("QtEnter.dll", QSettings::IniFormat);
    m_setting.beginGroup("EnterIp");
    return m_setting.value("currentPortStu").toString();
}


void YMLessonManagerAdapter::getDayLessonData(QString dayData)
{
    dayData = dayData.replace("/","-");
    dayData.append(" 00:00:00");
    QString endDay = dayData;
    endDay = endDay.replace(" 00:00:00"," 23:59:59");
    qDebug()<<"YMLessonManagerAdapter::getDayLessonData"<<dayData;
    //2019/12/02
    getMiniClassTimeTable(dayData,endDay,1);

}

void YMLessonManagerAdapter::getMonthLessonData(QString startDay,QString endDay)
{
    startDay = startDay.replace("/","-");
    startDay.append(" 00:00:00");
    endDay = endDay.replace("/","-");
    endDay = endDay.append(" 23:59:59");
    qDebug()<<"YMLessonManagerAdapter::getMonthLessonData"<<startDay<<endDay;
    //2019/12/02
    getMiniClassTimeTable(startDay,endDay,2);
}

void YMLessonManagerAdapter::onGetMonthLessonDataFinish(QNetworkReply *reply)
{
    QByteArray byteArray = reply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();
    QJsonArray lessonArry = {};
    QJsonArray timeArry = {};
    if(dataObject.value("message").toString() == "success")
    {
        lessonArry = dataObject.value("data").toArray();
    }

    for(int a = 0; a < lessonArry.size(); a++)
    {
        QString tempData = lessonArry.at(a).toObject().value("startTime").toString();
        if(tempData.split(" ").size() == 2)
        {
            timeArry.append(tempData.split(" ").at(0));
        }
    }

    qDebug() << "YMLessonManagerAdapter::onGetMonthLessonData" << dataObject<<timeArry;
    sigGetMonthLessonData(timeArry);
    reply->deleteLater();
}

void YMLessonManagerAdapter::onGetDayLessonDataFinish(QNetworkReply *reply)
{
    QByteArray byteArray = reply->readAll();
    if( reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 401 )
    {
        sigInvalidToken();
    }
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();
    QJsonArray lessonArry = {};
    //{"code":2000,"data":[],"message":"success"}
    if(dataObject.value("message").toString() == "success")
    {
        lessonArry = dataObject.value("data").toArray();
    }
    qDebug() << "YMLessonManagerAdapter::getDayLessonData" << lessonArry.size()<<lessonArry;
    sigGetDayLessonData(lessonArry);
    reply->deleteLater();
}

void YMLessonManagerAdapter::getMiniClassTimeTable(QString startDay,QString endDay,int opationType)
{
    QString strDomainName = "http://liveroom.yimifudao.com.cn/v1.0.0/openapi/token/app/timetable";
    if( m_httpClint->m_stage != "api")
    {
        strDomainName = strDomainName.replace("liveroom",m_httpClint->m_stage + "-liveroom");
    }
    QString postData = QString("{\"startDate\": \"%1\",\"endDate\": \"%2\"}").arg(startDay).arg(endDay);
    qDebug()<<"YMAccountManager::getMiniClassToken()"<<m_httpClint->m_stage<<strDomainName<<postData;
    //QUrl encodedUrl = QUrl(strDomainName);
    QNetworkAccessManager * netWorkMgr = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    httpRequest.setUrl(strDomainName);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    httpRequest.setRawHeader("yihuiyun-xbk-token", YMUserBaseInformation::miniClassToken.toLatin1());


    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    netWorkMgr->post(httpRequest,postData.toLatin1());
    if(opationType == 1)
    {
        connect(netWorkMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(onGetDayLessonDataFinish(QNetworkReply*)));
    }else if(opationType == 2)
    {
        connect(netWorkMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(onGetMonthLessonDataFinish(QNetworkReply*)));
    }
}


void YMLessonManagerAdapter::runClassRoom(QJsonObject roomData)
{

    QString tempData = "appurl://?appId=%s&appKey=%s&roomId=%s&userId=%s&userRole=%s&nickName=%s&groupId=%s&envType=%s";
    tempData = "appurl://?roomId=";
    tempData.append(roomData.value("roomId").toString().toStdString().c_str());
    tempData.append("&userId=").append(YMUserBaseInformation::id.toStdString().c_str());
    tempData.append("&userRole=").append(roomData.value("userRole").toString().toStdString().c_str());
    tempData.append("&nickName=").append(roomData.value("nickName").toString().toUtf8().toPercentEncoding());
    tempData.append("&envType=").append(roomData.value("envType").toString().toStdString().c_str());
    tempData.append("&appId=").append(roomData.value("appId").toString().toStdString().c_str());
    tempData.append("&appKey=").append(roomData.value("appKey").toString().toStdString().c_str());
    tempData.append("&token=").append(YMUserBaseInformation::miniClassToken.toUtf8().toPercentEncoding());
    tempData.append("&appVersion=").append(YMUserBaseInformation::appVersion.toStdString().c_str());

    //点击进入教室埋点
    QMap<QString,QString> extrainfos;
    if(roomData.contains("roomId"))
        extrainfos.insert("lessonId",roomData.value("roomId").toString());
    yimipingback::PingbackManager::gestance()->SendEvent("clickEnterRoom",YimiLogType::CLICK,extrainfos);
    QString runPath = QCoreApplication::applicationDirPath();
    QStringList courseData;
    courseData.append(tempData.toUtf8());
    QProcess *enterRoomprocess = new QProcess(this);
    enterRoomprocess->start(runPath + "/cloudclassroom.exe", courseData);
    qDebug()<<"YMLessonManagerAdapter::runClassRoom"<<roomData<<courseData<<YMUserBaseInformation::miniClassToken;
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
}
//查看新录播
void YMLessonManagerAdapter::runPlayer(QJsonObject roomData)
{
    QString tempData = "appurl://?appId=%s&appKey=%s&roomId=%s&userId=%s&userRole=%s&nickName=%s&groupId=%s&envType=%s";
    tempData = "appurl://?roomId=";
    tempData.append(roomData.value("roomId").toString().toStdString().c_str());
    tempData.append("&userId=").append(YMUserBaseInformation::id.toStdString().c_str());
    tempData.append("&userRole=").append(roomData.value("userRole").toString().toStdString().c_str());
    tempData.append("&nickName=").append(roomData.value("nickName").toString().toStdString().c_str());
    tempData.append("&envType=").append(roomData.value("envType").toString().toStdString().c_str());
    tempData.append("&appId=").append(roomData.value("appId").toString().toStdString().c_str());
    tempData.append("&appKey=").append(roomData.value("appKey").toString().toStdString().c_str());
    tempData.append("&token=").append(YMUserBaseInformation::miniClassToken.toUtf8().toPercentEncoding());
    tempData.append("&appVersion=").append(YMUserBaseInformation::appVersion.toStdString().c_str());

    QString runPath = QCoreApplication::applicationDirPath();
    QStringList courseData;
    courseData.append(tempData.toUtf8());
    QProcess *playerprocess = new QProcess(this);
    playerprocess->start(runPath + "/player.exe", courseData);
}
//查看新课件
void YMLessonManagerAdapter::runCourse(QJsonObject roomData)
{
    QString tempData = "appurl://?appId=%s&appKey=%s&roomId=%s&userId=%s&userRole=%s&nickName=%s&groupId=%s&envType=%s";
    tempData = "appurl://?roomId=";
    tempData.append(roomData.value("roomId").toString().toStdString().c_str());
    tempData.append("&envType=").append(roomData.value("envType").toString().toStdString().c_str());
    tempData.append("&appId=").append(roomData.value("appId").toString().toStdString().c_str());
    tempData.append("&appKey=").append(roomData.value("appKey").toString().toStdString().c_str());
    tempData.append("&token=").append(YMUserBaseInformation::miniClassToken.toUtf8().toPercentEncoding());
    QString runPath = QCoreApplication::applicationDirPath();
    QStringList courseData;
    courseData.append(tempData.toUtf8());
    qDebug()<<"YMLessonManagerAdapter::runCourse"<<courseData;
    QProcess *courseProcess = new QProcess(this);
    courseProcess->start(runPath + "/CoursewarePreview.exe", courseData);
}

//opationType 1未结束 2已结束
void YMLessonManagerAdapter::getMiniClassLessonList(QString startDay,QString endDay,int opationType,int pageNum ,int pageSize ,QString roomId )
{
    QString strDomainName = "http://liveroom.yimifudao.com.cn/v1.0.0/openapi/token/app/courseList";
    if( m_httpClint->m_stage != "api")
    {
        strDomainName = strDomainName.replace("liveroom",m_httpClint->m_stage + "-liveroom");
    }
    // QString postData = QString("{\"startDate\": \"%1\",\"endDate\": \"%2\"},\"pageNum\": %3},\"pageSize\": %4},\"roomId\": %5},\"status\": %6}").arg(startDay).arg(endDay).arg(pageNum).arg(pageSize).arg(roomId).arg(opationType);
    QString postData = "{";
    if(startDay != "")
    {
        postData.append("\"startDate\":\"").append(startDay).append("\",");
    }

    if(endDay != "")
    {
        postData.append("\"endDate\":\"").append(endDay).append("\",");
    }

    if(roomId != "-1")
    {
        postData.append("\"roomId\":\"").append(roomId).append("\",");
    }
    if(opationType != -1)
    {
        postData.append("\"status\":\"").append(QString::number(opationType)).append("\",");
    }
    postData.append("\"pageNum\":").append(QString::number(pageNum)).append(",");
    postData.append("\"pageSize\":").append(QString::number(pageSize)).append("}");
    qDebug()<<"YMAccountManager::getMiniClassLessonList()"<<pageNum<<pageSize<<opationType<<m_httpClint->m_stage<<strDomainName<<postData;
    //QUrl encodedUrl = QUrl(strDomainName);
    QNetworkAccessManager * netWorkMgr = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    httpRequest.setUrl(strDomainName);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    httpRequest.setRawHeader("yihuiyun-xbk-token", YMUserBaseInformation::miniClassToken.toLatin1());


    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    netWorkMgr->post(httpRequest,postData.toLatin1());

    connect(netWorkMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(onGetMiniClassLessonList(QNetworkReply*)));

}

void YMLessonManagerAdapter::onGetMiniClassLessonList(QNetworkReply *reply)
{
    QByteArray byteArray = reply->readAll();
    if( reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 401 )
    {
        sigInvalidToken();
    }
    QJsonObject dataObject = QJsonDocument::fromJson(byteArray).object();
    qDebug()<<"onGetMiniClassLessonList"<<dataObject;
    if(dataObject.value("message").toString() == "success")
    {
        sigGetLessonListDate(dataObject.value("data").toObject());
    }
    reply->deleteLater();
}


void YMLessonManagerAdapter::getCurrentMonthLessonData(QString currentMonth)
{
    QDateTime timess = QDateTime::currentDateTime();

    QVariantMap dataMap;
    //dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", "5.0");
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    dataMap.insert("queryMonth", currentMonth);

    //dataMap.insert("type", YMUserBaseInformation::type);

    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);

    QString url = m_httpClint->httpUrl + "/oneToMore/lesson/studentLessonSchedule";
    QNetworkAccessManager *networkMgr = new QNetworkAccessManager(this);
    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QVariantMap::const_iterator it = dataMap.begin(); it != dataMap.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toByteArray());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    networkMgr->post(request, multiPart);
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), this,SLOT(onGetCurrentMonthLessonDataFinish(QNetworkReply*)));

}

void YMLessonManagerAdapter::getCurrentDayLessonData(QString currentDay)
{
    currentDay.replace("/","-");
    currentDayBuffer = currentDay;
    QDateTime timess = QDateTime::currentDateTime();

    QVariantMap dataMap;
    //dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", "5.0");
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    dataMap.insert("queryStartDate", currentDay);
    dataMap.insert("queryEndDate", currentDay);

    dataMap.insert("pageIndex", 1);
    dataMap.insert("pageSize", 100);
    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);

    QString url = m_httpClint->httpUrl + "/oneToMore/lesson/v2/studentLessonList";

    QNetworkAccessManager *networkMgr = new QNetworkAccessManager(this);
    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QVariantMap::const_iterator it = dataMap.begin(); it != dataMap.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toByteArray());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    networkMgr->post(request, multiPart);
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), this,SLOT(onGetCurrentDayLessonDataFinish(QNetworkReply*)));
}

void YMLessonManagerAdapter::onGetCurrentMonthLessonDataFinish(QNetworkReply *reply)
{
    QByteArray dataByte = reply->readAll();
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    QJsonObject lessonData = objectData.value("data").toObject();
    qDebug()<<"getCurrentMonthLessonData"<<lessonData;
    sigGetMonthLessonData(objectData.value("data").toArray());
}

void YMLessonManagerAdapter::onGetCurrentDayLessonDataFinish(QNetworkReply *reply)
{
    QByteArray dataByte = reply->readAll();
    QJsonArray arrayData = QJsonDocument::fromJson(dataByte).object().value("data").toObject().value("items").toArray();

    for(int a = 0; a < arrayData.size(); a++)
    {
        QString lessonTime = arrayData[a].toObject().value("lessonTime").toString();
        if(lessonTime.split("-").size() == 2)
        {
            QJsonObject tObj = arrayData[a].toObject();
            tObj.insert("startTime",currentDayBuffer + " " + lessonTime.split("-").at(0));
            tObj.insert("endTime",currentDayBuffer + " " + lessonTime.split("-").at(1));
            tObj.insert("lessonDateShowText",currentDayBuffer + " " + lessonTime.replace("-","~"));
            arrayData[a] = tObj;
        }
    }
    qDebug()<<"getCurrentDayLessonData"<<currentDayBuffer<<dataByte<<arrayData;
    sigGetDayLessonData(arrayData);
}

