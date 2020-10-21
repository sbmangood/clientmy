#include "YMHttpClient.h"
#include "YMHttpResponse.h"
#include "YMFileTransportResponse.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include <QMessageBox>
#include <QProcess>
#include <QJsonObject>
#include <QJsonDocument>
#include <QApplication>

extern int g_ReturnCode_Restart;
extern QString g_strAppFullPath;
extern QString g_strAppFileName;
#define MSG_BOX_TITLE  QString(u8"溢米辅导")

class YMHttpClientFactory
{
    public:
        YMHttpClientFactory()
            : m_httpClient(0)
        {

        }

        ~YMHttpClientFactory()
        {
            if (m_httpClient)
            {
                delete m_httpClient;
            }
        }

        YMHttpClient * getHttpClient()
        {
            if (!m_httpClient)
            {
                m_httpClient = new YMHttpClient();
                YMUserBaseInformation::url = "http://" + m_httpClient->getRunUrl(1);
                m_httpClient->httpUrl = YMUserBaseInformation::url;
            }
            return m_httpClient;
        }

        YMHttpClient * m_httpClient;
};

YMHttpClientFactory g_httpClientFactory;

YMHttpClient::YMHttpClient(QObject *parent)
    : QObject(parent)
{
    m_reqCode = 0;
    m_networkMgr = new QNetworkAccessManager(this);
    m_networkMgrIp = new QNetworkAccessManager(this);
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinished(QNetworkReply*)));
    m_timer = new QTimer();
    m_timer->setInterval(15000);
    m_timer->setSingleShot(true);
}

YMHttpClient * YMHttpClient::defaultInstance()
{
    return g_httpClientFactory.getHttpClient();
}

int YMHttpClient::httpGet(
    QString url,
    const QMap<QString, QString>& reqParam,
    YMHttpResponseHandler * handler)
{
    //qDebug() << "YMHttpClient::httpGet" << url << reqParam << handler;
    QUrl encodedUrl = QUrl(url);
    if (reqParam.size() > 0)
    {
        QStringList formatedParam;
        for (QMap<QString, QString>::const_iterator it = reqParam.begin(); it != reqParam.end(); it ++)
        {
            formatedParam << it.key() + "=" + it.value();
        }
        QString formatedUrl = url + "?" + formatedParam.join("&");
        encodedUrl = QUrl(formatedUrl);
    }
    //qDebug() << "YMHttpClient::httpGet" << encodedUrl;

    QNetworkReply * reply = m_networkMgr->get(QNetworkRequest(encodedUrl));
    YMHttpResponse * resp = new YMHttpResponse(reply, handler, ++m_reqCode);
    m_httpReqs.insert(reply, resp);

    return m_reqCode;
}

QByteArray YMHttpClient::httpGetVariant(
    QString url,
    YMHttpResponseHandler *handler)
{
    //qDebug() << "YMHttpClient::httpGetVariant" << url << handler;
    QUrl encodedUrl = QUrl(url);

    //qDebug() << "YMHttpClient::httpGetVariant" << encodedUrl;
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded"); //"application/json;charset=UTF-8");//
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

    if( 302 ==  reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() )
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
            return byteArray;//m_reqCode;
        }
    }
    else
    {
        onRequstTimerOut();
    }
    reply->deleteLater();
    httpAccessmanger->deleteLater();
    return byteArray;
}


QByteArray YMHttpClient::httpGetVariant(QString url, QString headToken, const QVariantMap &formData)
{
    //qDebug() << "YMHttpClient::httpGetVariant" << url << handler;
    QUrl encodedUrl = QUrl(url);

    //qDebug() << "YMHttpClient::httpGetVariant" << encodedUrl;
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(this);
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8"); //

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

    httpRequest.setRawHeader("X-AUTH-TOKEN", headToken.toLatin1());
    httpRequest.setRawHeader("Common-Params", common_Params.toLatin1());
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

    if( 302 ==  reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() )
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
            return byteArray;//m_reqCode;
        }
    }
    else
    {
        onRequstTimerOut();
    }
    reply->deleteLater();
    httpAccessmanger->deleteLater();
    return byteArray;
}

QByteArray YMHttpClient::httpGetIp(QString url)
{
    QUrl encodedUrl = QUrl(url);
    //qDebug() << "YMHttpClient::httpGetIp" << encodedUrl;
    //QNetworkAccessManager * netWorkMgr = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(url));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QEventLoop httploop;
    QNetworkReply * reply = m_networkMgrIp->get(QNetworkRequest(encodedUrl));
    connect(m_networkMgrIp, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray dataArray = reply->readAll();
    reply->deleteLater();
    return dataArray;
}


int YMHttpClient::httpPostForm(
    const QString & url,
    const QMap<QString, QString>& formData,
    YMHttpResponseHandler * handler)
{
    //qDebug() << "YMHttpClient::httpPostForm" << url << formData << handler;

    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QMap<QString, QString>::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toStdString().c_str());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QNetworkReply * reply = m_networkMgr->post(request, multiPart);
    multiPart->setParent(reply);
    YMHttpResponse * resp = new YMHttpResponse(reply, handler, ++m_reqCode);
    m_httpReqs.insert(reply, resp);

    return m_reqCode;
}

QByteArray YMHttpClient::httpPostVariantHanlder(const QString &url, const QVariantMap &formData)
{
    QNetworkAccessManager *networkMgr = new QNetworkAccessManager();

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");

    QVariantMap dataMap;
    for (QVariantMap::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        dataMap.insert(it.key(), it.value());
    }
    QJsonObject dataObj = QJsonDocument::fromVariant(dataMap).object();
    qDebug() << "==YMHttpClient::httpPostVariantHanlder==" << dataObj;
    QByteArray send_byteArray = QJsonDocument(dataObj).toJson();
    QEventLoop httploop;
    QNetworkReply * reply = networkMgr->post(request, send_byteArray);

    qDebug() << "===multiPart===";
//    multiPart->setParent(reply);
    QTimer::singleShot(16000, &httploop, SLOT(quit()));
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();

    QByteArray byteArray;
    if(m_timer->isActive())
    {
        m_timer->stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            byteArray = reply->readAll();
            reply->deleteLater();
            networkMgr->deleteLater();
            return byteArray;//m_reqCode;
        }
    }
    else
    {
        onRequstTimerOut();
        //qDebug() << "RequstTimerOut" << reply->error();
    }
    reply->deleteLater();
    networkMgr->deleteLater();
    return byteArray;
}

QByteArray YMHttpClient::httpPostForm(
    const QString & url,
    const QVariantMap &formData)
{
    //qDebug() << "YMHttpClient::httpPostForm" << url << formData;
    QNetworkAccessManager *networkMgr = new QNetworkAccessManager();
    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QVariantMap::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toByteArray());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QEventLoop httploop;
    QNetworkReply * reply = networkMgr->post(request, multiPart);
    multiPart->setParent(reply);
    QTimer::singleShot(16000, &httploop, SLOT(quit()));
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();

    QByteArray byteArray;
    if(m_timer->isActive())
    {
        m_timer->stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            byteArray = reply->readAll();
            reply->deleteLater();
            networkMgr->deleteLater();
            return byteArray;//m_reqCode;
        }
    }
    else
    {
        onRequstTimerOut();
        //qDebug() << "RequstTimerOut" << reply->error();
    }
    reply->deleteLater();
    networkMgr->deleteLater();
    return byteArray;

}

int YMHttpClient::httpPostVariant(
    const QString &url,
    const QVariantMap &formData,
    YMHttpResponseHandler *handler)
{
    //qDebug() << "YMHttpClient::httpPostVariant" << url << formData << handler;

    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QVariantMap::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toByteArray());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QNetworkReply * reply = m_networkMgr->post(request, multiPart);
    multiPart->setParent(reply);
    YMHttpResponse * resp = new YMHttpResponse(reply, handler, ++m_reqCode);
    m_httpReqs.insert(reply, resp);
    return m_reqCode;
}

int YMHttpClient::httpUploadFile(
    const QString &url,
    const QString &filename,
    const QString &remotePath,
    YMFileTransportEventHandler *handler)
{
    //qDebug() << "YMHttpClient::httpUploadFile" << url << filename << remotePath << handler;

    QHttpMultiPart * multipart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart part1;
    part1.setHeader(QNetworkRequest::ContentDispositionHeader, "application/x-www-form-urlencoded");
    part1.setBody(remotePath.toStdString().c_str());
    multipart->append(part1);
    QHttpPart part2;
    part2.setHeader(QNetworkRequest::ContentDispositionHeader, "application/x-www-form-urlencoded");
    part2.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("binary"));
    QFile * file = new QFile(filename);
    file->open(QIODevice::ReadOnly);
    part2.setBodyDevice(file);
    multipart->append(part2);
    file->setParent(multipart);

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QNetworkReply * reply = m_networkMgr->post(request, multipart);
    multipart->setParent(reply);

    YMFileTransportResponse * resp = new YMFileTransportResponse(reply, handler, ++m_reqCode);
    m_fileReqs.insert(reply, resp);

    connect(reply, SIGNAL(uploadProgress(qint64, qint64)), resp, SLOT( onUploadProgress(qint64, qint64 )));

    return m_reqCode;
}

QByteArray YMHttpClient::httpDownloadFile(
    const QString &url)
{
    //qDebug() << "YMHttpClient::httpDownloadFile";
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(url));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QEventLoop httploop;
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    QNetworkReply *httpReply;
    httpReply = m_networkMgr->get(httpRequest);

    httploop.exec();

    if( 302 == httpReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() )
    {
        disconnect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        QString tempUrl = httpReply->attribute(QNetworkRequest::RedirectionTargetAttribute).toString();
        httpRequest.setUrl(QUrl(tempUrl));
        httpReply = m_networkMgr->get(httpRequest);
        httploop.exec();
    }

    QByteArray readData = httpReply->readAll();
    return readData;
}

int YMHttpClient::ftpUploadFile(
    const QString &url,
    const QString &username,
    const QString &password,
    const QString &filename,
    YMFileTransportEventHandler *handler)
{
    //qDebug() << "YMHttpClient::ftpUploadFile" << url << username << password << filename;

    QUrl u(url.toStdString().c_str());
    u.setUserName(username);
    u.setPassword(password);
    u.setPort(21);

    QNetworkRequest request(u);

    QFile* file = new QFile(filename);
    if (file->open(QIODevice::ReadOnly))
    {
        QNetworkReply * reply = m_networkMgr->put(request, file);
        file->setParent(reply);
        YMFileTransportResponse * resp = new YMFileTransportResponse(reply, handler, ++m_reqCode);
        m_fileReqs.insert(reply, resp);

        qWarning() << "file" << file << "reply" << reply;

        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), resp, SLOT( onUploadProgress(qint64, qint64 )));
        return m_reqCode;
    }

    return 0;
}

void YMHttpClient::onNetworkStateChanged(QNetworkAccessManager::NetworkAccessibility accessible)
{
    //qDebug() << "YMHttpClient::onNetworkStateChanged" << accessible;
}

void YMHttpClient::onUploadProgress(qint64 /*bytesSent*/, qint64 /*bytesTotal*/)
{

}

void YMHttpClient::onDownloadProgress(qint64 /*bytesReceived*/, qint64 /*bytesTotal*/)
{

}

void YMHttpClient::onDownloadDataReady()
{
    //qDebug() << "YMHttpClient::onDownloadDataReady";
}

void YMHttpClient::onFinished(QNetworkReply * reply)
{
    //qDebug() << "YMHttpClient::onDownloadFinished";
    QMap<QNetworkReply *, YMHttpResponse *>::iterator it1 = m_httpReqs.find(reply);
    if (it1 != m_httpReqs.end())
    {
        disconnect(reply, 0, 0, 0);
        YMHttpResponse * resp = it1.value();
        resp->processResponse();
        delete resp;
        m_httpReqs.erase(it1);
        reply->deleteLater();
        return;
    }
    QMap<QNetworkReply *, YMFileTransportResponse *>::iterator it2 = m_fileReqs.find(reply);
    if (it2 != m_fileReqs.end())
    {
        disconnect(reply, 0, 0, 0);
        YMFileTransportResponse * resp = it2.value();
        resp->onFinished();
        delete resp;
        m_fileReqs.erase(it2);
        reply->deleteLater();
        return;
    }
}
//urlType为获取url的类型 获取 教研url 传0 其他url传 1
QString YMHttpClient::getRunUrl(int urlType)
{
    QString tempUrl = "api.yimifudao.com/v2.4";
    QString minClassUrl = "";
    QString minClassH5 = "";

    //=====================================
    //检查文件: Qtyer.dll, 是否存在
    //不存在的话, 提示文件不存在, 不是提示: 课件加载失败
    QString strDllFile = g_strAppFullPath;
    strDllFile = strDllFile.replace(g_strAppFileName, "Qtyer.dll"); //得到dll文件的绝对路径
    qDebug() << "YMHttpClient::getRunUrl" << qPrintable(strDllFile);

    QString strMsg = QString(u8"文件: %1, 不存在, 程序将退出." ) .arg(strDllFile);
    if(!QFile::exists(strDllFile))
    {
        QMessageBox::critical(NULL, MSG_BOX_TITLE, strMsg, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << "YMHttpClient::getRunUrl file not exist, file: " << qPrintable(strDllFile);
        exit(1);
    }

    //=====================================
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);

    // 环境类型  测试环境 0  正式环境 1 手动配置
    m_setting->beginGroup("EnvironmentType");

    int environmentType = m_setting->value("type").toInt();
    m_setting->endGroup();

    if(environmentType == 1) //正式环境
    {
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("formal").toString();//, "jyhd.yimifudao.com"
            m_setting->setValue("stage", "stage-jyhd.yimifudao.com");
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("formal").toString();//, "api.yimifudao.com/v2.4"
            m_setting->setValue("stage", "stage-api.yimifudao.com/v2.4");
            m_setting->endGroup();
        }
    }
    if(environmentType == 0) //
    {
        YMUserBaseInformation::isStageEnvironment = true;
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("stage").toString();//, "jyhd.yimifudao.com"
            //m_setting->setValue("stage", "stage-jyhd.yimifudao.com");
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("stage").toString();//, "api.yimifudao.com/v2.4"
            // m_setting->setValue("stage", "stage-api.yimifudao.com/v2.4");
            m_setting->endGroup();
        }
    }
    m_setting->beginGroup("MiniClass");
    YMUserBaseInformation::m_minClassUrl = m_setting->value("miniUrl").toString();
    YMUserBaseInformation::m_minClassH5 = m_setting->value("miniH5").toString();
    m_setting->endGroup();
    qDebug() << "==YMUserBaseInformation::m_minClassUrl==111111" << YMUserBaseInformation::m_minClassUrl << YMUserBaseInformation::m_minClassH5;

    QString strStage = ""; //生产环境, 这边默认是空
    if(tempUrl.contains("pre-"))
    {
        strStage = "pre";
    }
    if(tempUrl.contains("stage-"))
    {
        strStage = "stage";
    }
    if(tempUrl.contains("dev-"))
    {
        strStage = "dev";
    }
    if(environmentType == 0)
    {
       QStringList tempList = tempUrl.split("-");
       strStage = tempList.at(0);
       strStage = strStage.replace("-","");
    }
    m_netType = environmentType;
    m_stage = strStage;
    if(tempUrl == "")
    {
        tempUrl = "api.yimifudao.com/v2.4";
    }

    return tempUrl;
}

void YMHttpClient::updateNetType(int netType, QString stage)
{
    QString strDllFile = g_strAppFullPath;
    strDllFile = strDllFile.replace(g_strAppFileName, "Qtyer.dll"); //得到dll文件的绝对路径
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);
    qDebug() << "==YMHttpClient::updateNetType==" << netType << stage;
    if(netType == 0)
    {
        m_setting->setValue("EnvironmentType/type", netType);
        m_setting->setValue("V2.4/stage", stage + "-api.yimifudao.com/v2.4");
        m_setting->setValue("Study/stage", stage + "-jyhd.yimifudao.com");
        m_setting->setValue("MiniClass/miniUrl", "http://" + stage + "-platform.yimifudao.com/v1.0.0");
        m_setting->setValue("MiniClass/miniH5", "http://" + stage + "-h5.yimifudao.com/classAssignment");
    }
    if(netType == 1)
    {
        m_setting->setValue("EnvironmentType/type", netType);
        m_setting->setValue("V2.4/formal", "api.yimifudao.com/v2.4");
        m_setting->setValue("Study/formal", "jyhd.yimifudao.com");
        m_setting->setValue("MiniClass/miniUrl", "http://platform.yimifudao.com/v1.0.0");
        m_setting->setValue("MiniClass/miniH5", "http://h5.yimifudao.com/classAssignment");
    }
    m_setting->deleteLater();

    QProcess p;
    QString c = "taskkill /im classroom.exe /f";
    p.execute(c);
    p.close();

    c = "taskkill /im CourwarePreviewer.exe /f";
    p.execute(c);
    p.close();

    c = "taskkill /im player.exe /f";
    p.execute(c);
    p.close();

    c = "taskkill /im attendclassroom.exe /f";
    p.execute(c);
    p.close();

    QMessageBox::information(NULL, MSG_BOX_TITLE, QStringLiteral("配置成功, 程序将自动重启."), QMessageBox::Ok, QMessageBox::Ok);

    //参考链接: https://www.cnblogs.com/pyw0818/p/8048046.html
    qApp->exit(g_ReturnCode_Restart);
//    exit(1);
}
