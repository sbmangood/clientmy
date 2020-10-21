#ifndef YMHTTPRESPONSE_H
#define YMHTTPRESPONSE_H

#include <QObject>
#include <QNetworkReply>
#include "YMHttpResponseHandler.h"

class YMHttpResponse : public QObject
{
        Q_OBJECT
    public:
        YMHttpResponse(QObject *parent = 0);
        YMHttpResponse(QNetworkReply * reply, YMHttpResponseHandler * handler, int code, QObject *parent = 0);

        QNetworkReply * m_reply;
        YMHttpResponseHandler * m_handler;
        QString m_data;
        QByteArray m_byte;
        int m_reqCode;

        void processResponse();

    public slots:

        void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
        void onDownloadDataReady();
        void onReplyError(QNetworkReply::NetworkError);
        void onReplyFinished();
};

#endif // YMHTTPRESPONSE_H
