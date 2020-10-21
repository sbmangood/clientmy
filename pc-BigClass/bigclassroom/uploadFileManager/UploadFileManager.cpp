#include <QTimer>
#include <QEventLoop>
#include <QNetworkRequest>
#include <QFile>
#include <QNetworkAccessManager>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>
#include "UploadFileManager.h"

UploadFileThread::UploadFileThread()
{

}

UploadFileThread::~UploadFileThread()
{

}

void UploadFileThread::setBasicParams(QJsonObject basicParamsObj)
{
    m_basicMutex.lock();
    m_basicParamsObj = basicParamsObj;
    m_basicMutex.unlock();
}

QJsonObject UploadFileThread::getBasicParams()
{
    QJsonObject paramsObj;
    m_basicMutex.lock();
    paramsObj = m_basicParamsObj;
    m_basicMutex.unlock();
    return paramsObj;
}

void UploadFileThread::run()
{
    QJsonObject paramsObj = getBasicParams();
    QString filePath, lessonId, userId, token, enType, httpUrl, appVersion, apiVersion;
    int time_out = 10000;
    if(paramsObj.contains("filePath"))
    {
        filePath = paramsObj.take("filePath").toString();
    }
    if(paramsObj.contains("lessonId"))
    {
        lessonId = paramsObj.take("lessonId").toString();
    }
    if(paramsObj.contains("userId"))
    {
        userId = paramsObj.take("userId").toString();
    }
    if(paramsObj.contains("token"))
    {
        token = paramsObj.take("token").toString();
    }
    if(paramsObj.contains("enType"))
    {
        enType = paramsObj.take("enType").toString();
    }
    if(paramsObj.contains("httpUrl"))
    {
        httpUrl = paramsObj.take("httpUrl").toString();
    }
    if(paramsObj.contains("appVersion"))
    {
        appVersion = paramsObj.take("appVersion").toString();
    }
    if(paramsObj.contains("apiVersion"))
    {
        apiVersion = paramsObj.take("apiVersion").toString();
    }
    if(paramsObj.contains("time_out"))
    {
        time_out = paramsObj.take("time_out").toInt();
    }

    QString paths = QUrl::fromPercentEncoding(filePath.toUtf8());
    QFile *pFile_upLoad = new QFile(paths);

    if(!QFile::exists(paths) || !pFile_upLoad->open(QIODevice::ReadOnly) || pFile_upLoad->size() <= 0)
    {
        delete pFile_upLoad;
        pFile_upLoad = NULL;
        qDebug()<<"======select file failed======";
        return;
    }

    QEventLoop loop;
    QTimer *timer = new QTimer();
    timer->setInterval(time_out); // 超时还没有上传完也退出
    connect(timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    QMap<QString, QString> maps;
    QDateTime times = QDateTime::currentDateTime();
    maps.insert("token", token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    maps.insert("lessonId", lessonId + "_" + userId + "_" + times.toString("yyyyMMddhhmmss"));
    maps.insert("appVersion", appVersion);
    maps.insert("apiVersion", apiVersion);

    QString sign;
    int i = 0;
    for(QMap<QString, QString>::iterator it = maps.begin(); it != maps.end(); it++)
    {
        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
        i++;
    }
    QString urls;
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"%1\"; filename=\"%2\"").arg("multipartFile").arg(paths)));
    imagePart.setBodyDevice(pFile_upLoad);
    pFile_upLoad->setParent(multiPart);
    multiPart->append(imagePart);

    if(enType != "")
    {
        httpUrl = enType + httpUrl;
    }
    QString httpsd= "http://" + httpUrl + "/log/logUpload?" + QString("%1").arg(urls);
    qDebug() << "=====Start to upload======" << paths << "===>" << httpsd;
    QUrl url(httpsd);
    QNetworkRequest request(url);
    QNetworkReply *networkReply = httpAccessmanger->post(request, multiPart);
    connect(networkReply, SIGNAL(finished()), &loop, SLOT(quit()));
    connect(networkReply, SIGNAL(error(QNetworkReply::NetworkError)), &loop, SLOT(quit()));
    timer->start();
    loop.exec();

    QByteArray replyData = networkReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();

    long fileSize =  pFile_upLoad->size();

    if(NULL != networkReply)
    {
        networkReply->deleteLater();
        networkReply->close();
        delete networkReply;
        networkReply = NULL;
    }
    if(NULL != pFile_upLoad)
    {
        pFile_upLoad->close();
    }
    if(NULL != multiPart)
    {
        delete multiPart;
        multiPart = NULL;
    }
    if(NULL != httpAccessmanger)
    {
        delete httpAccessmanger;
        httpAccessmanger = NULL;
    }
    if(NULL != timer)
    {
        timer->stop();
        delete timer;
        timer = NULL;
    }
    if(dataObject.value("result").toString().toLower() == "success")
    {
        if(dataObject.contains("message"))
        {
            emit sigUploadSuccess(dataObject.take("message").toString(), fileSize);
        }
    }
    else
    {
        emit sigUploadFailed();
    }
}

UploadFileManager::UploadFileManager() : m_uploadFileThread(NULL)
{
    m_uploadFileThread = new UploadFileThread();
    connect(m_uploadFileThread, SIGNAL(sigUploadSuccess(QString, long)), this, SIGNAL(sigUploadSuccess(QString, long)));
    connect(m_uploadFileThread, SIGNAL(sigUploadFailed()), this, SIGNAL(sigUploadFailed()));
}

UploadFileManager::~UploadFileManager()
{
    if(NULL != m_uploadFileThread)
    {
        delete m_uploadFileThread;
        m_uploadFileThread = NULL;
    }
}

int UploadFileManager::upLoadFileToServer(QString filePath, QString lessonId, QString userId, QString token, QString enType, int time_out, QString httpUrl, QString appVersion, QString apiVersion)
{
    QJsonObject basicParamsObj;
    basicParamsObj.insert("filePath", filePath);
    basicParamsObj.insert("lessonId", lessonId);
    basicParamsObj.insert("userId", userId);
    basicParamsObj.insert("token", token);
    basicParamsObj.insert("time_out", time_out);
    basicParamsObj.insert("enType", enType);
    basicParamsObj.insert("httpUrl", httpUrl);
    basicParamsObj.insert("appVersion", appVersion);
    basicParamsObj.insert("apiVersion", apiVersion);

    QEventLoop eventLoop;
    connect(m_uploadFileThread, SIGNAL(finished()), &eventLoop, SLOT(quit())); // 线程执行完成以后, 退出loop
    QTimer::singleShot(time_out, &eventLoop, SLOT(quit())); // 超时退出loop
    QTimer *timer = new QTimer();
    timer->setInterval(time_out);
    connect(timer, &QTimer::timeout, &eventLoop, &QEventLoop::quit);
    timer->start();
    if(NULL != m_uploadFileThread)
    {
        m_uploadFileThread->setBasicParams(basicParamsObj);
        m_uploadFileThread->start();
    }
    eventLoop.exec();

    if(NULL != m_uploadFileThread)
    {
        m_uploadFileThread->quit();
    }
    if(NULL != timer)
    {
        delete timer;
        timer = NULL;
    }
    return 0;
}
