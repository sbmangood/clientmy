#ifndef YMHTTPCLIENT_H
#define YMHTTPCLIENT_H

#include <QObject>
#include <QList>
#include <QMap>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>

//用当前的环境的枚举类型
enum enumEnvironment
{
    ENVIRONMENT_API = 1,
    ENVIRONMENT_STAGE = 2,
    ENVIRONMENT_PRE = 3,
    ENVIRONMENT_DEV = 4,

    ENVIRONMENT_MAX = 100,
};

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

        QString getRunUrl(int urlType);

        //得到当前环境的类型
        enumEnvironment getCurrentEnvironmentType();

        int getCurrentReplyCode();//获取当前http请求的返回值
    signals:
        void onRequstTimerOut();

    public:
        QString httpUrl;
        QTimer * m_timer;        
        QString answerUrl;

        int m_currentReplyCode = 200;//当前请求的返回值code

    private:
        QNetworkAccessManager * m_networkMgr;
        int m_reqCode;
        enumEnvironment m_enEnvironment;

};

#endif // YMHTTPCLIENT_H
