#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H

#include <QObject>
#include <QList>
#include <QMap>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class HttpClient : public QObject
{
    Q_OBJECT
public:
    explicit HttpClient(QString httpIp, int httpPort);
    ~HttpClient();

    int asynRequestMsg(QString url, const QString & msg, int timeOut = 2000);

public slots:
    //http 请求超时处理
    void onTimeOut();
    void onHttpReply(QNetworkReply *reply);

private:
    QString m_httpIp;
    int m_httpPort;

    QTimer * m_timer;
    QNetworkAccessManager * m_networkMgr;

};

#endif // HTTPCLIENT_H
