#include "YMHttpResponse.h"

YMHttpResponse::YMHttpResponse(QObject *parent) : QObject(parent)
{

}

YMHttpResponse::YMHttpResponse(QNetworkReply *reply, YMHttpResponseHandler *handler, int code, QObject *parent)
    : QObject(parent)
    , m_reply(reply)
    , m_handler(handler)
    , m_reqCode(code)
{

}

void YMHttpResponse::processResponse()
{
    if (m_reply->error() == QNetworkReply::NoError)
    {
        m_data = m_reply->readAll();
        if (m_handler)
        {
            m_handler->onResponse(m_reqCode, m_data);
        }
    }
    else
    {
        //qDebug() << "YMHttpResponse::processResponse" << "error" << m_reply->errorString();
        if (m_handler)
        {
            m_handler->onResponse(m_reqCode, "");
        }
    }
}

void YMHttpResponse::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    //qDebug() << "YMHttpResponse::onDownloadProgress" << bytesReceived << bytesTotal;
}

void YMHttpResponse::onDownloadDataReady()
{
    //qDebug() << "YMHttpResponse::onDownloadDataReady";
    //m_data += QString(m_reply->readAll());
}

void YMHttpResponse::onReplyFinished()
{
    //qDebug() << "YMHttpResponse::onReplyFinished";
}

void YMHttpResponse::onReplyError(QNetworkReply::NetworkError errCode)
{
    //qDebug() << "YMHttpResponse::onReplyError" << errCode;
}
