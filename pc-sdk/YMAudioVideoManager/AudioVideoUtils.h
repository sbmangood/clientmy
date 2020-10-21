#ifndef AUDIOVIDEOUTILS_H
#define AUDIOVIDEOUTILS_H
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

// 环境类型
enum ENVIRONMENT_TYPE
{
    API = 0,// 线上环境
    SIT01 = 1,// sit01环境
    SIT02 = 2,// sit02环境
    SIT03 = 3,// sit03环境
    SIT04 = 4,// sit04环境
    ENVIRONMENT_DEFAULT = API
};

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
    QString getRunUrl(ENVIRONMENT_TYPE enType);
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
    bool beautyIsOn = false;// 美颜是否开启
    QList<QImage> hasBeautyImageList;// 存储被美颜过的图像
};

#endif // AUDIOVIDEOUTILS_H
