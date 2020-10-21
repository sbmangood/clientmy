#include <QDir>
#include <QDateTime>
#include <QEventLoop>
#include <QStandardPaths>
#include "filedownload.h"
#include "ymcrypt.h"
#include"YMUserBaseInformation.h"
#include "AESCryptManager/AESCryptManager.h"


FileDownload::FileDownload(QObject * parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onRequstTimerOut()), this, SIGNAL(requstTimeOuted()));
}

FileDownload::~FileDownload()
{
    disconnect(m_httpClient, 0, 0, 0);
}

// 查看回放
void FileDownload::getPlayback(QString appUrl, QString lessonId, QString appId)
{
    QString url = appUrl + "/app/playback";
    QDateTime currentTime = QDateTime::currentDateTime();
    QJsonObject dataJson;
    dataJson.insert("ts", currentTime.currentMSecsSinceEpoch());
    dataJson.insert("lessonId",lessonId);

    QJsonDocument doc(dataJson);
    QString msg = QString(doc.toJson(QJsonDocument::Compact));
    AESCryptManager aESCryptManager;// AES加密
    QString msgen = QString::fromStdString(aESCryptManager.EncryptionAES(msg.toStdString()));
    qDebug() << "appUrl--" << url <<",msg=" << msg << ",msgen=" << msgen;

    QJsonObject paramObj;
    paramObj.insert("appid", appId);
    paramObj.insert("encyptyData", msgen);
    QJsonDocument docparam(paramObj);
    QString parammsg = QString(docparam.toJson(QJsonDocument::Compact));


    QByteArray byteArray = m_httpClient->httpPostMsg(url, YMUserBaseInformation::token, parammsg);
    if(byteArray.length() == 0)
    {
        emit sigDownLoadFailed();
        return;
    }

    QJsonObject jsonDataObj = QJsonDocument::fromJson(byteArray).object();
    QJsonObject dataObj = jsonDataObj.value("data").toObject();

    QString roomId = dataObj.value("roomId").toString();
    QJsonArray dataArray = dataObj.value("trailRecordResDtoList").toArray();

    if(dataArray.size() > 0)
    {
        downloadMiniPlayFile(roomId, dataArray);
        return;
    }
    emit sigDownLoadFailed();
}

void FileDownload::downloadMiniPlayFile(const QString &roomId, QJsonArray dataArray)
{
    QString trailFile;
    int trailNumber = 0;
    QString liveroomId = roomId;
    emit setDownValue(0, dataArray.size());
    for(int i = 0; i < dataArray.size(); i++)
    {
       QJsonObject arrayData  = dataArray.at(i).toObject();
       int number = arrayData.value("number").toString().toInt();
       QString trailUrl = arrayData.value("trailUrl").toString();
       QString voiceUrl = arrayData.value("voiceUrl").toString();
       qDebug()<< "download file" << number<< trailUrl<< voiceUrl;
       trailFile = trailUrl;
       trailNumber = number;
       emit downloadChanged(number);
       writeFile(liveroomId,voiceUrl,number,".mp3");
    }

    writeFile(liveroomId,trailFile,trailNumber,".txt");

    QString trailFileName(QString::number(trailNumber) + ".txt");
    QString fileCachePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +  "/YiMi/" + liveroomId;
    emit downloadFinished(roomId, "", fileCachePath, trailFileName);

}

void FileDownload::writeFile(QString liveroomId,QString path,int fileNumber,QString suffix)
{
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

    file.open(QIODevice::WriteOnly);
    file.write(readData);
    file.flush();
    file.close();
}
