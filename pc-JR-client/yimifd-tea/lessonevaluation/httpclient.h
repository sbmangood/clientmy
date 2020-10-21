#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H

#include <QObject>
#include <QList>
#include <QMap>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>

class HttpClient : public QObject
{
    Q_OBJECT
public:
    explicit HttpClient();
    ~HttpClient();

    QJsonObject syncRequestMsg(QString url, const QString &msg, const QString &token, int timeOut = 2000);
    int asynRequestMsg(QString url, const QString &msg, const QString &token);
    QByteArray httpGetIp(QString url);

signals:
    void sigHttpReply(QJsonObject jsonObj);

public slots:
    //http 请求超时处理
    void onTimeOut();
    void onHttpReply(QNetworkReply *reply);

private:

    QTimer * m_timer;
    QNetworkAccessManager * m_networkMgr;

};

#endif // HTTPCLIENT_H
