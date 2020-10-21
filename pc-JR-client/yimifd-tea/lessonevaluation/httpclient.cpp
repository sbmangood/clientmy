#include "httpclient.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>

HttpClient::HttpClient()
    : QObject(nullptr)
{
    m_networkMgr = new QNetworkAccessManager();
    m_timer = new QTimer();
}

HttpClient::~HttpClient()
{
    if(nullptr != m_timer)
    {
        if(m_timer->isActive())
            m_timer->stop();

        delete m_timer;
        m_timer = nullptr;
    }

    if(nullptr != m_networkMgr)
    {
        delete m_networkMgr;
        m_networkMgr = nullptr;
    }
}

QJsonObject HttpClient::syncRequestMsg(QString url, const QString &msg, const QString &token, int timeOut)
{
    QUrl qurl(url);
    QNetworkRequest netRequest;
    netRequest.setUrl(qurl);
    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    if(!token.isEmpty())
    {
        netRequest.setRawHeader("yihuiyun-xbk-token", token.toUtf8());
    }

    QEventLoop httploop;
    QNetworkReply *netReply;
    netReply = m_networkMgr->post(netRequest, msg.toUtf8());
    qDebug() << "sync request msg" << qurl << token.toUtf8() << msg;

    m_timer->setInterval(timeOut);
    m_timer->setSingleShot(true);
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    connect(netReply, SIGNAL(finished()), &httploop, SLOT(quit()));
    m_timer->start();
    httploop.exec();

    int statusCode = netReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if( 200 !=  statusCode)
    {
        qDebug()<< "sync request http status code is" << statusCode;
        if(nullptr != m_timer)
        {
            if(m_timer->isActive())
                m_timer->stop();
        }
        return QJsonObject();
    }

    QByteArray replyData = netReply->readAll();
    QJsonObject jsonObj = QJsonDocument::fromJson(replyData).object();
    qDebug()<< "sync request msg recv" <<jsonObj;
    return jsonObj;
}

int HttpClient::asynRequestMsg(QString url, const QString & msg, const QString &token)
{
    QUrl qurl(url);
    QNetworkRequest netRequest;
    netRequest.setUrl(qurl);
    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    netRequest.setRawHeader("TOKEN", token.toUtf8());

    QNetworkReply *netReply;
    netReply = m_networkMgr->post(netRequest, msg.toUtf8());
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(onHttpReply(QNetworkReply*)));
    qDebug() << "asyn request msg" << qurl << msg;

    return 0;
}

QByteArray HttpClient::httpGetIp(QString url)
{
    QUrl encodedUrl = QUrl(url);

    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(url));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QEventLoop httploop;
    QNetworkReply * reply = m_networkMgr->get(QNetworkRequest(encodedUrl));
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray dataArray = reply->readAll();
    reply->deleteLater();
    return dataArray;
}

void HttpClient::onTimeOut()
{

}

void HttpClient::onHttpReply(QNetworkReply *reply)
{
    if(nullptr != reply)
    {
        QByteArray replyData = reply->readAll();
        QJsonObject jsonObj = QJsonDocument::fromJson(replyData).object();
        qDebug()<< "asyn request msg recv" <<jsonObj;
        emit sigHttpReply(jsonObj);
    }
    else
    {
        qWarning()<< "http reply is null!";
    }


}
