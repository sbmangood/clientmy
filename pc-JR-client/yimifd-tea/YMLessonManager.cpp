#include "YMLessonManager.h"
#include <QStandardPaths>
#include <QCoreApplication>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include <QMessageBox>
/*
*小班课http数据获取类
*/
#define MSG_BOX_TITLE  QString(u8"溢米辅导")

YMLessonManager::YMLessonManager(QObject *parent) : QObject(parent)
{
    m_timer = new QTimer();
    m_timer->setInterval(15000);
    m_timer->setSingleShot(true);
    readUserBaseInfo();
    qDebug()<<"======YMLessonManager::readUserBaseInfo="
           << m_userBaseInfo.apiVersion
           <<",appVersion="<< m_userBaseInfo.appVersion
          <<",token="<< m_userBaseInfo.token
         <<",liveroomId="<< m_userBaseInfo.liveroomId
        <<",miniUrl="<< m_userBaseInfo.miniUrl
       <<",miniH5="<< m_userBaseInfo.miniH5;
}

YMLessonManager::~YMLessonManager()
{
    if(NULL != m_timer)
    {
        delete m_timer;
        m_timer = NULL;
    }
}

int YMLessonManager::readUserBaseInfo()
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
    QDir isDir;
    if (!isDir.exists(systemPublicFilePath))
    {
        qDebug() << QString("!isDir.exists") << systemPublicFilePath << __LINE__;
        return -1;
    }
    if (!QFile::exists(systemPublicFilePath + "miniTemp.ini"))
    {
        qDebug() << QString("!QFile.exists") << systemPublicFilePath + "miniTemp.ini" << __LINE__;
        return -1;
    }
    QFile file(systemPublicFilePath + "miniTemp.ini");
    if(!file.open(QIODevice::ReadOnly))
    {
        qDebug() << QString("!file.open") << __LINE__;
        return -1;
    }
    QByteArray arrys = file.readAll();
    QString backDatas(arrys);
    file.close();

    if(backDatas.length() < 1)
    {
        qDebug() << QString("backData.length() < 1") << __LINE__;
        return -1;
    }
    QStringList listIndor = backDatas.split("###");
    QString backData, backDataOne;
    for(int i = 0 ; i < listIndor.count() ; i++)
    {
        if(i == 0)
        {
            backData = listIndor[0];
        }
        if(i == 1)
        {
            backDataOne = listIndor[1];
        }
    }
    // 读取apiVersion、appVersion、token
    QJsonParseError errors;
    QJsonDocument documets = QJsonDocument::fromJson(backDataOne.toUtf8(), &errors);
    if(errors.error == QJsonParseError::NoError)
    {
        if(documets.isObject())
        {
            QJsonObject jsonObjsa = documets.object();
            m_userBaseInfo.apiVersion = jsonObjsa.take("apiVersion").toString();
            m_userBaseInfo.appVersion = jsonObjsa.take("appVersion").toString();
            m_userBaseInfo.token = jsonObjsa.take("token").toString();
        }
    }
    // 读取liveroomId
    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        if(documet.isObject())
        {
            QJsonObject jsonObjs = documet.object();
            if(jsonObjs.contains("data"))
            {
                QJsonObject jsonObj = jsonObjs.take("data").toObject();
                m_userBaseInfo.liveroomId = jsonObj.take("liveroomId").toString();
            }
        }
    }
    // 读取miniUrl、miniH5
    QString strDllFile = QCoreApplication::applicationDirPath();
    strDllFile += "/Qtyer.dll";
    QString strMsg = QString(u8"文件: %1, 不存在, 程序将退出." ) .arg(strDllFile);
    if(!QFile::exists(strDllFile))
    {
        QMessageBox::critical(NULL, MSG_BOX_TITLE, strMsg, QMessageBox::Ok, QMessageBox::Ok);
        exit(1);
    }
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);
    m_setting->beginGroup("MiniClass");
    m_userBaseInfo.miniUrl = m_setting->value("miniUrl").toString();
    m_userBaseInfo.miniH5 = m_setting->value("miniH5").toString();
    m_setting->endGroup();

    if(NULL != m_setting)
    {
        delete m_setting;
        m_setting = NULL;
    }

    return 0;
}

QByteArray YMLessonManager::httpGetVariant(QString url,const QVariantMap &formData)
{
    QUrl encodedUrl = QUrl(url);
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader,"application/json;charset=UTF-8");
    QString common_Params;
    int make = 0;
    for (QVariantMap::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        make++;
        if(make == formData.count())
        {
            common_Params.append( it.key() + "=" + it.value().toString());
        }
        else
        {
            common_Params.append(it.key() + "=" + it.value().toString() + "&");
        }
    }

    httpRequest.setRawHeader("X-AUTH-TOKEN",m_userBaseInfo.token.toLatin1());
    httpRequest.setRawHeader("Common-Params",common_Params.toLatin1());
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    QEventLoop httploop;
    QNetworkReply * reply = httpAccessmanger->get(httpRequest);
    connect(reply, SIGNAL(finished()), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();

    if(302 == reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt())
    {
        disconnect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        QString tempUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toString();
        httpRequest.setUrl(QUrl(tempUrl));
        reply = httpAccessmanger->get(httpRequest);
        httploop.exec();
    }

    QByteArray byteArray;
    if(m_timer->isActive())
    {
        m_timer->stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            byteArray = reply->readAll();
            reply->deleteLater();
            httpAccessmanger->deleteLater();
            return byteArray;
        }
    }
    reply->deleteLater();
    httpAccessmanger->deleteLater();

    if(NULL != httpAccessmanger)
    {
        delete httpAccessmanger;
        httpAccessmanger = NULL;
    }
    return byteArray;
}

void YMLessonManager::getEnterRoomData()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", m_userBaseInfo.appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", m_userBaseInfo.apiVersion);
    QString sign = YMEncryptions::signMapSort(reqParm);
    QString md5Sign = YMEncryptions::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = m_userBaseInfo.miniUrl + QString("/marketing/app/api/t/catalog/go/agora/room?executionPlanId=%1").arg(m_userBaseInfo.liveroomId);
    QByteArray dataByte = httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMLessonManager::getEnterRoomData" <<url<< objectData;
}

QJsonArray YMLessonManager::getCloudDiskInitFileInfo()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", m_userBaseInfo.appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", m_userBaseInfo.apiVersion);
    QString sign = YMEncryptions::signMapSort(reqParm);
    QString md5Sign = YMEncryptions::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = m_userBaseInfo.miniUrl + QString("/marketing/app/api/t/cloud/disk/room?liveroomId=%1").arg(m_userBaseInfo.liveroomId);
    QByteArray dataByte = httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    //qDebug() << "YMLessonManager::getCloudDiskInitFileInfo" <<url<< objectData << reqParm << m_userBaseInfo.token;
    return objectData.value("data").toArray();
}

QJsonArray YMLessonManager::getCloudDiskFolderInfo(QString folderId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", m_userBaseInfo.appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", m_userBaseInfo.apiVersion);
    QString sign = YMEncryptions::signMapSort(reqParm);
    QString md5Sign = YMEncryptions::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = m_userBaseInfo.miniUrl + QString("/marketing/app/api/t/cloud/disk/file?fileId=%1").arg(folderId);
    QByteArray dataByte = httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    //qDebug() << "YMLessonManager::getCloudDiskFolderInfo" <<url<< objectData;
    return objectData.value("data").toArray();
}

QJsonObject YMLessonManager::getCloudDiskFileInfo(QString fileId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", m_userBaseInfo.appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", m_userBaseInfo.apiVersion);
    QString sign = YMEncryptions::signMapSort(reqParm);
    QString md5Sign = YMEncryptions::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    QString url = m_userBaseInfo.miniUrl + QString("/marketing/app/api/t/cloud/disk/file/detail?fileId=%1").arg(fileId);
    QByteArray dataByte = httpGetVariant(url,reqParm);
    //qDebug() << "YMLessonManager::getCloudDiskFileInfo"<< dataByte.length() <<url;
    QJsonParseError jsonParseError;
    QJsonDocument document = QJsonDocument::fromJson(dataByte, &jsonParseError);
    if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
    {
        qDebug() << "==getCloudDiskFileInfo::Error:Json===";
    }
    QJsonObject objectData = document.object();
    QJsonObject jsonData = objectData.value("data").toObject();
    QString jsonDataStr  = jsonData.value("jsonData").toString();
    QJsonObject objChildJson = QJsonDocument::fromJson(jsonDataStr.toUtf8()).object();
    QJsonArray lessonItems  = objChildJson.value("lessonItems").toArray();
    QJsonObject h5Obj = lessonItems.at(0).toObject();
    int h5Size = h5Obj.value("h5Json").toArray().size();
    emit sigCoursewareTotalPage(h5Size);
    //qDebug() << "==h5::Size==" << h5Size << lessonItems.size();
    return objectData;
}
