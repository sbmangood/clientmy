#include "YMMiniclassManagerAdapter.h"

YMMiniclassManagerAdapter::YMMiniclassManagerAdapter(QObject *parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpClient->getRunUrl(1);
}

QJsonObject YMMiniclassManagerAdapter::getCloudDiskFileInfo(QString docId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/t/cloud/disk/file/detail?fileId=%1").arg(docId);
    QByteArray dataByte = m_httpClient->httpGetVariant(url,reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMMiniclassManagerAdapter::getCloudDiskFileInfo"<< objectData;
    return objectData;
}
