#ifndef YMHTTPCLIENTUTILS_H
#define YMHTTPCLIENTUTILS_H
#include <QObject>
#include <QImage>
#include <QList>
#include <QSettings>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QEventLoop>
#include <QTimer>
#include <QMap>

// Http请求处理类
class YMHttpClientUtils: public QObject
{
    Q_OBJECT
public:
    explicit YMHttpClientUtils();
    virtual ~YMHttpClientUtils();

    static  YMHttpClientUtils *getInstance();

signals:
    void onRequstTimerOut();

public:
    QString m_currentEnvironmentType;
    QString getRunUrl(int urlType);
    QString getCurrentEnvironmentType();
    QByteArray httpPostForm(const QString & url, const QVariantMap &formData);
    static YMHttpClientUtils *m_YMHttpClientUtils;
};

#endif // YMHTTPCLIENTUTILS_H
