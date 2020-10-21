#include "YMMiniLessonManager.h"
#include "YMEncryption.h"
#include <QStandardPaths>
#include <QCoreApplication>

/*
*小班课http数据获取类
* 学生端主要用到 getCloudDiskFileInfo 根据fileid来获取可见的url arry getIpListInfo 获取Ip列表
*/

YMMiniLessonManager::YMMiniLessonManager(QObject *parent)
    : QObject(parent)
{

    m_httpClint = YMHttpClient::defaultInstance();

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
    qDebug() << "YMMiniLessonManager::getCloudDiskInitFileInfo" <<url<< objectData;
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
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/cloud/disk/file?fileId=%1").arg(folderId);
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
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/cloud/disk/file/detail?fileId=%1").arg(fileId);
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getCloudDiskFileInfo" <<url<< QString::fromUtf8(dataByte);
    return objectData;
}

QJsonObject YMMiniLessonManager::getIpListInfo()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/agora/ip/list");
    QByteArray dataByte = m_httpClint->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniLessonManager::getIpListInfo" <<url<< objectData;
    return objectData;
    /*{"code":2000,"data":[{"createById":null,"createByName":"","createByTime":1543204709000,"deleteFlag":0,"id":2,"isValid":1,"isp":"","serverArea":"bbb","serverIp":"192.0.0.1","serverLimit":null,"serverName":"bbb","serverWarn":null,"updateById":null,"updateByName":"","updateByTime":""},{"createById":null,"createByName":"","createByTime":1543204696000,"deleteFlag":0,"id":1,"isValid":1,"isp":"","serverArea":"aaa","serverIp":"168.0.0.1","serverLimit":null,"serverName":"aaa","serverWarn":null,"updateById":null,"updateByName":"","updateByTime":""}],"message":"鎴愬姛","result":"success","success":true}*/
}
