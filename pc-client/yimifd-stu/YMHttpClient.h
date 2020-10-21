#ifndef YMHTTPCLIENT_H
#define YMHTTPCLIENT_H

#include <QObject>
#include <QList>
#include <QMap>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "YMHttpResponse.h"
#include "YMFileTransportEventHandler.h"
#include "YMHttpResponseHandler.h"
#include<QSettings>
/*
*http请求类
*/

class YMHttpResponse;
class YMFileTransportResponse;

class YMHttpClient : public QObject
{
        Q_OBJECT
    public:
        explicit YMHttpClient(QObject *parent = 0);

        static YMHttpClient * defaultInstance();

        int httpGet(
            QString url,
            const QMap<QString, QString>& reqParam,
            YMHttpResponseHandler * handler);

        QByteArray httpGetIp(QString url);


        QByteArray httpGetVariant(
            QString url,
            YMHttpResponseHandler *handler);

        QByteArray httpGetVariant(QString url,const QVariantMap &formData);

        int httpPostForm(
            const QString& url,
            const QMap<QString, QString>& formData,
            YMHttpResponseHandler * handler);

        QByteArray httpPostForm(
            const QString &url,
            const QVariantMap &formData);

        int httpPostVariant(
            const QString& url,
            const QVariantMap& formData,
            YMHttpResponseHandler * handler);

        QByteArray httpPostVariant(
            const QString &url,
            const QVariantMap &formData);

        int httpUploadFile(
            const QString& url,
            const QString& filename,
            const QString& remotePath,
            YMFileTransportEventHandler * handler);

        int httpDownloadFile(
            const QString& url,
            YMFileTransportEventHandler * handler);

        QByteArray httpDownloadFile(
            const QString& url);

        int ftpUploadFile(
            const QString& url,
            const QString& username,
            const QString& password,
            const QString& filename,
            YMFileTransportEventHandler * handler);

        void updateNetType(int netType, QString stage); //修改配置文件内容

    public slots:
        void onNetworkStateChanged(QNetworkAccessManager::NetworkAccessibility accessible);
        void onUploadProgress(qint64 bytesReceived, qint64 bytesTotal);
        void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
        void onDownloadDataReady();
        void onFinished(QNetworkReply *);
        //urlType 教研url 0 其他url 1
        QString getRunUrl(int urlType);

    signals:
        void onTimerOut();

    public:
        QString httpUrl;
        QTimer * m_timer;
        int m_netType;//网络状态 0 预发布 1线上
        QString m_stage;//网络环境

    private:
        QNetworkAccessManager * m_networkMgr;
        int m_reqCode;
        QMap<QNetworkReply *, YMHttpResponse *> m_httpReqs;
        QMap<QNetworkReply *, YMFileTransportResponse *> m_fileReqs;
};

#endif // YMHTTPCLIENT_H
