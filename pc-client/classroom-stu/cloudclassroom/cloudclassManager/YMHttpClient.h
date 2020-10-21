#ifndef YMHTTPCLIENT_H
#define YMHTTPCLIENT_H

#include <QObject>
#include <QList>
#include <QMap>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class YMHttpClient : public QObject
{
        Q_OBJECT
    public:
        explicit YMHttpClient(QObject *parent = 0);

        static YMHttpClient * defaultInstance();

        QByteArray httpGetVariant(QString url);

        QByteArray httpGetIp(QString url);

        QByteArray httpPostForm(
            const QString& url,
            const QVariantMap& formData);


        QByteArray httpDownloadFile(
            const QString& url);

        int getCurrentReplyCode();//获取当前http请求的返回值

    signals:
        void onRequstTimerOut();

    public:
        QString httpUrl;
        QTimer * m_timer;
        int m_currentReplyCode = 200;//当前请求的返回值code
    private:
        QNetworkAccessManager * m_networkMgr;
        int m_reqCode;

};

#endif // YMHTTPCLIENT_H
