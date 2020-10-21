#include "YMLessonManagerAdapter.h"
#include "YMUserBaseInformation.h"
#include "YMEncryption.h"
#include <QJsonDocument>
#include "QProcess"
#include "QFile"
#include "QDir"
#include <QStandardPaths>
#include <QCoreApplication>

std::string key = "Q-RRt2H2";

YMLessonManagerAdapter::YMLessonManagerAdapter(QObject * parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onRequstTimerOut()), this, SIGNAL(requstTimeOuted()));
    m_timer = new QTimer();
    m_timer->setInterval(15000);
}

void YMLessonManagerAdapter::errorLog(QString message)
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString filePath = docPath + "/YiMi/";
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
    QString url = m_httpClient->httpUrl + "/lesson/getTeacherLessonSchedule";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
    teachLessonInfoChanged(objectData);
    QString datas;
    emit loadingFinished();
}

//获取: 课程列表
void YMLessonManagerAdapter::getTeachLessonListInfo(QJsonObject data)
{
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
    QString url = m_httpClient->httpUrl + "/lesson/getTeacherLesson";

    QByteArray dataArray = m_httpClient->httpPostForm(url, dataMap);
    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
	
    QJsonObject lessonData = objectData.value("data").toObject();
    teacherLesonListInfoChanged(lessonData);
    this->errorLog("YMLessonManagerAdapter::getTeachLessonListInfo");
    emit loadingFinished();
}

//查看课件
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
                               "\"tcpPort\": \"5120\","
                               "\"userName\": \"hzhtr\"}").arg(YMUserBaseInformation::passWord).arg(YMUserBaseInformation::apiVersion).arg(YMUserBaseInformation::appVersion).arg(YMUserBaseInformation::deviceInfo).arg(YMUserBaseInformation::id).arg(YMUserBaseInformation::token).arg(QString::number(lessonInfo.value("lessonId").toInt())).arg(QString::number(lessonInfo.value("lessonStatus").toInt()));

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
void YMLessonManagerAdapter::getEnterClass(QString lessonId)
{
    //进入教室埋点
    QJsonObject msgData;
    msgData.insert("lessonId",lessonId);
    msgData.insert("lessonType","ORDER");
    msgData.insert("lessonPlanStartTime",m_startTime);
    msgData.insert("lessonPlanEndTime",m_endTime);
    m_listenOrClass = true;
    m_lessonId = lessonId;
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

    QString url = m_httpClient->httpUrl + "/lesson/enterClass?";

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
    m_timer->start();
    connect(m_timer, SIGNAL(timeout()), this, SLOT(enterClassTimerOut()));
}

void YMLessonManagerAdapter::enterClassTimerOut()
{
    emit requstTimeOuted();

    qDebug() << "YMLessonManagerAdapter::enterClassTimerOut";
}

void YMLessonManagerAdapter::getEnterClassresult(QNetworkReply *reply)
{
    QByteArray dataArray = reply->readAll();

    if(dataArray.length() == 0)
    {
        lessonlistRenewSignal();
        return;
    }
    if(m_timer->isActive())
    {
        m_timer->stop();
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    
    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString().toLower() == "success"
            && dataObject.value("message").toString().toUpper() == "SUCCESS")
    {
        m_classData = dataObject;
        
        getCloudServer();
    }
    else
    {
        qosV2Mannage();
        qDebug() << "YMLessonManagerAdapter::getEnterClassresult" << dataObject;
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
    QString url = m_httpClient->httpUrl + "/lesson/getStuTrailVideoList";
    int reqCode = m_httpClient->httpPostVariant(url, dataMap, this);
    m_respHandlers.insert(reqCode, &YMLessonManagerAdapter::onRespGetRepeatPlayer);
}

void YMLessonManagerAdapter::getCloudServer()
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString md5sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5sign).toUpper();
    dataMap.insert("sign", sign);
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/agora/domain");
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);

    if(dataArray.length() <= 0)
    {
        lessonlistRenewSignal();
        return;
    }

    qDebug()<<"getCloudServer data "<< QString::fromUtf8(dataArray);
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("data"))
    {
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_ipAddress = dataObj.value("domain").toString();
        m_tcpPort = QString::number(dataObj.value("tcpPort").toInt());
        m_httpPort =  QString::number(dataObj.value("httpPort").toInt());
        
        int type = dataObj.value("domainType").toInt();
        if(type == 0)
        {
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
        else if(type == 1)
        {
            QString url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
            QByteArray data = m_httpClient->httpGetIp(url.arg(des_encrypt(m_ipAddress)));
            QString IpAddress = des_decrypt(QByteArray::fromHex(data).toStdString());
            qDebug() << "====IpAddress===" << IpAddress;
            IpAddress = IpAddress.split(",").at(0);
            IpAddress = IpAddress.split(";").at(0);
            m_ipAddress = IpAddress;
            
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
            m_ipAddress = "120.132.3.5";
            m_port = 5122;
            m_tcpPort = 5120;
            if(m_listenOrClass)
            {
                
                enterClass();
            }
            else
            {
                enterListen();
            }
        }
    }
    else{
        qosV2Mannage();
    }
}

YMLessonManagerAdapter::~YMLessonManagerAdapter()
{
    this->disconnect(m_httpClient, 0, 0, 0);
}

void YMLessonManagerAdapter::onRespGetRepeatPlayer(const QString &data)
{
    QJsonObject dataObject = QJsonDocument::fromJson(data.toUtf8()).object();

    QString lessonId = QString::number(m_repeatData.value("lessonId").toInt());
    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    QString path = year.mid(0, 6).append("/").append(lessonId);
    
    downLoadFile(dataObject, path);
}

void YMLessonManagerAdapter::downLoadFile(QJsonObject dataObject, QString fileDir)
{
    qDebug() << "YMLessonManagerAdapter::downLoadFile dataObject " << dataObject;
    QVariantMap result = dataObject.toVariantMap();
    QVariantList datalist = result["data"].toList();
    QVariantList filedata;
    
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
    if(file.size() == 0)
    {
        QDir dir(filedata.at(0).toString());
        dir.setFilter(QDir::Files);
        for(int z = 0; z < dir.count(); z ++)
        {
            dir.remove(dir[z]);
        }
        emit sigRepeatPlayer();
        qDebug() << "YMLessonManagerAdapter::downLoadFile::data" << datalist;
        return;
    }

    setDownValue(0, datalist.size());
    for(int a = 0; a < datalist.size(); a++)
    {
        QVariantMap data = datalist.at(a).toMap();
        if(data["hasVoice"].toInt() == 1)
        {
            getStuVideo(data["id"].toString(), data["number"].toString(), fileDir);
            downloadChanged(a);
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
#ifdef USE_OSS_UPLOAD_LOG
    courseData << YMUserBaseInformation::id;
#endif
    QString runPath = QCoreApplication::applicationDirPath();
    qDebug() << "RunPath:" << filedata;
    QProcess::startDetached(runPath + "/player.exe", courseData);
}

void YMLessonManagerAdapter::getStuVideo(QString videoId, QString fileName, QString fileDir)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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

        QString url = m_httpClient->httpUrl + "/lesson/getStuVideo?" + md5Sign + "&sign=" + sign;

        QByteArray readData = m_httpClient->httpDownloadFile(url);

        QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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
    QString url = m_httpClient->httpUrl + "/lesson/getStuTrail?" + signMd5 + "&sign=" + sign;
    QByteArray data = m_httpClient->httpGetVariant(url, this);
    //qDebug() << "data::" << data.length();
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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
    allresultlist << QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation).append("/YiMi/").append(fileDir);
    allresultlist << fileName.append(".encrypt");
    return allresultlist;
}

//进入旁听
void YMLessonManagerAdapter::getListen(QString userId)
{
    //qDebug() << "YMLessonManagerAdapter::getListen::" << userId;
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


    QByteArray dataArray = m_httpClient->httpPostForm(m_httpClient->httpUrl + "/lesson/enterClass", dataMap);
    if(dataArray.length() <= 0)
    {
        lessonlistRenewSignal();
        return;
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "enterClass::data:" << dataObject;
    if(dataObject.contains("result") && dataObject.contains("message")
            && dataObject.value("result").toString().toLower() == "success"
            && dataObject.value("message").toString().toUpper() == "SUCCESS")
    {
        m_classData = dataObject;
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_listen = dataObj.value("startFlag").toInt();
        getCloudServer();
    }
    else
    {
        qDebug() << "YMLessonManagerAdapter::getListen" << dataObject;
    }
}

void YMLessonManagerAdapter::enterListen()
{
    //qDebug() << "YMLessonManagerAdapter::enterListen" << m_listen;
    if(m_listen == 0)
    {
        listenChange(m_listen);
        return;
    }
    QString ipPort = m_port;
    QString address = m_ipAddress;
    QString tcpPort = m_tcpPort;

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
    dataOthermap.insert("tcpPort", tcpPort);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);
    dataOthermap.insert("plat", "T");
    if(YMUserBaseInformation::latitude != "" && YMUserBaseInformation::longitude != "")
    {
        dataOthermap.insert("lng", YMUserBaseInformation::longitude);
        dataOthermap.insert("lat", YMUserBaseInformation::latitude);
    }

    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QFile file(m_systemPublicFilePath + "stutempattend.ini");
    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();
    //qDebug() << "filePath:" << m_systemPublicFilePath + "stutempattend.ini";

    QString runPath = QCoreApplication::applicationDirPath();
    runPath += "/attendclassroom.exe";

    QProcess *enterRoomprocess = new QProcess(this);
    enterRoomprocess->start(runPath, QStringList());
    programRuned();
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
}

void YMLessonManagerAdapter::enterClass()
{
    //    //调试暂用 服务器IP：118.25.48.118  tcp端口：5250，HTTP端口：5251
    //    tcpPort = "5250";
    //    ipPort = "118.25.48.118";
    QVariantMap dataOthermap;
    dataOthermap.insert("address", m_ipAddress);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("MD5Pwd", YMUserBaseInformation::MD5Pwd);
    dataOthermap.insert("mobileNo", YMUserBaseInformation::mobileNo);
    dataOthermap.insert("id", YMUserBaseInformation::id);
    dataOthermap.insert("lessonType", lessonType);
    dataOthermap.insert("tcpPort", m_tcpPort);
    dataOthermap.insert("httpPort", m_httpPort);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);

    if(YMUserBaseInformation::latitude != "" && YMUserBaseInformation::longitude != "")
    {
        dataOthermap.insert("lat", YMUserBaseInformation::latitude);
        dataOthermap.insert("lng", YMUserBaseInformation::longitude);
    }
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QFile file(m_systemPublicFilePath + "miniTemp.ini");
    //qDebug() << "m_systemPublicFilePath" << m_systemPublicFilePath;
    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();

    QString runPath = QCoreApplication::applicationDirPath();
    runPath += "/classroomdemo.exe";
    qDebug() << "onRespCloudServer::runPath:" << runPath;
    QProcess *enterRoomprocess = new QProcess(this);
    enterRoomprocess->start(runPath, QStringList());
    programRuned();
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
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

    QByteArray dataArray = m_httpClient->httpPostForm(m_httpClient->httpUrl + "/lesson/getLvbLessonInfo", dataMap);
    //qDebug()<< QString::fromUtf8( dataArray)<<"231131231321321";
    QJsonObject obj = QJsonDocument::fromJson(dataArray).object();
    return obj;//QVariant( dataArray).toJsonObject();
}

void YMLessonManagerAdapter::resetSelectIp(int type, QString ip)
{
    this->errorLog("YMLessonManagerAdapter::resetSelectIp");
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
    QString url = m_httpClient->httpUrl + "/lesson/getEmLessons";
    QByteArray dataArray = m_httpClient->httpPostForm(url, dataMap);
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
    QString url = m_httpClient->httpUrl + "/lesson/getUserSubjectInfo";
    QByteArray dataArray = m_httpClient->httpPostForm(url, dataMap);
    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject objData = QJsonDocument::fromJson(dataArray).object();
    QJsonObject dataObj = objData.value("data").toObject();
    this->errorLog("YMLessonManagerAdapter::getEmLessons::" + dataObj.size());
    //qDebug() << "YMLessonManagerAdapter::getUserSubjectInfo" << dataObj;
    emit sigUserSubjectInfo(dataObj);
}

//我的课表
void YMLessonManagerAdapter::getCurrentLessonTable(QString dateTime)
{
    qDebug() << "==YMLessonManagerAdapter::getCurrentLessonTable::pram==" << dateTime;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);

    QString url = QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/currtable?currDate=%1").arg(dateTime);
    //    QString url = QString("http://dev-platform.yimifudao.com/v1.0.0/marketing/app/api/t/currtable?currDate=%1").arg(dateTime);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);//this); //

    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "==YMLessonManagerAdapter::getCurrentLessonTable::dataObj==" << url << dataMap<< YMUserBaseInformation::token << dataObj;
    emit sigCurrentLessonInfo(dataObj);
}

//我的课程
void YMLessonManagerAdapter::getMyLessonInfo(int page, int pageSize)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/myclass?page=%1&pageSize=%2").arg(page).arg(pageSize);
    //QString url = QString("http://dev-platform.yimifudao.com/v1.0.0/marketing/app/api/t/myclass?page=%1&pageSize=%2").arg(page).arg(pageSize);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);
    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "==YMLessonManagerAdapter::getMyLessonInfo::dataObj==" << url << dataObj;
    emit sigMyLessonInfo(dataObj);
}

void YMLessonManagerAdapter::getCatalogs(QString classId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);

    QString url = QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/catalogs?classId=%1").arg(classId);
    //QString url = QString("http://dev-platform.yimifudao.com/v1.0.0/marketing/app/api/t/catalogs?classId=%1").arg(classId);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);
    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "==YMLessonManagerAdapter::getCatalogs::dataObj==" << url << dataObj;
    emit sigCatalogsInfo(dataObj);
}

void YMLessonManagerAdapter::getJoinTalkClassRoomInfo(QString executionPlanId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);

    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/catalog/go/room?executionPlanId=%1").arg(executionPlanId);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);
    qDebug() << "==getJoinTalkClassRoomInfo==" << dataArray.length() << url;
    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "==getJoinTalkClassRoomInfo::data==" << dataObj;
    emit sigJoinClassroom(dataObj);
}

void YMLessonManagerAdapter::getJoinClassRoomInfo(QString executionPlanId)
{
    emit sigJoinClassroomStaus();
    m_listenOrClass = true;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);

    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/enter/room?executionPlanId=%1").arg(executionPlanId);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);

    if(dataArray.length() == 0)
    {
        emit sigJoinClassroomFail();
        return;
    }

    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    qDebug()<<"YMLessonManagerAdapter::getJoinClassRoomInfo("<< dataObj << url << YMUserBaseInformation::token;
    if(dataObj.value("result").toString() == "success")
    {
        QJsonObject childObj = dataObj.value("data").toObject();
        QJsonObject liveRoomObj = childObj.value("liveRoomDto").toObject();
        int platform = childObj.value("platform").toInt();
        if(platform == 2)//云教室
        {
            QJsonObject cloudObj;
            cloudObj.insert("code",dataObj.value("code").toInt());
            cloudObj.insert("message",dataObj.value("message").toString());
            cloudObj.insert("result",dataObj.value("result").toString());
            cloudObj.insert("success",dataObj.value("success").toString());
            cloudObj.insert("data",liveRoomObj);
            m_classData = cloudObj;
            //获取服务器Ip
            getCloudServer();
        }
        else
        {
            emit sigJoinClassroomFail();
        }
    }
    else
    {
        emit sigJoinClassroomFail();
    }
}

void YMLessonManagerAdapter::browseCourseware(QString executionPlanId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);
    QString url = QString(YMUserBaseInformation::m_minClassUrl +"/marketing/app/api/t/catalog/preview/courseware?executionPlanId=%1").arg(executionPlanId);
    //QString url = QString("http://dev-platform.yimifudao.com/v1.0.0/marketing/app/api/t/catalog/preview/courseware?executionPlanId=%1").arg(executionPlanId);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);

    if(dataArray.length() == 0)
    {
        sigBrowseCoursewareFail();
        return;
    }

    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
    if(objectData.value("success").toBool() == false)
    {
        sigBrowseCoursewareFail();
        return;
    }
    if(objectData.value("data").toArray().size() == 0)
    {
        sigBrowseCoursewareFail();
        return;
    }

    qDebug() << "==YMLessonManagerAdapter::browseCourseware==" << objectData ;
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";
    QDir isDir;
    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        isDir.mkpath(m_systemPublicFilePath);
    }

    QString filenames("miniCourware.ini");
    QFile files(m_systemPublicFilePath + filenames);
    files.open(QIODevice::WriteOnly);
    files.write(dataArray);
    files.flush();
    files.close();

    QString tempdata = QString("{\"code\": -1,\"data\": {\"endTime\": \"2018-03-29 22:38:00\", \"lessonId\": %7,\"lessonSecondCount\": 79920,"
                               " \"qqSign\": \"eJxlj11\","
                               "  \"socketFlag\": 1,"
                               "  \"isMiniClass\": 2,"
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
                               "\"tcpPort\": \"5120\","
                               "\"userName\": \"hzhtr\"}").arg(YMUserBaseInformation::passWord).arg(YMUserBaseInformation::apiVersion).arg(YMUserBaseInformation::appVersion).arg(YMUserBaseInformation::deviceInfo).arg(YMUserBaseInformation::id).arg(YMUserBaseInformation::token).arg(executionPlanId).arg("");
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

// 获取旁听课程信息（小班课）
void YMLessonManagerAdapter::getAttendLessonListInfo(QJsonObject data)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    QString page = data.value("page").toString();//QString::number(data.value("page").toInt());//data.value("page").toString();
    QString pageSize = QString::number(data.value("pageSize").toInt());
    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();
    QString teacherIds = data.value("teacherIds").toString();
    QString gradeIds = data.value("gradeIds").toString();
    QString subjectIds = data.value("subjectIds").toString();
    QString status = data.value("status").toString();
    QString roomId = data.value("roomId").toString();
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("sign", sign);
    dataMap.insert("teacherIds", teacherIds);
    dataMap.insert("gradeIds", gradeIds);
    dataMap.insert("subjectIds", subjectIds);
    dataMap.insert("status", status);
    qDebug() << "%%%%%%%%%% teacherIds = "<<teacherIds<<"; gradeIds = "<<gradeIds<<", subjectIds"<<subjectIds<<", status"<<status;
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/listen/list?page=%1&pageSize=%2&teacherIds=%3&gradeIds=%4&subjectIds=%5&status=%6&roomId=%7")
            .arg(page).arg(pageSize).arg(teacherIds).arg(gradeIds).arg(subjectIds).arg(status).arg(roomId);
    qDebug()<<"##### url ="<<url;
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token, dataMap);
    if(dataArray.length() == 0){
        qDebug() << "########### dataArray.length() = "<< dataArray.length();
        return;
    }
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    emit attendLessonListInfoChanged(dataObj);
    emit loadingAttendLessonListInfoFinished();
}

// 得到教师列表(小班课)
void YMLessonManagerAdapter::getListenTeachers()
{
    QVariantMap dataMap;
    QDateTime currentTime = QDateTime::currentDateTime();
    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("sign", sign);
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/listen/getListenTeachers");
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token, dataMap);
    if(dataArray.length() == 0) return;
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    emit listenTeachersListInfoChanged(dataObj);
}

// 得到当前老师学科和年级(小班课)
void YMLessonManagerAdapter::findGradeAndSubject()
{
    QVariantMap dataMap;
    QDateTime currentTime = QDateTime::currentDateTime();
    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("sign", sign);
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/listen/findGradeAndSubject");
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token, dataMap);
    if(dataArray.length() == 0) return;
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    qDebug()<<"########## GradeAndSubject = "<<dataObj;
    emit gradeAndSubjectInfoChanged(dataObj);
}

// 小班课二期旁听-进入旁听
void YMLessonManagerAdapter::getListenClassroom(QString executionPlanId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("sign", sign);
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/enter/room?executionPlanId=%1").arg(executionPlanId);
    qDebug()<<"@@@@@@ url = "<< url <<__LINE__;
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token, dataMap);
    if(dataArray.length() <= 0)
    {
        lessonlistRenewSignal();
        return;
    }
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    qDebug() <<"##########"<< dataObject.value("result").toString() <<"##########"<< dataObject.value("message").toString() <<"##########"<<QString::number(dataObject.value("success").toBool());
    if(dataObject.contains("result") && dataObject.contains("message") && dataObject.contains("success")
            && dataObject.value("result").toString() == QString::fromLocal8Bit("success")
            && dataObject.value("message").toString() == QString::fromLocal8Bit("成功")
            && QString::number(dataObject.value("success").toBool()) == "1")
    {
        m_classData = dataObject;
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_listen = dataObj.value("startFlag").toInt();
        qDebug()<<"###### m_listen ="<<m_listen;
        getListenCloudServerIp();
    }
    else
    {
        qDebug() << "####### YMLessonManagerAdapter::getListenClassroom ##########";
    }
}
void YMLessonManagerAdapter::getListenCloudServerIp()
{
    QDateTime timess = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));
    QString md5sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5sign).toUpper();
    dataMap.insert("sign", sign);
    QString url =  QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/agora/domain");
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);
    if(dataArray.length() <= 0)
    {
        lessonlistRenewSignal();
        return;
    }
    qDebug()<<"getCloudServer data "<< QString::fromUtf8(dataArray);
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("data"))
    {
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_ipAddress = dataObj.value("domain").toString();
        m_tcpPort = QString::number(dataObj.value("tcpPort").toInt());
        m_httpPort =  QString::number(dataObj.value("httpPort").toInt());
        int type = dataObj.value("domainType").toInt();
        if(type == 0)
        {
            resetSelectIp(1, m_ipAddress);
            enterListenClass();
            return;
        }
        else if(type == 1)
        {
            QString url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
            QByteArray data = m_httpClient->httpGetIp(url.arg(des_encrypt(m_ipAddress)));
            QString IpAddress = des_decrypt(QByteArray::fromHex(data).toStdString());
            IpAddress = IpAddress.split(",").at(0);
            IpAddress = IpAddress.split(";").at(0);
            m_ipAddress = IpAddress;
            enterListenClass();
            return;
        }
        else
        {
            m_ipAddress = "120.132.3.5";
            m_port = 5122;
            m_tcpPort = 5120;
            enterListenClass();
        }
    }
}
// 进入旁听教室
void YMLessonManagerAdapter::enterListenClass()
{
    QString address = m_ipAddress;
    QString tcpPort = m_tcpPort;
    QString httpPort = m_httpPort;
    QVariantMap dataOthermap;
    dataOthermap.insert("address", address);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("MD5Pwd", YMUserBaseInformation::MD5Pwd);
    dataOthermap.insert("mobileNo", YMUserBaseInformation::mobileNo);
    dataOthermap.insert("id", YMUserBaseInformation::id);
    dataOthermap.insert("lessonType", lessonType);
    dataOthermap.insert("tcpPort", tcpPort);
    dataOthermap.insert("httpPort", httpPort);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);
    if(YMUserBaseInformation::latitude != "" && YMUserBaseInformation::longitude != "")
    {
        dataOthermap.insert("lat", YMUserBaseInformation::latitude);
        dataOthermap.insert("lng", YMUserBaseInformation::longitude);
    }
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";
    //设置顶端配置路径
    QDir wdir(m_systemPublicFilePath);
    if (!wdir.exists())
        wdir.mkpath(m_systemPublicFilePath);
    QFile file(m_systemPublicFilePath + "miniAttendTemp.ini");
    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();
    QString runPath = QCoreApplication::applicationDirPath();
    runPath += "/attendclassroommini2nd.exe";
    QFile runfile(runPath);
    if(!runfile.exists())
    {
        qDebug() << runPath << " does not exist !" ;
        return;
    }
    QProcess *enterRoomprocess = new QProcess(this);
    enterRoomprocess->start(runPath, QStringList());
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
    emit programRuned();
}

// 查看回放
void YMLessonManagerAdapter::getPlayback(QString executionPlanId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);

    QString url = QString(YMUserBaseInformation::m_minClassUrl + "/marketing/app/api/t/playback?executionPlanId=%1").arg(executionPlanId);
    QByteArray dataArray = m_httpClient->httpGetVariant(url, YMUserBaseInformation::token,dataMap);

    if(dataArray.length() == 0)
    {
        return;
    }

    QJsonObject jsonDataObj = QJsonDocument::fromJson(dataArray).object();
    QJsonObject dataObj = jsonDataObj.value("data").toObject();

    int platform = dataObj.value("platform").toInt();
    if(platform == 2)
    {
        QJsonArray dataArray = dataObj.value("list").toArray();
        this->downloadMiniPlayFile(dataArray);
        return;
    }
    emit sigPlaybackInfo(dataObj);
}

void YMLessonManagerAdapter::downloadMiniPlayFile(QJsonArray dataArray)
{
    QString trailFile;
    int trailNumber;
    QString liveroomId;
    setDownValue(0, dataArray.size());
    for(int i = 0; i < dataArray.size(); i++)
    {
       QJsonObject arrayData  = dataArray.at(i).toObject();
       QString id = arrayData.value("id").toString();
       liveroomId = arrayData.value("liveroomId").toString();
       int number = arrayData.value("number").toInt();
       QString trailUrl = arrayData.value("trailUrl").toString();
       QString voiceUrl = arrayData.value("voiceUrl").toString();
       trailFile = trailUrl;
       trailNumber = number;
       downloadChanged(number);
       this->writeFile(liveroomId,voiceUrl,number,".mp3");
    }

    this->writeFile(liveroomId,trailFile,trailNumber,".txt");
    downloadFinished();

    QString lessonId = liveroomId;
    QStringList courseData;
    courseData << lessonId;

    QByteArray arrydata;
    arrydata.append(QStringLiteral("【"));
    arrydata.append(QStringLiteral("编号")).append(lessonId.toUtf8()).append(QStringLiteral("】"));
    courseData << arrydata.toHex();
    QString trailFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +  "/YiMi/" + liveroomId;
    courseData << trailFilePath.toUtf8().toHex(); //文件路径进行加密
    courseData << QString::number(trailNumber) +".txt";

    courseData << YMUserBaseInformation::type;
    courseData << YMUserBaseInformation::token;
    courseData << YMUserBaseInformation::apiVersion;
    courseData << YMUserBaseInformation::appVersion;
    courseData << YMUserBaseInformation::id;

    QString runPath = QCoreApplication::applicationDirPath();
    QProcess::startDetached(runPath + "/miniclass_player.exe", courseData);
    emit programRuned();
}

void YMLessonManagerAdapter::writeFile(QString liveroomId,QString path,int fileNumber,QString suffix)
{
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(path));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader,"application/x-www-form-urlencoded");
    QEventLoop httploop;
    QNetworkAccessManager *m_networkMgr = new QNetworkAccessManager(this);
    connect(m_networkMgr,SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    QNetworkReply *httpReply;
    httpReply = m_networkMgr->get(httpRequest);
    httploop.exec();

    QByteArray readData = httpReply->readAll();
    //qDebug() << "====readData::MP3====" << readData.length() << path;

    QString filename(QString::number(fileNumber) + suffix);
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +  "/YiMi/" + liveroomId + "/";
    QDir dir;
    if(!dir.exists(m_systemPublicFilePath))
    {
        dir.mkdir(m_systemPublicFilePath);
    }
    QFile file(m_systemPublicFilePath + filename);
    file.open(QIODevice::WriteOnly);
    file.write(readData);
    file.flush();
    file.close();
}

void YMLessonManagerAdapter::setQosStartTime(qlonglong startTime, qlonglong endTime)
{
    m_startTime = QString::number(startTime);
    m_endTime = QString::number(endTime);
    qDebug() << "===setQosStartTime===" << startTime << endTime;
}

void YMLessonManagerAdapter::qosV2Mannage()
{
    QJsonObject jsonObj;
    QJsonObject dataObj;
    dataObj.insert("lessonId",m_lessonId);
    dataObj.insert("appVersion",YMUserBaseInformation::appVersion);
    jsonObj.insert("data",dataObj);

    QJsonObject userObj;
    userObj.insert("id",YMUserBaseInformation::id);
    userObj.insert("apiVersion",YMUserBaseInformation::apiVersion);
    userObj.insert("appVersion",YMUserBaseInformation::appVersion);

    QString userStr = QJsonDocument(userObj).toJson();
    QString initData = QString(QJsonDocument(jsonObj).toJson()).append("###").append(userStr);

    QJsonObject msgData;
    msgData.insert("socketIp","");
    msgData.insert("lessonPlanStartTime",m_startTime);
    msgData.insert("lessonPlanEndTime",m_endTime);
    msgData.insert("result","0");
    msgData.insert("errMsg","进入教室失败!");
}
