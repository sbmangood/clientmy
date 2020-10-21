#include "YMHttpClient.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include "./dataconfig/datahandl/datamodel.h"

#define MSG_BOX_TITLE  QString(u8"溢米辅导")

class YMHttpClientFactory
{
    public:
        YMHttpClientFactory()
            : m_httpClient(0)
        {

        }

        ~YMHttpClientFactory()
        {
            if (m_httpClient)
            {
                delete m_httpClient;
            }
        }

        YMHttpClient * getHttpClient()
        {
            if (!m_httpClient)
            {
                m_httpClient = new YMHttpClient();
                m_httpClient->httpUrl = m_httpClient->getRunUrl(1);// "stage-api.yimifudao.com/v2.4";
                // qDebug() << "===YMHttpClient==="<< m_httpClient->httpUrl<< YMUserBaseInformation::token << YMUserBaseInformation::apiVersion << YMUserBaseInformation::appVersion;
            }
            return m_httpClient;
        }

        YMHttpClient * m_httpClient;
};

YMHttpClientFactory g_httpClientFactory;

YMHttpClient::YMHttpClient(QObject *parent)
    : QObject(parent)
{
    //当前的开发环境, 默认值为生产环境
    m_enEnvironment = ENVIRONMENT_API;

    m_reqCode = 0;
    m_networkMgr = new QNetworkAccessManager(this);
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinished(QNetworkReply*)));
    m_timer = new QTimer();
    m_timer->setInterval(15000);
    m_timer->setSingleShot(true);
}

YMHttpClient * YMHttpClient::defaultInstance()
{
    return g_httpClientFactory.getHttpClient();
}

//得到当前环境的类型
enumEnvironment YMHttpClient::getCurrentEnvironmentType()
{
    return m_enEnvironment;
}

//urlType为获取url的类型 获取 教研url 传0 其他url传 1
QString YMHttpClient::getRunUrl(int urlType)
{
    QString tempUrl = "api.yimifudao.com/v2.4";

    //=====================================
    //控制读取配置文件: Qtyer.dll的次数(不需要每次都读), urlType = 0, urlType = 1的时候, 各读一次, 就可以了
    static QString strTempUrl_0 = ""; //urlType为0的时候
    static QString strTempUrl_1 = ""; //urlType为1的时候
//    qDebug() << "YMHttpClient::getRunUrl length: " << strTempUrl_0.length() << strTempUrl_1.length();

    if(urlType == 0 && strTempUrl_0.length() > 0)
    {
        return strTempUrl_0;
    }
    else if(urlType == 1 && strTempUrl_1.length() > 0)
    {
        return strTempUrl_1;
    }
    //如果都不是以上的两种if情况, 则继续读取配置文件

    //=====================================
    //检查文件: Qtyer.dll, 是否存在
    //不存在的话, 提示文件不存在, 不是提示: 课件加载失败
    QString strDllFile = StudentData::gestance()->strAppFullPath;
    strDllFile = strDllFile.replace(StudentData::gestance()->strAppName, "Qtyer.dll"); //得到dll文件的绝对路径
    qDebug() << "YMHttpClient::getRunUrl" << qPrintable(strDllFile);

    QString strMsg = QString(u8"文件: %1, 不存在, 程序将退出." ) .arg(strDllFile);
    if(!QFile::exists(strDllFile))
    {
        QMessageBox::critical(NULL, MSG_BOX_TITLE, strMsg, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << "YMHttpClient::getRunUrl file not exist, file: " << qPrintable(strDllFile);
        exit(1);
    }

    //=====================================
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);

    // 环境类型  测试环境:0  正式环境:1 手动配置
    m_setting->beginGroup("EnvironmentType");
    int environmentType = m_setting->value("type").toInt();
    m_setting->endGroup();

    //====================
    //正式环境
    if(environmentType == 1)
    {
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("formal").toString();
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("formal").toString();
            m_setting->endGroup();
        }
    }
    //====================
    //测试环境
    else if(environmentType == 0)
    {
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("stage").toString();
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("stage").toString();
            m_setting->endGroup();
        }
    }

    //=====================================
    if(tempUrl == "")
    {
        tempUrl = "api.yimifudao.com/v2.4";
    }

    //=====================================
    //设置当前的开发环境
    if(tempUrl.contains("pre-"))
    {
        m_enEnvironment = ENVIRONMENT_PRE;
        answerUrl = "pre-htimg.yimifudao.com";
    }
    else if(tempUrl.contains("stage-"))
    {
        m_enEnvironment = ENVIRONMENT_STAGE;
        answerUrl = "stage-htimg.yimifudao.com";
    }
    else if(tempUrl.contains("dev-"))
    {
        m_enEnvironment = ENVIRONMENT_DEV;
        answerUrl = "dev-htimg.yimifudao.com";
    }else if(tempUrl.contains("stage3-"))
    {
        answerUrl = "stage3-htimg.yimifudao.com";
    }else if(tempUrl.contains("stage2-"))
    {
        answerUrl = "stage2-htimg.yimifudao.com";
    }
    else
    {
        m_enEnvironment = ENVIRONMENT_API;
        answerUrl  = "htimg.yimifudao.com";
    }


    //=====================================
    //记录tempUrl信息, 为了控制读取配置文件: Qtyer.dll的次数
    if(urlType == 0 && strTempUrl_0.length() <= 0)
    {
        strTempUrl_0 = tempUrl;
    }
    else if(urlType == 1 && strTempUrl_1.length() <= 0)
    {
        strTempUrl_1 = tempUrl;
    }

    qDebug() << "YMHttpClient::getRunUrl: " << tempUrl;
    return tempUrl;
}

QByteArray YMHttpClient::httpGetVariant(
    QString url)
{
    //qDebug() << "YMHttpClient::httpGetVariant" << url << handler;
    QUrl encodedUrl = QUrl(url);

    //qDebug() << "YMHttpClient::httpGetVariant" << encodedUrl;
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    QEventLoop httploop;
    QNetworkReply * reply = httpAccessmanger->get(httpRequest);
    connect(reply, SIGNAL(finished()), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();
    QByteArray byteArray;
    if(m_timer->isActive())
    {
        m_timer->stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            byteArray = reply->readAll();
            reply->deleteLater();
            httpAccessmanger->deleteLater();
            return byteArray;//m_reqCode;
        }
    }
    else
    {
        onRequstTimerOut();
    }
    reply->deleteLater();
    httpAccessmanger->deleteLater();
    return byteArray;
}

QByteArray YMHttpClient::httpGetIp(QString url)
{
    QUrl encodedUrl = QUrl(url);
    //qDebug() << "YMHttpClient::httpGetIp" << encodedUrl;
    QNetworkAccessManager * netWorkMgr = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QEventLoop httploop;
    QNetworkReply * reply = netWorkMgr->get(QNetworkRequest(encodedUrl));
    connect(reply, SIGNAL(finished()), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray dataArray = reply->readAll();
    reply->deleteLater();
    netWorkMgr->deleteLater();
    return dataArray;
}

QByteArray YMHttpClient::httpPostForm(
    const QString & url,
    const QVariantMap &formData)
{
    //qDebug() << "YMHttpClient::httpPostForm" << url << formData;
    QNetworkAccessManager *networkMgr = new QNetworkAccessManager();
    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QVariantMap::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toByteArray());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QEventLoop httploop;
    QNetworkReply * reply = networkMgr->post(request, multiPart);
    multiPart->setParent(reply);
    QTimer::singleShot(16000, &httploop, SLOT(quit()));
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();

    QByteArray byteArray;
    if(m_timer->isActive())
    {
        m_timer->stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            byteArray = reply->readAll();
            reply->deleteLater();
            networkMgr->deleteLater();
            return byteArray;//m_reqCode;
        }
    }
    else
    {
        onRequstTimerOut();
        //qDebug() << "RequstTimerOut" << reply->error();
    }
    reply->deleteLater();
    networkMgr->deleteLater();
    return byteArray;

}

QByteArray YMHttpClient::httpDownloadFile(
    const QString &url)
{
    //qDebug() << "YMHttpClient::httpDownloadFile";
    QNetworkRequest httpRequest;
    QSslConfiguration conf = httpRequest.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    httpRequest.setSslConfiguration(conf);
    httpRequest.setUrl(QUrl(url));
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QEventLoop httploop;
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    QNetworkReply *httpReply;
    httpReply = m_networkMgr->get(httpRequest);

    httploop.exec();
    QByteArray readData = httpReply->readAll();
    return readData;
}


