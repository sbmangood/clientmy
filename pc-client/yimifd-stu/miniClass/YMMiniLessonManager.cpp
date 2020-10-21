#include "YMMiniLessonManager.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"

#include <QStandardPaths>
#include <QCoreApplication>
#include "YMFileTransportEventHandler.h"
#include "../YMCommon/qosV2Manager/YMQosManager.h"
/*
*小班课http数据获取类
*/
std::string keys = "Q-RRt2H2";
YMMiniLessonManager::YMMiniLessonManager(QObject *parent)
    : QObject(parent)
{
    m_httpClint = YMHttpClient::defaultInstance();
    connect(m_httpClint, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut()));

    m_timer = new QTimer(this);
    m_timer->setInterval(15000);
    m_timer->setSingleShot(true);

    tipsTimer = new QTimer(this);
    tipsTimer->setInterval(300000);
    connect(tipsTimer,SIGNAL(timeout()),this,SLOT(getEnterClassTips()));
    tipsTimer->start();

}


void YMMiniLessonManager::getMiniLessonList(QString page,QString pageSize)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/course/list?page=%1&pageSize=%2").arg(page).arg(pageSize);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getMiniLessonList" << objectData;

    emit studentLessonInfoChanged(objectData);
    emit lodingFinished();
}


void YMMiniLessonManager::getMiniLessonItemInfo(QString lessonId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/course/info?courseId=").append(lessonId);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getMiniLessonList" << objectData;

    emit studentLesonListInfoChanged(objectData);
    emit lodingFinished();
}

//我的小班课  http://192.168.3.24:8002/app/mock/45/app/api/s/myclass
void YMMiniLessonManager::getMiniLessonMyLesson(QString page, QString pageSize)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + "/marketing/app/api/s/myclass?page=1&pageSize=-1";
    //QString url = "http://192.168.3.24:8002/app/mock/45/app/api/s/myclass?page=1&pageSize=-1";
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getMiniLessonMyLesson" << url <<  __LINE__ << reqParm << objectData;

    emit myMiniLessonInfoChanged(objectData);
    emit lodingFinished();
}

//小班课课程列表Item详情
QJsonObject YMMiniLessonManager::getMiniLessonMyLessonItemInfo(QString planId, QString type)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/catalogs?classId=%1&type=%2").arg(planId).arg(type);
    //QString url = "http://192.168.3.24:8002/app/mock/45/app/api/s/catalogs";
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    objectData.insert("requestType",type.toInt());
    qDebug() << "YMMiniLessonManager::getMiniLessonMyLessonItemInfo" << objectData << url << __LINE__;
    emit myMiniLessonItemInfoChanged(objectData,type.toInt());
    emit lodingFinished();
    return objectData;
}


//拓课云进入教室
QJsonObject YMMiniLessonManager::getTalkEnterClass(QString planId, QString handleStatus )
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/catalog/go?executionPlanId=%1&handleStatus=%2").arg(planId).arg(handleStatus);

    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    if(dataByte.length() == 0)
    {
        emit sigJoinroomfail();
    }
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    if(objectData.value("result").toString().toLower().contains("success"))
    {
        qDebug() << "YMMiniLessonManager::getTalkEnterClass" << objectData<<planId<<url;
        emit lodingFinished();
        return objectData;
    }
    else
    {
        emit sigJoinroomfail();
        QJsonObject dataObj;
        return dataObj;
    }
}

//拓课云进入教室
QJsonObject YMMiniLessonManager::getEnterClass( QString planId, QString handleStatus )
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/catalog/go?executionPlanId=%1&handleStatus=%2").arg(planId).arg(handleStatus);

    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getEnterClass" << objectData<<planId<<url;
    emit lodingFinished();
    return objectData;
}

//进入教室
QJsonObject YMMiniLessonManager::getEnterClass(QString executionPlanId)
{
    emit sigJoinClassroom("startClassroom");

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    //QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/catalog/go/agora/room?executionPlanId=%1").arg(planId);
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/enter/room?executionPlanId=%1").arg(executionPlanId);

    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    if(dataByte.length() == 0)
    {
        QJsonObject nullObj;
        emit sigJoinroomfail();
        qosV2Mannage();
        return nullObj;
    }
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getEnterClass" << objectData << executionPlanId << url;

    if(objectData.value("result").toString() == "success")
    {
        QJsonObject childData = objectData.value("data").toObject();
        int platform = childData.value("platform").toInt();
        QJsonObject liveRoomObj = childData.value("liveRoomDto").toObject();
        if(platform == 2)
        {
            QJsonObject cloudObj;
            cloudObj.insert("code",objectData.value("code").toInt());
            cloudObj.insert("message",objectData.value("message").toString());
            cloudObj.insert("result",objectData.value("result").toString());
            cloudObj.insert("success",objectData.value("success").toString());
            cloudObj.insert("data",liveRoomObj);
            m_classData = cloudObj;

            QString lessonId = liveRoomObj.value("liveroomId").toString();
            //进入教室埋点
            QJsonObject msgData;
            msgData.insert("lessonId",lessonId);
            msgData.insert("lessonType","ORDER");
            msgData.insert("lessonPlanStartTime",m_startTime);
            msgData.insert("lessonPlanEndTime",m_endTime);
            YMQosManager::gestance()->addBePushedMsg("XBKenterClassroom",msgData);
            //获取服务器Ip
            getCloudServer();
        }
        if(platform == 1)
        {
            emit lodingFinished();
            emit sigJoinClassroom("finshClassroom");
        }
        return liveRoomObj;
    }
    else
    {
        emit sigJoinroomfail();
        qosV2Mannage();
        return objectData;
    }
}

//查看录播
QJsonObject YMMiniLessonManager::getPlayBack(QString executionPlanId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap dataMap;
    dataMap.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    dataMap.insert("appVersion ",YMUserBaseInformation::appVersion);
    dataMap.insert("apiVersion ",YMUserBaseInformation::apiVersion);

    QString signSort = YMEncryption::signMapSort(dataMap);
    QString sign = YMEncryption::md5(signSort).toUpper();

    dataMap.insert("sign", sign);

    QString url = QString(YMUserBaseInformation::miniUrl + "/marketing/app/api/s/playback?executionPlanId=%1").arg(executionPlanId);
    QByteArray dataArray = m_httpClint->httpGetVariant(url,dataMap);

    QJsonObject dataObj;
    if(dataArray.length() == 0)
    {
        return dataObj;
    }

    QJsonObject jsonDataObj = QJsonDocument::fromJson(dataArray).object();
    dataObj = jsonDataObj.value("data").toObject();

    qDebug() << "===getPlayBack===" << jsonDataObj;

    int platform = dataObj.value("platform").toInt();
    if(platform == 2)
    {
        QJsonArray dataArray = dataObj.value("list").toArray();
        this->downloadMiniPlayFile(dataArray);
        return dataObj;
    }

    if(platform == 1)
    {
       return dataObj;
    }
}

void YMMiniLessonManager::getCloudServer()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/agora/domain");

    QByteArray dataArray = m_httpClint->httpGetVariant(url,reqParm);

    QJsonObject dataObject = QJsonDocument::fromJson(dataArray).object();
    qDebug() << "onRespCloudServer::ip"<<dataObject << m_ipAddress << m_tcpPort;

    if(dataObject.contains("data"))
    {
        QJsonObject dataObj = dataObject.value("data").toObject();
        m_ipAddress = dataObj.value("domain").toString();
        m_tcpPort = QString::number(dataObj.value("tcpPort").toInt());
        m_udpPort = QString::number(dataObj.value("udpPort").toInt());
        m_httpPort = QString::number(dataObj.value("httpPort").toInt());

        int type = dataObj.value("domainType").toInt();
        if(type == 0) //服务端指定Ip
        {
            //resetSelectIp(1, m_ipAddress);
            enterClass();
            return;
        }
        if(type == 1) //服务器未指定Ip
        {
            //腾讯云的 移动解析 Http DNS 服务
            //备用ip: 119.28.28.28
            url = "http://119.29.29.29/d?dn=%1&id=191&ttl=1";
            dataArray = m_httpClint->httpGetIp(url.arg(des_encrypt(m_ipAddress)));
            QString IpAddress = des_decrypt(QByteArray::fromHex(dataArray).toStdString());

            IpAddress = IpAddress.split(",").at(0);
            IpAddress = IpAddress.split(";").at(0);
            m_ipAddress = IpAddress;
            qDebug() << "==ip::dataArray==" << dataArray << IpAddress << m_ipAddress;
            //resetSelectIp(2,m_ipAddress);
            enterClass();
            return;
        }
        else
        {
            m_ipAddress = "120.132.3.5";
            m_tcpPort = "5122";
            m_udpPort = "5120";
            //resetSelectIp(2,m_ipAddress);
            enterClass();
        }
    }
    else{
        emit sigJoinroomfail();
        qosV2Mannage();
    }
}

void YMMiniLessonManager::enterClass()
{
    QString httpPort = m_httpPort;
    QString address = m_ipAddress;
    QString udpPort = m_udpPort;
    QString tcpPort = m_tcpPort;
    //qDebug() << "address:" << address;
    QVariantMap dataOthermap;
    dataOthermap.insert("address", address);
    dataOthermap.insert("httpPort", httpPort);
    dataOthermap.insert("tcpPort", tcpPort);
    dataOthermap.insert("udpPort", udpPort);
    dataOthermap.insert("token", YMUserBaseInformation::token);
    dataOthermap.insert("apiVersion", YMUserBaseInformation::apiVersion);
    dataOthermap.insert("appVersion", YMUserBaseInformation::appVersion);
    dataOthermap.insert("deviceInfo", YMUserBaseInformation::deviceInfo);
    dataOthermap.insert("logTime", YMUserBaseInformation::logTime);
    dataOthermap.insert("userName", YMUserBaseInformation::userName);

    dataOthermap.insert("plat", "S");

    dataOthermap.insert("lessonType", "");
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
    qDebug() << "====stuUserType====" << YMUserBaseInformation::stuUserType;
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
        filename = "miniStuTemp.ini";
    }
    else
    {
        filename = "MiniStuTempAttend.ini";
    }
    QFile file(m_systemPublicFilePath + filename);
    //qDebug() << "m_systemPublicFilePath" << m_systemPublicFilePath;

    file.open(QIODevice::WriteOnly);
    QByteArray byte_array = QJsonDocument(m_classData).toJson();
    file.write(byte_array.append("###").append(QJsonDocument::fromVariant(dataOthermap).toJson()));
    file.flush();
    file.close();

    QString runPath = QCoreApplication::applicationDirPath();

    //qDebug() << "onRespCloudServer::runPath:" << runPath;
    QProcess *enterRoomprocess = new QProcess(this);
    connect(enterRoomprocess, SIGNAL(finished(int)), this, SIGNAL(lessonlistRenewSignal()));
    //enterRoomprocess->start(runPath,QStringList());
    //attendclassroom
    if(YMUserBaseInformation::stuUserType)
    {
        runPath += "/ministudentclassroom.exe";
        enterRoomprocess->start(runPath, QStringList());
        enterRoomprocess->waitForStarted(5000);
        emit hideEnterClassRoomItem();
    }
    else
    {
        runPath += "/miniattendclassroom.exe";
        enterRoomprocess->start(runPath, QStringList());
        enterRoomprocess->waitForStarted(5000);
        emit hideEnterClassRoomItem();
    }
    emit sigJoinClassroom("finshClassroom");;

}

QString YMMiniLessonManager::des_encrypt(const QString &clearText)
{
    DES_cblock keyEncrypt;
    memset(keyEncrypt, 0, 8);

    if (keys.length() <= 8)
        memcpy(keyEncrypt, keys.c_str(), keys.length());
    else
        memcpy(keyEncrypt, keys.c_str(), 8);

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

QList<QString> YMMiniLessonManager::decrypt(QString source)
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
void YMMiniLessonManager::encrypt(QString source, QString target)
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
QString YMMiniLessonManager::des_decrypt(const std::string &cipherText)
{
    std::string clearText; // 明文
    DES_cblock keyEncrypt;
    memset(keyEncrypt, 0, 8);
    if (keys.length() <= 8)
        memcpy(keyEncrypt, keys.c_str(), keys.length());
    else
        memcpy(keyEncrypt, keys.c_str(), 8);

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


QString YMMiniLessonManager::getH5Url(QString executionPlanId,QString handleStatus,QString className,QString title)
{
    //"http://dev-h5.yimifudao.com.cn/classAssignment?executionPlanId=" + classId +"&handleStatus=12&token=" + miniLessonManager.getToken()+"&className='"+classIndex+"'&title='"+classNameTitle+"'";
    //域名待修改
    QString runUrl = YMUserBaseInformation::miniH5 + QString("?executionPlanId=%1&handleStatus=%2&token=%3&className=%4&title=%5").arg(executionPlanId).arg(handleStatus).arg(YMUserBaseInformation::token).arg(className).arg(title);
    qDebug()<<"getH5Url("<<runUrl;
    return runUrl;
}

void YMMiniLessonManager::getEnterClassTips()
{   
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/notice/class");
    //QString url = "http://192.168.3.24:8002/app/api/s/notice/class";
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getEnterClassTips" << objectData ;
    QJsonObject tObj;
    if(!objectData.value("data").isObject())
    {
        tObj.insert("isShow",false);
        tObj.insert("executionPlanId","");
        tObj.insert("handleStatus",0);
    }else
    {
        tObj = objectData.value("data").toObject();
        tObj.insert("isShow",true);
        tObj.insert("executionPlanId",tObj.value("executionPlanId").toString());
        tObj.insert("handleStatus",tObj.value("handleStatus").toInt());
    }
    enterClassTips(tObj);
    emit lodingFinished();
}

#if 0
QString YMMiniLessonManager::getRunUrl()
{
    QString tUrl = m_httpClint->httpUrl;
    if(tUrl.contains("//dev-api"))
    {
        tUrl = "https://dev-platform.yimifudao.com.cn/v1.0.0";
    }else if(tUrl.contains("//stage-api"))
    {
        tUrl = "https://stage-platform.yimifudao.com.cn/v1.0.0";
    }if(tUrl.contains("//pre-api"))
    {
        tUrl = "https://pre-platform.yimifudao.com.cn/v1.0.0";
    }else
    {
        //线上 待定
    }
    return tUrl;
}
#endif

QJsonObject YMMiniLessonManager::getDoHomeWorkTips(QString classId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/notice/class?type=1&classId=%1").arg(classId);
    //QString url = "http://192.168.3.24:8002/app/api/s/notice/class";
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getDoHomeWorkTips" << objectData <<url;
    QJsonObject tObj;
    if(!objectData.value("data").isObject())
    {
        tObj.insert("isShow",false);
        tObj.insert("executionPlanId","");
        tObj.insert("handleStatus",0);
    }else
    {
        tObj = objectData.value("data").toObject();
        tObj.insert("isShow",true);
        tObj.insert("executionPlanId",tObj.value("executionPlanId").toString());
        tObj.insert("handleStatus",tObj.value("handleStatus").toInt());
    }

    return tObj;
}


void YMMiniLessonManager::enterClassTimerOut()
{
    emit requestTimerOut();
    //qDebug() << "YMMiniLessonManager::getEnterClassTimerOut";
}

//查看课件
void YMMiniLessonManager::getLookCourse(QString executionPlanId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion); //接口标注3.0
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/catalog/preview/courseware?executionPlanId=%1").arg(executionPlanId);
    //QString url = "http://192.168.3.24:8002/app/api/s/notice/class";
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getLookCourse" << objectData <<url;


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
    files.write(dataByte);
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
                               "\"udpPort\": \"5120\","
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

YMMiniLessonManager::~YMMiniLessonManager()
{
    this->disconnect(m_httpClint, 0, 0, 0);
}

void YMMiniLessonManager::onResponse(int reqCode, const QString &data)
{
    //qDebug() << "YMMiniLessonManager::onResponse" << reqCode;
    if (m_respHandlers.contains(reqCode))
    {
        HttpRespHandler handler = m_respHandlers.find(reqCode).value();
        (this->*handler)(data);
        m_respHandlers.remove(reqCode);
    }
}

void YMMiniLessonManager::downloadMiniPlayFile(QJsonArray dataArray)
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
    qDebug()<< "===trailFilePath===" << trailFilePath;
    courseData << trailFilePath.toUtf8().toHex(); //文件路径进行加密
    courseData << QString::number(trailNumber) +".txt";
    courseData << YMUserBaseInformation::type;
    courseData << YMUserBaseInformation::token;
    courseData << YMUserBaseInformation::apiVersion;
    courseData << YMUserBaseInformation::appVersion;
    courseData << YMUserBaseInformation::id;

    QString runPath = QCoreApplication::applicationDirPath();
    QProcess::startDetached(runPath + "/miniclass_player.exe", courseData);
}

void YMMiniLessonManager::writeFile(QString liveroomId,QString path,int fileNumber,QString suffix)
{
    qDebug() << "==path==" << path << fileNumber << suffix;
    QString filename(QString::number(fileNumber) + suffix);
    QString m_systemPublicFilePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +  "/YiMi/" + liveroomId + "/";
    QDir dir;
    if(!dir.exists(m_systemPublicFilePath))
    {
        dir.mkdir(m_systemPublicFilePath);
    }
    QFile file(m_systemPublicFilePath + filename);
    if(file.exists())
    {
        file.flush();
        file.close();
        return;
    }
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
    file.open(QIODevice::WriteOnly);
    file.write(readData);
    file.flush();
    file.close();
}

void YMMiniLessonManager::setQosStartTime(qlonglong startTime, qlonglong endTime)
{
    m_startTime = QString::number(startTime);
    m_endTime = QString::number(endTime);
    qDebug() << "===setQosStartTime===" << startTime << endTime;
}

void YMMiniLessonManager::qosV2Mannage()
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
    YMQosManager::gestance()->initQosManager(initData,YMUserBaseInformation::type);

    QJsonObject msgData;
    msgData.insert("socketIp","");
    msgData.insert("lessonPlanStartTime",m_startTime);
    msgData.insert("lessonPlanEndTime",m_endTime);
    msgData.insert("result","0");
    msgData.insert("errMsg",QStringLiteral("进入教室失败!"));
    YMQosManager::gestance()->addBePushedMsg("XBKenterClassroomFinished",msgData);
}



