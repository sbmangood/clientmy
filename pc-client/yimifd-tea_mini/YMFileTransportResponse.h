#ifndef YMFILETRANSPORTRESPONSE_H
#define YMFILETRANSPORTRESPONSE_H

#include <QObject>
#include <QNetworkReply>
#include "YMFileTransportEventHandler.h"

class YMFileTransportResponse : public QObject
{
        Q_OBJECT
    public:
        YMFileTransportResponse(QObject * parent = 0);
        YMFileTransportResponse(QNetworkReply * reply, YMFileTransportEventHandler * handler, int reqCode, QObject *parent = 0);
        ~YMFileTransportResponse();

        QNetworkReply * m_reply;
        YMFileTransportEventHandler * m_handler;
        int m_reqCode;

        void onFinished();

    public slots:
        void onUploadProgress(qint64 bytesReceived, qint64 bytesTotal);
        void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
        void onDownloadDataReady();
};

#endif // YMFILETRANSPORTRESPONSE_H
