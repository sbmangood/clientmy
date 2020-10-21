﻿#include "YMHttpClient.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include "YMUserBaseInformation.h"
#include <QSettings>
#include <QMessageBox>
//#include "./dataconfig/datahandl/datamodel.h"
#include "imageprovider.h"

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
                qDebug() << "===YMHttpClient::getHttpClient()===" << m_httpClient->httpUrl << YMUserBaseInformation::token << YMUserBaseInformation::apiVersion << YMUserBaseInformation::appVersion;
            }
            return m_httpClient;
        }

        YMHttpClient * m_httpClient;
};

YMHttpClientFactory g_httpClientFactory;

YMHttpClient::YMHttpClient(QObject *parent)
    : QObject(parent)
{
    m_reqCode = 0;
    m_networkMgr = new QNetworkAccessManager(this);
    //connect(m_networkMgr, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinished(QNetworkReply*)));
    m_timer = new QTimer();
    m_timer->setInterval(15000);
    m_timer->setSingleShot(true);
}

YMHttpClient * YMHttpClient::defaultInstance()
{
    return g_httpClientFactory.getHttpClient();
}

//urlType为获取url的类型 获取 教研url 传0 其他url传 1
QString YMHttpClient::getRunUrl(int urlType)
{
    //qDebug() << "========YMHttpClient::getRunUrl===========" << urlType;
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
    qDebug() << "YMHttpClient getRunUrl" << qPrintable(strDllFile);

    QString strMsg = QString(u8"文件: %1, 不存在, 程序将退出." ) .arg(strDllFile);
    if(!QFile::exists(strDllFile))
    {
        QMessageBox::critical(NULL, MSG_BOX_TITLE, strMsg, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << "YMHttpClient getRunUrl file not exist, file: " << qPrintable(strDllFile);
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
            tempUrl =  m_setting->value("formal").toString();//, "jyhd.yimifudao.com"
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("formal").toString();//, "api.yimifudao.com/v2.4"
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
            tempUrl =  m_setting->value("stage").toString();//, "jyhd.yimifudao.com"
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("stage").toString();//, "api.yimifudao.com/v2.4"
            m_setting->endGroup();
        }
    }

    //=====================================
    if(tempUrl == "")
    {
        tempUrl = "api.yimifudao.com/v2.4";
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
    m_setting->beginGroup("MiniClass");
    YMUserBaseInformation::miniUrl = m_setting->value("miniUrl").toString();
    YMUserBaseInformation::miniH5 = m_setting->value("miniH5").toString();
    m_setting->endGroup();

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

QByteArray YMHttpClient::httpGetVariant(QString url,const QVariantMap &formData)
{
    //qDebug() << "YMHttpClient::httpGetVariant" << url << handler;
    QUrl encodedUrl = QUrl(url);
    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager();
    QNetworkRequest httpRequest;
    httpRequest.setUrl(encodedUrl);
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader,"application/json;charset=UTF-8");//

    QString common_Params;
    int make = 0;
    for (QVariantMap::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        make++;
        if(make == formData.count())
        {
            common_Params.append( it.key() + "=" + it.value().toString());
        }
        else
        {
            common_Params.append(it.key() + "=" + it.value().toString() + "&");
        }
    }

    httpRequest.setRawHeader("X-AUTH-TOKEN",YMUserBaseInformation::token.toLatin1());
   //httpRequest.setRawHeader("X-AUTH-TOKEN","yimi_250219669883981824_yxt666_nfnyhZ_1543305533892");
    httpRequest.setRawHeader("Common-Params",common_Params.toLatin1());
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

    if( 302 ==  reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() )
    {
        disconnect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        QString tempUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toString();
        httpRequest.setUrl(QUrl(tempUrl));
        reply = httpAccessmanger->get(httpRequest);
        httploop.exec();
    }

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
    reply->deleteLater();
    httpAccessmanger->deleteLater();
    return byteArray;
}

QByteArray YMHttpClient::httpPostMsg(QString url, QString headToken, const QString &formData)
{

    QNetworkAccessManager *httpAccessmanger = new QNetworkAccessManager(this);
    QUrl qurl(url);
    QNetworkRequest netRequest;
    netRequest.setUrl(qurl);
    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=UTF-8");
    netRequest.setRawHeader("TOKEN", headToken.toUtf8());
    QEventLoop httploop;
    QNetworkReply *netReply;
    netReply = httpAccessmanger->post(netRequest, formData.toUtf8());
    qDebug() << "sync request msg" << qurl << headToken.toUtf8() << formData;

    connect(netReply, SIGNAL(finished()), &httploop, SLOT(quit()));
    connect(m_timer, &QTimer::timeout, &httploop, &QEventLoop::quit);
    m_timer->start();
    httploop.exec();

//    if( 302 ==  reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() )
//    {
//        disconnect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
//        connect(httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
//        QString tempUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toString();
//        httpRequest.setUrl(QUrl(tempUrl));
//        reply = httpAccessmanger->get(httpRequest);
//        httploop.exec();
//    }

    QByteArray byteArray;
    if(m_timer->isActive())
    {
        m_timer->stop();
        if(netReply->error() == QNetworkReply::NoError)
        {
            byteArray = netReply->readAll();
            qDebug()<< "http recv msg "<< byteArray;
            netReply->deleteLater();
            httpAccessmanger->deleteLater();
            return byteArray;//m_reqCode;
        }
        else
        {
            int statusCode = netReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            qDebug()<< "sync request http status code is" << statusCode;
        }
    }
    else
    {
        onRequstTimerOut();
    }
    netReply->deleteLater();
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

