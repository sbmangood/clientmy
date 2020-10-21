#include "YMMiniLessonManager.h"
#include "YMEncryption.h"
#include <QStandardPaths>
#include <QCoreApplication>

/*
*小班课http数据获取类
*/

YMMiniLessonManager::YMMiniLessonManager(QObject *parent)
    : QObject(parent)
{

    m_httpClint = YMHttpClient::defaultInstance();
    m_httpClint->getRunUrl(1);

}

YMMiniLessonManager::~YMMiniLessonManager()
{

}

void YMMiniLessonManager::getEnterRoomData()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/t/catalog/go/agora/room?executionPlanId=%1").arg(YMUserBaseInformation::liveroomId);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getEnterRoomData" <<url<< objectData;
}

QJsonArray YMMiniLessonManager::getCloudDiskInitFileInfo()
{
    qDebug()<<"NetworkAccessManagerInfor::getCloudDiskInitFileInfo()"<<YMUserBaseInformation::miniUrl;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/t/cloud/disk/room?liveroomId=%1").arg(YMUserBaseInformation::liveroomId);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getCloudDiskInitFileInfo" <<url<< objectData << reqParm << YMUserBaseInformation::token;
    return objectData.value("data").toArray();
}

QJsonArray YMMiniLessonManager::getCloudDiskFolderInfo(QString folderId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/t/cloud/disk/file?fileId=%1").arg(folderId);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getCloudDiskFolderInfo" <<url<< objectData;
    return objectData.value("data").toArray();
}

QJsonObject YMMiniLessonManager::getCloudDiskFileInfo(QString fileId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/t/cloud/disk/file/detail?fileId=%1").arg(fileId);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    qDebug() << "YMMiniLessonManager::getCloudDiskFileInfo"<< dataByte.length() <<url;
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
    qDebug() << "==h5::Size==" << h5Size << lessonItems.size();
    return objectData;
}


