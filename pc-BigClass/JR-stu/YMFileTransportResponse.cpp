#include "YMFileTransportResponse.h"


YMFileTransportResponse::YMFileTransportResponse(QObject *parent /*= 0*/)
    : QObject(parent)
{

}

YMFileTransportResponse::YMFileTransportResponse(QNetworkReply *reply,
        YMFileTransportEventHandler *handler,
        int reqCode,
        QObject *parent)
    : QObject(parent)
    , m_reply(reply)
    , m_handler(handler)
    , m_reqCode(reqCode)
{

}

YMFileTransportResponse::~YMFileTransportResponse()
{

}

void YMFileTransportResponse::onFinished()
{
    if (m_handler)
    {
        m_handler->onFinished(m_reqCode, m_reply);
    }
}

void YMFileTransportResponse::onUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    if (m_handler)
    {
        m_handler->onUploadProgress(m_reqCode, bytesSent, bytesTotal);
    }
    qWarning() << "YMFileTransportResponse::onUploadProgress" << bytesSent << bytesTotal;
}

void YMFileTransportResponse::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    if (m_handler)
    {
        m_handler->onDownloadProgress(m_reqCode, bytesReceived, bytesTotal);
    }
}

void YMFileTransportResponse::onDownloadDataReady()
{
    if (m_handler)
    {
        m_handler->onDownloadDataReady(m_reqCode, m_reply);
    }
}






