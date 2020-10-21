#include "YMLessonManager.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"
#include "QProcess"
#include "QDir"
#include "QFile"
#include <QStandardPaths>
#include <QCoreApplication>

YMLessonManager *YMLessonManager::m_instance = nullptr;
std::string key = "Q-RRt2H2";

YMLessonManager::YMLessonManager(QObject *parent)
    : QObject(parent)
{
    m_httpClint = YMHttpClient::defaultInstance();
}

YMLessonManager *YMLessonManager::getInstance()
{
    if(m_instance == nullptr)
    {
        m_instance = new YMLessonManager();
    }
    return m_instance;
}

//获取学生课程表
void YMLessonManager::getStudentLessonInfo(QString dateTime)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;

    reqParm.insert("queryDate", dateTime);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QByteArray dataArray = m_httpClint->httpPostForm(m_httpClint->httpUrl + "/lesson/getStuLessonSchedule", reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "getStudentLessonInfo" << objectData;
    emit studentLessonInfoChanged(objectData);

    //m_respHandlers.insert(reqCode,&YMLessonManager::onRespLesson);
}

void YMLessonManager::getStudentLessonListInfo(QJsonObject data)
{
    QDateTime timess = QDateTime::currentDateTime();

    QString keywords = data.value("keywords").toString();
    int pageIndex = data.value("pageIndex").toInt();
    int pageSize = data.value("pageSize").toInt();
    QString querySubject = data.value("querySubject").toString();
    QString queryStartDate = data.value("queryStartDate").toString();
    QString queryEndDate = data.value("queryEndDate").toString();
    QString queryStatus = data.value("queryStatus").toString();
    QString queryPeriod = data.value("queryPeriod").toString();

    QVariantMap dataMap;
    dataMap.insert("userId", YMUserBaseInformation::id);
    dataMap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataMap.insert("token", YMUserBaseInformation::token);
    dataMap.insert("timestamp", timess.toString("yyyyMMddhhmmss"));

    dataMap.insert("keywords", keywords);
    dataMap.insert("pageIndex", pageIndex);
    dataMap.insert("pageSize", pageSize);
    dataMap.insert("querySubject", querySubject);
    dataMap.insert("queryStartDate", queryStartDate);
    dataMap.insert("queryEndDate", queryEndDate);
    dataMap.insert("queryStatus", queryStatus);
    dataMap.insert("queryPeriod", queryPeriod);

    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);
    //qDebug() << "lessonList::" << dataMap;
    QByteArray dataArray = m_httpClint->httpPostVariant(m_httpClint->httpUrl + "/lesson/getStuLesson", dataMap);
    QJsonObject objectData = QJsonDocument::fromJson(dataArray).object();
    QJsonObject lessonData = objectData.value("data").toObject();
    qDebug() << "YMLessonManager::onRespLesonList" << lessonData;
    emit studentLesonListInfoChanged(lessonData);
    emit findChanged();
    //m_respHandlers.insert(reqCode,&YMLessonManager::onRespLessonList);
}

void YMLessonManager::getEnterClass(QString lessonId)
{
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
    QString md5Sign = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(md5Sign).toUpper();
    dataMap.insert("sign", sign);
    QString url = m_httpClint->httpUrl + "/lesson/enterClass";
    QByteArray dataArray = m_httpClint->httpPostVariant(url, dataMap);

    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("result") && dataObject.contains("message")
       && dataObject.value("result").toString() == "success"
       && dataObject.value("message").toString() == "SUCCESS")
    {
        m_classData = dataObject;
        getCloudServer();
    }
    //m_respHandlers.insert(reqCode,&YMLessonManager::onRespEnterClass);
}

QVariantList YMLessonManager::getVideoList(QString lessonId)
{
    QVariantList varList;
    return varList;
}

//查看课件
void YMLessonManager::getLookCourse(QJsonObject lessonInfo)
{
    qDebug() << "YMLessonManager::getLookCourse:" << lessonInfo;
    QString startTime = lessonInfo.value("startTime").toString();
    QString lessonId = QString::number(lessonInfo.value("lessonId").toInt());

    QStringList courseData;
    courseData << "STU";
    courseData << YMUserBaseInformation::id;
    courseData << YMUserBaseInformation::token;
    courseData << lessonId;
    QString timeRep = startTime.replace("-", "").replace("-", "");
    QString time = timeRep.mid(0, 6);
    courseData << time;
    courseData << YMUserBaseInformation::appVersion;
    courseData << YMUserBaseInformation::apiVersion;

    QString runPath = QCoreApplication::applicationDirPath();
    QProcess *process = new QProcess(this);

    qDebug() << "YMLessonManager::getLookCourse"
             << courseData << startTime << lessonId
             << time << runPath + "/CourwarePreviewer.exe" ;
    process->start(runPath + "/CourwarePreviewer.exe", courseData);
}

//查看录播
void YMLessonManager::getRepeatPlayer(QJsonObject lessonInfo)
{
    QString startTime = lessonInfo.value("startTime").toString();
    QString lessonId = QString::number(lessonInfo.value("lessonId").toInt());

    qDebug() << "YMLessonManager::getRepeatPlayer"
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
    QString url = m_httpClint->httpUrl + "/lesson/getStuTrailVideoList";
    QByteArray dataArray = m_httpClint->httpPostVariant(url, dataMap);
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();

    //QString lessonId = QString::number(m_repeatData.value("lessonId").toInt());
    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    QString path = year.mid(0, 6).append("/").append(lessonId);

    downLoadFile(dataObject, path);
    //m_respHandlers.insert(reqCode,&YMLessonManager::onRespGetRepeatPlayer);
}

void YMLessonManager::downLoadFile(QJsonObject dataObject, QString fileDir)
{
    qDebug() << "YMLessonManager::downLoadFile" << fileDir;
    QVariantMap result = dataObject.toVariantMap();;
    QVariantList datalist = result["data"].toList();

    QVariantList filedata;
    //待定
    QVariantMap data = datalist.at(datalist.size() - 1).toMap();
    qDebug() << "hasVoice" << data["hasVoice"];
    if(data["hasVoice"].toInt() == 1)
    {
        filedata = getStuTraila(data["id"].toString(), data["number"].toString(), fileDir);
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
    QString subject = m_repeatData.value("subject").toString();
    QString names = m_repeatData.value("name").toString();

    QStringList courseData;
    courseData << lessonId;
    QString year = m_repeatData.value("startTime").toString().replace("-", "").replace("-", "");
    QString time = year.mid(0, 6);
    courseData << time;
    QByteArray arrydata;
    arrydata.append(QStringLiteral("["));
    arrydata.append(lessonId.toLatin1()).append(QStringLiteral("] ")).append(subject.toUtf8()).append(QStringLiteral(" ")).append(names.toUtf8());
    courseData << arrydata.toHex();
    courseData << filedata.at(0).toString();
    courseData << filedata.at(1).toString();

    courseData << YMUserBaseInformation::type;
    QString runPath = QCoreApplication::applicationDirPath();
    qDebug() << "RunPath:" << filedata;
    QProcess::startDetached(runPath + "/player.exe", courseData);
}

QVariantList YMLessonManager::getStuTraila(QString trailId, QString fileName, QString fileDir)
{
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
    qDebug() << "data::" << data.length();
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

QString YMLessonManager::des_decrypt(const std::string &cipherText)
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

    clearText.clear();
    clearText.assign(vecCleartext.begin(), vecCleartext.end());
    return QString::fromStdString(clearText);
}

QString YMLessonManager::des_encrypt(const QString &clearText)
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

QList<QString> YMLessonManager::decrypt(QString source)
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

void YMLessonManager::encrypt(QString source, QString target)
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
    while (! in.atEnd())
    {
        QString line = in.readLine();
        out << YMCrypt::encrypt(line);
    }
}

void YMLessonManager::enterClass()
{
    QString ipPort = m_port;
    QString address = m_ipAddress;
    qDebug() << "address:" << address;
    QVariantMap dataOthermap;
    dataOthermap.insert("address", address);
    dataOthermap.insert("port", ipPort);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("id", YMUserBaseInformation::id);
    dataOthermap.insert("mobileNo", YMUserBaseInformation::mobileNo);
    dataOthermap.insert("MD5Pwd", YMUserBaseInformation::MD5Pwd);
    qDebug() << ipPort << address << YMUserBaseInformation::MD5Pwd;
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/temp/";

    QDir wdir;
    QDir isDir;

    //设置顶端配置路径
    if (!isDir.exists(m_systemPublicFilePath))
    {
        wdir.mkpath(m_systemPublicFilePath);
    }

    QFile file(m_systemPublicFilePath + "stutemp.ini");
    qDebug() << "m_systemPublicFilePath" << m_systemPublicFilePath;
    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();

    QString runPath = QCoreApplication::applicationDirPath();
    runPath += "/classroom.exe";
    qDebug() << "onRespCloudServer::runPath:" << runPath;
    QProcess *enterRoomprocess = new QProcess(this);
    enterRoomprocess->start(runPath, QStringList());
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
}

void YMLessonManager::getStuVideo(QString videoId, QString fileName, QString fileDir)
{
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_systemPublicFilePath += "/YiMi/";
    m_systemPublicFilePath.append(fileDir).append("/");
    qDebug() << "YMLessonManager::getStuVideo"
             << m_systemPublicFilePath << videoId
             << fileName << fileDir;
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

        QByteArray readData = m_httpClint->httpDownloadFile(url);

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

void YMLessonManager::getCloudServer()
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

    QString url = m_httpClint->httpUrl + "/server/getCloudServer";
    QByteArray dataArray = m_httpClint->httpPostVariant(url, dataMap);
    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    if(dataObject.contains("data"))
    {
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_ipAddress = dataObj.value("domain").toString();
        m_port = QString::number(dataObj.value("port").toInt());
        qDebug() << "onRespCloudServer::ip" << m_ipAddress << m_port;
        int type = dataObj.value("type").toInt();
        if(type == 2)
        {
            enterClass();
            return;
        }
        if(type == 1)
        {
            QString url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
            QByteArray dataArray = m_httpClint->httpGetIp(url.arg(des_encrypt(m_ipAddress)));

            QString IpAddress = des_decrypt(QByteArray::fromHex(dataArray).toStdString());
            IpAddress = IpAddress.split(",").at(0);
            IpAddress = IpAddress.split(";").at(0);
            m_ipAddress = IpAddress;
            enterClass();
            //m_respHandlers.insert(reqCode,&YMLessonManager::onRespGetIp);
            return;
        }
        else
        {
            m_ipAddress = "120.132.3.5";
            m_port = 5122;
            enterClass();
        }
    }
    //m_respHandlers.insert(reqCode,&YMLessonManager::onRespCloudServer);
}


YMLessonManager::~YMLessonManager()
{
    this->disconnect(m_httpClint, 0, 0, 0);
}

void YMLessonManager::onResponse(int reqCode, const QString &data)
{
    qDebug() << "YMLessonManager::onResponse" << reqCode;
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
        emit findChanged();
    }
}
