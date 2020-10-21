#ifndef BEAUTYLIST_H
#define BEAUTYLIST_H
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
    explicit YMHttpClientUtils(){}
    virtual ~YMHttpClientUtils(){}

    static  YMHttpClientUtils *getInstance()
    {
        static YMHttpClientUtils *m_YMHttpClientUtils = new YMHttpClientUtils();
        return m_YMHttpClientUtils;
    }

signals:
    void onRequstTimerOut();

public:
    QString m_currentEnvironmentType;
    QString getRunUrl(int urlType, QString strDllFile, QString strAppName);
    QString getCurrentEnvironmentType();
    QByteArray httpPostForm(const QString & url, const QVariantMap &formData);
};


// 美颜图片存储类
class BeautyList
{
public:
    BeautyList() {}
    static BeautyList* getInstance()
    {
        static BeautyList * m_beautyList = new BeautyList();
        return m_beautyList;
    }
    bool beautyIsOn = true;// 美颜是否开启
    QList<QImage> hasBeautyImageList;// 存储被美颜过的图像
};

#endif // BEAUTYLIST_H
