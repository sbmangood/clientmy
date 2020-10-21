#ifndef YMFILETRANSPORTEVENTHANDLER_H
#define YMFILETRANSPORTEVENTHANDLER_H

#include "QObject"
class QNetworkReply;

class YMFileTransportEventHandler
{
    public:
        virtual void onUploadProgress(int reqCode, qint64 bytesSent, qint64 bytesTotal) = 0;
        virtual void onDownloadProgress(int reqCode, qint64 bytesReceived, qint64 bytesTotal) = 0;
        virtual void onDownloadDataReady(int reqCode, QNetworkReply * reply) = 0;
        virtual void onFinished(int reqCode, QNetworkReply * reply) = 0;
};

#endif // YMFILETRANSPORTEVENTHANDLER_H
