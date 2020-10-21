#include "httpclient.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include "datamodel.h"
#include "messagetype.h"
#include "controlcenter.h"

HttpClient::HttpClient(QString httpIp, int httpPort)
    : QObject(nullptr)
{
    m_httpIp = httpIp;
    m_httpPort = httpPort;
    m_networkMgr = new QNetworkAccessManager(this);
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

int HttpClient::asynRequestMsg(QString url, const QString & msg, int timeOut)
{
    QNetworkRequest netRequest;
    QString qsUrl = QString("http://") + m_httpIp + url;
    QUrl qurl(qsUrl);
    qurl.setPort(m_httpPort);
    netRequest.setUrl(qurl);

    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    netRequest.setRawHeader("TOKEN", StudentData::gestance()->m_token.toUtf8());

    QNetworkReply *netReply;
    netReply = m_networkMgr->post(netRequest, msg.toUtf8());
    qDebug() << "HttpClient asynRequestMsg" << qsUrl <<  m_httpPort << msg;
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(onHttpReply(QNetworkReply*)));

//    m_timer->setInterval(timeOut);
//    m_timer->setSingleShot(true);
//    connect(m_timer, SIGNAL(timeout()), this, SLOT(onTimeOut()));
    return 0;
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

        if(jsonObj.contains(kSocketCmd))
        {
            QString command =  jsonObj[kSocketCmd].toString();
            ControlCenter::getInstance()->processHttpMsg(command, jsonObj);
        }
        else
        {
            qWarning()<< "jsonMsg is not contain command!, recv message is failed" << jsonObj;
        }
    }
    else
    {
        qWarning()<< "http reply is null!";
    }


}
