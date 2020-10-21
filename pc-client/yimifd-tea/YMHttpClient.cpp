﻿#include "YMHttpClient.h"
#include "YMHttpResponse.h"
#include "YMFileTransportResponse.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QFile>
#include <QEventLoop>
#include <QMessageBox>
#include <QProcess>
#include <QApplication>

extern int g_ReturnCode_Restart;
extern QString g_strAppFullPath;
extern QString g_strAppFileName;
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
            YMUserBaseInformation::url = "http://" + m_httpClient->getRunUrl(1);
            m_httpClient->httpUrl = YMUserBaseInformation::url;
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
    connect(m_networkMgr, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinished(QNetworkReply*)));
    m_timer = new QTimer();
    m_timer->setInterval(20000);
    m_timer->setSingleShot(true);
}

YMHttpClient * YMHttpClient::defaultInstance()
{
    return g_httpClientFactory.getHttpClient();
}

int YMHttpClient::httpGet(
        QString url,
        const QMap<QString, QString>& reqParam,
        YMHttpResponseHandler * handler)
{
    //qDebug() << "YMHttpClient::httpGet" << url << reqParam << handler;
    QUrl encodedUrl = QUrl(url);
    if (reqParam.size() > 0)
    {
        QStringList formatedParam;
        for (QMap<QString, QString>::const_iterator it = reqParam.begin(); it != reqParam.end(); it ++)
        {
            formatedParam << it.key() + "=" + it.value();
        }
        QString formatedUrl = url + "?" + formatedParam.join("&");
        encodedUrl = QUrl(formatedUrl);
    }
    //qDebug() << "YMHttpClient::httpGet" << encodedUrl;

    QNetworkReply * reply = m_networkMgr->get(QNetworkRequest(encodedUrl));
    YMHttpResponse * resp = new YMHttpResponse(reply, handler, ++m_reqCode);
    m_httpReqs.insert(reply, resp);

    return m_reqCode;
}

QByteArray YMHttpClient::httpGetVariant(
        QString url,
        YMHttpResponseHandler *handler)
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

int YMHttpClient::httpPostForm(
        const QString & url,
        const QMap<QString, QString>& formData,
        YMHttpResponseHandler * handler)
{
    //qDebug() << "YMHttpClient::httpPostForm" << url << formData << handler;

    QHttpMultiPart * multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    for (QMap<QString, QString>::const_iterator it = formData.begin(); it != formData.end(); it++)
    {
        QHttpPart httpPart;
        QString header = "form-data; name=\"PLACEHOLDER\"";
        header.replace("PLACEHOLDER", it.key());
        httpPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(header));
        httpPart.setBody(it.value().toStdString().c_str());
        multiPart->append(httpPart);
    }

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QNetworkReply * reply = m_networkMgr->post(request, multiPart);
    multiPart->setParent(reply);
    YMHttpResponse * resp = new YMHttpResponse(reply, handler, ++m_reqCode);
    m_httpReqs.insert(reply, resp);

    return m_reqCode;
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
    QTimer::singleShot(20000, &httploop, SLOT(quit()));
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

int YMHttpClient::httpPostVariant(
        const QString &url,
        const QVariantMap &formData,
        YMHttpResponseHandler *handler)
{
    //qDebug() << "YMHttpClient::httpPostVariant" << url << formData << handler;

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
    QNetworkReply * reply = m_networkMgr->post(request, multiPart);
    multiPart->setParent(reply);
    YMHttpResponse * resp = new YMHttpResponse(reply, handler, ++m_reqCode);
    m_httpReqs.insert(reply, resp);
    return m_reqCode;
}

int YMHttpClient::httpUploadFile(
        const QString &url,
        const QString &filename,
        const QString &remotePath,
        YMFileTransportEventHandler *handler)
{
    //qDebug() << "YMHttpClient::httpUploadFile" << url << filename << remotePath << handler;

    QHttpMultiPart * multipart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart part1;
    part1.setHeader(QNetworkRequest::ContentDispositionHeader, "application/x-www-form-urlencoded");
    part1.setBody(remotePath.toStdString().c_str());
    multipart->append(part1);
    QHttpPart part2;
    part2.setHeader(QNetworkRequest::ContentDispositionHeader, "application/x-www-form-urlencoded");
    part2.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("binary"));
    QFile * file = new QFile(filename);
    file->open(QIODevice::ReadOnly);
    part2.setBodyDevice(file);
    multipart->append(part2);
    file->setParent(multipart);

    QNetworkRequest request(QUrl(url.toStdString().c_str()));
    QNetworkReply * reply = m_networkMgr->post(request, multipart);
    multipart->setParent(reply);

    YMFileTransportResponse * resp = new YMFileTransportResponse(reply, handler, ++m_reqCode);
    m_fileReqs.insert(reply, resp);

    connect(reply, SIGNAL(uploadProgress(qint64, qint64)), resp, SLOT( onUploadProgress(qint64, qint64 )));

    return m_reqCode;
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

    if( 302 == httpReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() )
    {
        disconnect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        connect(m_networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
        QString tempUrl = httpReply->attribute(QNetworkRequest::RedirectionTargetAttribute).toString();
        httpRequest.setUrl(QUrl(tempUrl));
        httpReply = m_networkMgr->get(httpRequest);
        httploop.exec();
    }

    QByteArray readData = httpReply->readAll();
    return readData;
}

int YMHttpClient::ftpUploadFile(
        const QString &url,
        const QString &username,
        const QString &password,
        const QString &filename,
        YMFileTransportEventHandler *handler)
{
    //qDebug() << "YMHttpClient::ftpUploadFile" << url << username << password << filename;

    QUrl u(url.toStdString().c_str());
    u.setUserName(username);
    u.setPassword(password);
    u.setPort(21);

    QNetworkRequest request(u);

    QFile* file = new QFile(filename);
    if (file->open(QIODevice::ReadOnly))
    {
        QNetworkReply * reply = m_networkMgr->put(request, file);
        file->setParent(reply);
        YMFileTransportResponse * resp = new YMFileTransportResponse(reply, handler, ++m_reqCode);
        m_fileReqs.insert(reply, resp);

        qWarning() << "file" << file << "reply" << reply;

        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), resp, SLOT( onUploadProgress(qint64, qint64 )));
        return m_reqCode;
    }

    return 0;
}

void YMHttpClient::onNetworkStateChanged(QNetworkAccessManager::NetworkAccessibility accessible)
{
    //qDebug() << "YMHttpClient::onNetworkStateChanged" << accessible;
}

void YMHttpClient::onUploadProgress(qint64 /*bytesSent*/, qint64 /*bytesTotal*/)
{

}

void YMHttpClient::onDownloadProgress(qint64 /*bytesReceived*/, qint64 /*bytesTotal*/)
{

}

void YMHttpClient::onDownloadDataReady()
{
    //qDebug() << "YMHttpClient::onDownloadDataReady";
}

void YMHttpClient::onFinished(QNetworkReply * reply)
{
    //qDebug() << "YMHttpClient::onDownloadFinished";
    QMap<QNetworkReply *, YMHttpResponse *>::iterator it1 = m_httpReqs.find(reply);
    if (it1 != m_httpReqs.end())
    {
        disconnect(reply, 0, 0, 0);
        YMHttpResponse * resp = it1.value();
        resp->processResponse();
        delete resp;
        m_httpReqs.erase(it1);
        reply->deleteLater();
        return;
    }
    QMap<QNetworkReply *, YMFileTransportResponse *>::iterator it2 = m_fileReqs.find(reply);
    if (it2 != m_fileReqs.end())
    {
        disconnect(reply, 0, 0, 0);
        YMFileTransportResponse * resp = it2.value();
        resp->onFinished();
        delete resp;
        m_fileReqs.erase(it2);
        reply->deleteLater();
        return;
    }
}
//urlType为获取url的类型 获取 教研url 传0 其他url传 1
QString YMHttpClient::getRunUrl(int urlType)
{
    QString tempUrl = "api.yimifudao.com.cn/v2.4";

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
    QString strDllFile = g_strAppFullPath;
    strDllFile = strDllFile.replace(g_strAppFileName, "Qtyer.dll"); //得到dll文件的绝对路径
    qDebug() << "YMHttpClient::getRunUrl" << qPrintable(strDllFile) << urlType;

    QString strMsg = QString(u8"文件: %1, 不存在, 程序将退出." ) .arg(strDllFile);
    if(!QFile::exists(strDllFile))
    {
        QMessageBox::critical(NULL, MSG_BOX_TITLE, strMsg, QMessageBox::Ok, QMessageBox::Ok);
        qDebug() << "YMHttpClient::getRunUrl file not exist, file: " << qPrintable(strDllFile) << urlType;
        exit(1);
    }

    //=====================================
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);

    // 环境类型  测试环境 0  正式环境 1 手动配置
    m_setting->beginGroup("EnvironmentType");

    int environmentType = m_setting->value("type").toInt();
    int iPublicTest = m_setting->value("isPublic_Test").toInt(); //是不是公测的版本
    YMUserBaseInformation::m_bIsPublicTest = ((iPublicTest == 1) ? true : false);
    m_setting->endGroup();

    //====================
    //正式环境
    if(environmentType == 1)
    {
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("formal").toString();//, "jyhd.yimifudao.com"
            m_setting->setValue("stage", "stage-jyhd.yimifudao.com.cn");
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("formal").toString();//, "api.yimifudao.com/v2.4"
            m_setting->setValue("stage", "stage-api.yimifudao.com.cn/v2.4");
            m_setting->endGroup();
        }
    }
    //====================
    //测试环境
    else if(environmentType == 0)
    {
        YMUserBaseInformation::isStageEnvironment = true;
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("stage").toString();//, "jyhd.yimifudao.com"
            //m_setting->setValue("stage", "stage-jyhd.yimifudao.com");
            m_setting->endGroup();
        }

        if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("stage").toString();//, "api.yimifudao.com/v2.4"
            // m_setting->setValue("stage", "stage-api.yimifudao.com/v2.4");
            m_setting->endGroup();
        }
    }

    //=====================================
    //"切换测试网络环境"的相关代码
    QString strStage = "api";
    bool isPublicTest = m_setting->value("EnvironmentType/isPublic_Test").toInt() == 0 ? false : true;
    if(isPublicTest)
    {
       strStage = "test-api";
    }
    QString strHttpHeader = YMUserBaseInformation::m_strHttpHead;
    if(tempUrl.contains("pre-"))
    {
        strStage = "pre";
        strHttpHeader = YMUserBaseInformation::m_strHttpHead_Pre;
    }
    else if(tempUrl.contains("stage-"))
    {
        strStage = "stage";
        strHttpHeader = YMUserBaseInformation::m_strHttpHead_Stage;
    }
    else if(tempUrl.contains("dev-"))
    {
        strStage = "dev";
        strHttpHeader = YMUserBaseInformation::m_strHttpHead_Dev;
    }
    else if(tempUrl.contains("stage2-"))
    {
        strStage = "stage2";
        strHttpHeader = YMUserBaseInformation::m_strHttpHead_Stage2;
    }else
    {
        if(tempUrl.split("-").size() >= 2)
        {
            strStage = tempUrl.split("-").at(0);
            strHttpHeader = strHttpHeader.append(strStage).append("-");
        }
    }
    m_netType = environmentType;
    m_stage = strStage;

    //=====================================
    //记录各个环境的URL信息(生产环境, stage环境, pre环境, dev环境)
    m_setting->beginGroup("V2.4");

    //==========================
    QString strTea_Mis = m_setting->value("tea_Mis").toString();
    YMUserBaseInformation::m_strMis = strHttpHeader + strTea_Mis;

    //==========================
    QString strClassroomReport = m_setting->value("tea_ClassroomReport").toString();

    YMUserBaseInformation::m_strClassroomReport = strHttpHeader + strClassroomReport;

    //==========================
    QString strFreeTrial = m_setting->value("tea_FreeTrial").toString();
    YMUserBaseInformation::m_strWriteListenUrl= strHttpHeader + "h5.yimifudao.com.cn/hybrid/?lessonId=";

    //==========================
    QString strFreeTrialResult = m_setting->value("tea_FreeTrialResult").toString();

    YMUserBaseInformation::m_strListenUrl = strHttpHeader + strFreeTrialResult;

    //==========================
    m_setting->endGroup();

    //=====================================
    if(tempUrl == "")
    {
        tempUrl = "api.yimifudao.com.cn/v2.4";
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

void YMHttpClient::updateNetType(int netType, QString stage)
{
    QString strDllFile = g_strAppFullPath;
    strDllFile = strDllFile.replace(g_strAppFileName, "Qtyer.dll"); //得到dll文件的绝对路径
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);

    bool isPublicTest = m_setting->value("EnvironmentType/isPublic_Test").toInt() == 0 ? false : true;
    qDebug() << "==YMHttpClient::updateNetType==" << netType << stage << isPublicTest;
    if(netType == 0)
    {
        m_setting->setValue("EnvironmentType/type", netType);
        m_setting->setValue("V2.4/stage", stage + "-api.yimifudao.com.cn/v2.4");
        m_setting->setValue("Study/stage", stage + "-jyhd.yimifudao.com.cn");
        m_setting->setValue("MiniClass/miniUrl","http://"+ stage + "-platform.yimifudao.com.cn/v1.0.0");
        m_setting->setValue("MiniClass/miniH5","http://"+ stage + "-h5.yimifudao.com.cn/classAssignment");
    }
    if(netType == 1)
    {
        m_setting->setValue("EnvironmentType/type", netType);
        if(isPublicTest)
        {
            m_setting->setValue("V2.4/formal", "test-api.yimifudao.com.cn/v2.4");
            m_setting->setValue("Study/formal", "test-jyhd.yimifudao.com.cn");
        }else
        {
            m_setting->setValue("V2.4/formal", "api.yimifudao.com.cn/v2.4");
            m_setting->setValue("Study/formal", "jyhd.yimifudao.com.cn");
        }
        m_setting->setValue("MiniClass/miniUrl", "http://platform.yimifudao.com.cn/v1.0.0");
        m_setting->setValue("MiniClass/miniH5", "http://h5.yimifudao.com.cn/classAssignment");
    }
    m_setting->deleteLater();

    QProcess p;
    QString c = "taskkill /im classroom.exe /f";
    p.execute(c);
    p.close();

    c = "taskkill /im CourwarePreviewer.exe /f";
    p.execute(c);
    p.close();

    c = "taskkill /im player.exe /f";
    p.execute(c);
    p.close();

    c = "taskkill /im attendclassroom.exe /f";
    p.execute(c);
    p.close();
    QMessageBox::information(NULL, MSG_BOX_TITLE, QStringLiteral("配置成功, 程序将自动重启."), QMessageBox::Ok, QMessageBox::Ok);

    //参考链接: https://www.cnblogs.com/pyw0818/p/8048046.html
    qApp->exit(g_ReturnCode_Restart);
    //    exit(1);
}
