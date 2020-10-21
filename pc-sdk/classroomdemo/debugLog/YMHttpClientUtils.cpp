#include <QCoreApplication>
#include "YMHttpClientUtils.h"

YMHttpClientUtils *YMHttpClientUtils::m_YMHttpClientUtils = NULL;

YMHttpClientUtils::YMHttpClientUtils()
{

}

YMHttpClientUtils::~YMHttpClientUtils()
{

}

YMHttpClientUtils *YMHttpClientUtils::getInstance()
{
    if(NULL == m_YMHttpClientUtils)
    {
        m_YMHttpClientUtils = new YMHttpClientUtils();
    }
    return m_YMHttpClientUtils;
}

// urlType为获取url的类型 获取 教研url 传0 其他url传 1
QString YMHttpClientUtils::getRunUrl(int urlType)
{
    QString tempUrl = "api.yimifudao.com/v2.4";
    // 控制读取配置文件: Qtyer.dll的次数(不需要每次都读), urlType = 0, urlType = 1的时候, 各读一次, 就可以了
    static QString strTempUrl_0 = ""; //urlType为0的时候
    static QString strTempUrl_1 = ""; //urlType为1的时候
    if(urlType == 0 && strTempUrl_0.length() > 0)
    {
        return strTempUrl_0;
    }
    else if(urlType == 1 && strTempUrl_1.length() > 0)
    {
        return strTempUrl_1;
    }
    // 如果都不是以上的两种if情况, 则继续读取配置文件
    QString exePath = QCoreApplication::applicationDirPath();
    QString strDllFile = exePath + "/Qtyer.dll"; //得到dll文件的绝对路径
    QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);
    // 环境类型  测试环境:0  正式环境:1 手动配置
    m_setting->beginGroup("EnvironmentType");
    int environmentType = m_setting->value("type").toInt();
    m_setting->endGroup();
    // 正式环境
    if(environmentType == 1)
    {
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("formal").toString();
            m_setting->endGroup();
        }
        else if(urlType == 1)//2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("formal").toString();
            m_setting->endGroup();
        }
    }
    else if(environmentType == 0)//测试环境
    {
        if(urlType == 0 ) //教研url
        {
            m_setting->beginGroup("Study");
            tempUrl =  m_setting->value("stage").toString();
            m_setting->endGroup();
        }
        else if(urlType == 1)// 2.4url
        {
            m_setting->beginGroup("V2.4");
            tempUrl = m_setting->value("stage").toString();
            m_setting->endGroup();
        }
    }
    if(tempUrl == "")
    {
        tempUrl = "api.yimifudao.com/v2.4";
    }

    //设置当前的开发环境
    if(tempUrl.contains("pre-"))
    {
        m_currentEnvironmentType = "pre";
    }
    else if(tempUrl.contains("stage-"))
    {
        m_currentEnvironmentType = "stage";
    }
    else if(tempUrl.contains("dev-"))
    {
        m_currentEnvironmentType = "dev";
    }
    else if(tempUrl.contains("stage2-"))
    {
        m_currentEnvironmentType = "stage2";
    }
    else if(tempUrl.contains("stage3-"))
    {
        m_currentEnvironmentType = "stage3";
    }
    else
    {
        if(tempUrl.split("-").size() >= 2)
        {
            m_currentEnvironmentType = tempUrl.split("-").at(0);
        }else
        {
            m_currentEnvironmentType = "api";
        }
    }

    // 记录tempUrl信息, 为了控制读取配置文件: Qtyer.dll的次数
    if(urlType == 0 && strTempUrl_0.length() <= 0)
    {
        strTempUrl_0 = tempUrl;
    }
    else if(urlType == 1 && strTempUrl_1.length() <= 0)
    {
        strTempUrl_1 = tempUrl;
    }
    return tempUrl;
}

// 得到当前环境类型
QString YMHttpClientUtils::getCurrentEnvironmentType()
{
    return m_currentEnvironmentType;
}

// http请求方法
QByteArray YMHttpClientUtils::httpPostForm(const QString & url, const QVariantMap &formData)
{
    QNetworkAccessManager *networkMgr = new QNetworkAccessManager();
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
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
    QNetworkReply * reply = networkMgr->post(request, multiPart);

    QEventLoop httploop;
    connect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray byteArray;
    if(reply->error() == QNetworkReply::NoError)
    {
        byteArray = reply->readAll();
    }
    else
    {
        emit onRequstTimerOut();
    }
    disconnect(networkMgr, SIGNAL(finished(QNetworkReply*)), &httploop, SLOT(quit()));
    reply->deleteLater();
    networkMgr->deleteLater();
    return byteArray;
}
