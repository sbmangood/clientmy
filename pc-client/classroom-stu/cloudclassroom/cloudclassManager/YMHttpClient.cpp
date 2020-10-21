#include "YMHttpClient.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include "YMUserBaseInformation.h"
#include "./dataconfig/datahandl/datamodel.h"

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
                //m_httpClient->httpUrl = "https://api.1mifd.com/v2.4";
                YMUserBaseInformation::token = StudentData::gestance()->m_token;
                YMUserBaseInformation::apiVersion = StudentData::gestance()->m_apiVersion;
                YMUserBaseInformation::appVersion = StudentData::gestance()->m_appVersion;
                //qDebug() << "===YMHttpClient===" << YMUserBaseInformation::token << YMUserBaseInformation::apiVersion << YMUserBaseInformation::appVersion;
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
    //connect(m_networkMgr, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinished(QNetworkReply*)));
    m_timer = new QTimer();
    m_timer->setInterval(15000);
    m_timer->setSingleShot(true);
}

YMHttpClient * YMHttpClient::defaultInstance()
{
    return g_httpClientFactory.getHttpClient();
}

int YMHttpClient::getCurrentReplyCode()
{
    return m_currentReplyCode;
}

QByteArray YMHttpClient::httpGetVariant(
    QString url)
{
    //qDebug() << "YMHttpClient::httpGetVariant" << url << handler;
    QUrl encodedUrl = QUrl(url);

    //qDebug() << "YMHttpClient::httpGetVariant" << encodedUrl;
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
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
    QNetworkAccessManager * netWorkMgr = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QEventLoop httploop;
    QNetworkReply * reply = netWorkMgr->get(QNetworkRequest(encodedUrl));
    connect(reply, SIGNAL(finished()), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray dataArray = reply->readAll();
    reply->deleteLater();
    netWorkMgr->deleteLater();
    return dataArray;
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
    qDebug() << "QNetworkReply * reply = networ" << multiPart;
    multiPart->setParent(reply);
    QTimer::singleShot(16000, &httploop, SLOT(quit()));
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();
    m_currentReplyCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
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
    QByteArray readData = httpReply->readAll();
    return readData;
}


